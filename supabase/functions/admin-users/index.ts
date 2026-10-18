// Edge funkcija: upravljanje korisnicima (samo za administratore).
// Radi sa service_role ključem koji postoji ISKLJUČIVO na serveru (SUPABASE_SERVICE_ROLE_KEY).
// Akcije (POST, JSON): create, set_password, set_active, delete.
import { createClient } from "npm:@supabase/supabase-js@2.49.4";

// Dopuštena porijekla (CORS). Dodatna se postavljaju u tajnama funkcije: ALLOWED_ORIGINS=https://a.vercel.app,https://b.hr
const ALLOWED_ORIGINS = [
  "https://markojankovicgit.github.io",
  "http://localhost:5178",
  "http://127.0.0.1:5178",
  ...(Deno.env.get("ALLOWED_ORIGINS") ?? "").split(",").map((o) => o.trim()).filter((o) => /^https?:\/\/[^\s*]+$/.test(o)),
];

function corsHeaders(origin: string | null): Record<string, string> {
  const allow = origin && ALLOWED_ORIGINS.includes(origin) ? origin : ALLOWED_ORIGINS[0];
  return {
    "Access-Control-Allow-Origin": allow,
    "Access-Control-Allow-Headers": "authorization, apikey, content-type, x-client-info",
    "Access-Control-Allow-Methods": "POST, OPTIONS",
    "Vary": "Origin",
  };
}

const EMAIL_RE = /^[^\s@]+@[^\s@]+\.[^\s@]{2,}$/;

Deno.serve(async (req: Request) => {
  const cors = corsHeaders(req.headers.get("Origin"));
  const json = (body: unknown, status = 200) =>
    new Response(JSON.stringify(body), { status, headers: { ...cors, "Content-Type": "application/json" } });

  if (req.method === "OPTIONS") return new Response(null, { status: 204, headers: cors });
  if (req.method !== "POST") return json({ error: "Metoda nije dopuštena." }, 405);

  const url = Deno.env.get("SUPABASE_URL");
  const serviceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
  if (!url || !serviceKey) return json({ error: "Poslužitelj nije podešen." }, 500);
  const admin = createClient(url, serviceKey, { auth: { persistSession: false, autoRefreshToken: false } });

  // 1) tko zove? (JWT prijavljenog korisnika)
  const token = (req.headers.get("Authorization") ?? "").replace(/^Bearer\s+/i, "");
  if (!token) return json({ error: "Nisi prijavljen." }, 401);
  const { data: who, error: whoErr } = await admin.auth.getUser(token);
  if (whoErr || !who?.user) return json({ error: "Nisi prijavljen." }, 401);
  const callerId = who.user.id;

  // 2) smije li? (samo aktivni administrator)
  const { data: caller } = await admin.from("profiles").select("role, active").eq("id", callerId).maybeSingle();
  if (!caller || caller.role !== "admin" || !caller.active) return json({ error: "Nemaš ovlasti." }, 403);

  let body: Record<string, unknown>;
  try { body = await req.json(); } catch { return json({ error: "Neispravan zahtjev." }, 400); }

  const activeAdminCount = async () => {
    const { count } = await admin.from("profiles").select("id", { count: "exact", head: true })
      .eq("role", "admin").eq("active", true);
    return count ?? 0;
  };
  const isLastActiveAdmin = async (id: string) => {
    const { data } = await admin.from("profiles").select("role, active").eq("id", id).maybeSingle();
    return !!data && data.role === "admin" && data.active && (await activeAdminCount()) <= 1;
  };
  const validPassword = (p: unknown): p is string => typeof p === "string" && p.length >= 8 && p.length <= 72;

  try {
    switch (body.action) {
      case "create": {
        const email = String(body.email ?? "").trim().toLowerCase();
        const name = String(body.name ?? "").trim().slice(0, 120);
        const role = body.role === "admin" ? "admin" : "user";
        if (!EMAIL_RE.test(email) || email.length > 254) return json({ error: "Upiši ispravnu e-mail adresu." }, 400);
        const pw = body.password;
        if (!validPassword(pw)) return json({ error: "Lozinka mora imati 8 do 72 znaka." }, 400);
        const { data, error } = await admin.auth.admin.createUser({
          email,
          password: pw,
          email_confirm: true,
          user_metadata: { full_name: name },
          app_metadata: { role, created_by: callerId },
        });
        if (error) {
          const dup = /already|registered|exists/i.test(error.message);
          return json({ error: dup ? "Korisnik s tim e-mailom već postoji." : "Korisnik nije kreiran." }, dup ? 409 : 400);
        }
        return json({ id: data.user.id, email });
      }

      case "set_password": {
        const id = String(body.id ?? "");
        if (!id) return json({ error: "Nedostaje korisnik." }, 400);
        const pw = body.password;
        if (!validPassword(pw)) return json({ error: "Lozinka mora imati 8 do 72 znaka." }, 400);
        const { error } = await admin.auth.admin.updateUserById(id, { password: pw });
        if (error) return json({ error: "Lozinka nije promijenjena." }, 400);
        return json({ ok: true });
      }

      case "set_active": {
        const ids = Array.isArray(body.ids) ? body.ids.map(String).slice(0, 200) : [];
        const active = body.active === true;
        let changed = 0; const skipped: string[] = [];
        for (const id of ids) {
          if (id === callerId) { skipped.push(id); continue; }                       // sebe ne deaktiviraš
          if (!active && await isLastActiveAdmin(id)) { skipped.push(id); continue; } // zadnji admin
          const { error } = await admin.auth.admin.updateUserById(id, { ban_duration: active ? "none" : "876000h" });
          if (error) { skipped.push(id); continue; }
          await admin.from("profiles").update({ active }).eq("id", id);
          changed++;
        }
        return json({ changed, skipped });
      }

      case "delete": {
        const id = String(body.id ?? "");
        if (!id || id === callerId) return json({ error: "Ne možeš obrisati ovaj račun." }, 400);
        if (await isLastActiveAdmin(id)) return json({ error: "Ne možeš obrisati zadnjeg administratora." }, 400);
        const { error } = await admin.auth.admin.deleteUser(id);
        if (error) return json({ error: "Korisnik nije obrisan." }, 400);
        return json({ ok: true });
      }

      default:
        return json({ error: "Nepoznata akcija." }, 400);
    }
  } catch (_e) {
    return json({ error: "Greška na poslužitelju." }, 500);
  }
});
