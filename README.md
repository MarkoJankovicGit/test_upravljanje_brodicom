# Kviz — Voditelj brodice A/B (Boat Training Rovinj)

Aplikacija za pripremu teorijskog ispita za voditelja brodice (kategorije A i B). Aplikacija je jedan statični fajl: **[`index.html`](index.html)** (uz logo `btr-logo.jpg`). Stari link `kviz-brodica.html` preusmjerava na njega.

## Mogućnosti

- **Tri jezika: hrvatski, engleski, njemački.** Cijela učenička aplikacija i svih 414 pitanja (tekst, odgovori, pomoć, gradivo, odgovori za upis) dostupni su na sva tri jezika; učenik bira jezik izbornikom u gornjoj traci (na prijavi, u svim ekranima i usred kviza); promjena je odmah, bez osvježavanja i bez gubitka rezultata. **Admin panel je uvijek na hrvatskom.** Prijevodi pitanja su nacrt za stručni pregled, vidi [PREVODI-ZA-PREGLED.md](PREVODI-ZA-PREGLED.md).
- **414 pitanja** u 16 lekcija, složenih u 6 grupa (usmeni ispit, navigacija, oznake/svjetla/signali, pravila i sigurnost, brod i oprema, komunikacija).
- **Složi vlastitu vježbu**: lekcije, težina i vrsta (Osnovna, Napredna, Zamke, Slikovna), broj pitanja. Izbor se pamti po korisniku.
- **Slikovna i animirana pitanja** (SVG): ruža vjetrova i kursa, karta s koordinatama, kardinalne/lateralne oznake, svjetla broda, scenariji izbjegavanja sudara, karakteristike svjetala.
- Uz svako pitanje: gdje se gradivo nalazi u skripti + pomoć (hint).
- **Pametno ponavljanje** (Leitner) — pitanja koja grešiš vraćaju se češće.
- **Prijava e-mailom i lozinkom** (Supabase Auth), napredak i statistika odvojeni po korisniku i spremljeni u bazi, dostupni s bilo kojeg uređaja.
- **Admin panel** (uvijek hrvatski): kreiranje korisnika (e-mail + lozinka), **promjena uloge** (učenik, administrator ili oboje), deaktivacija, nova lozinka, brisanje, povijest prijava (uspješne i neuspješne). Admin ne vidi tuđi napredak. Korisnik s obje uloge u aplikaciji prelazi između učenja i administracije (kartice "Admin" i "Učenje").

## Arhitektura

- **Frontend:** jedan statični HTML (`index.html`), GitHub Pages ili Vercel. Bez build koraka i bez vanjskih biblioteka; prema Supabaseu ide običan `fetch`.
- **Baza i prijava:** Supabase (projekt `ouavhtfnhvfzyzzftyks`, eu-north-1). Šema i pravila pristupa su u [`supabase/`](supabase/README.md).
- **Upravljanje korisnicima:** Edge funkcija `admin-users` (kreiranje, nova lozinka, deaktivacija, brisanje). Samo ona koristi tajni `service_role` ključ, koji nikad nije u pregledniku ni u repou.
- **U pregledniku** su samo URL projekta i javni (publishable) ključ; zaštitu daju RLS pravila u bazi.
- Javna registracija je isključena: korisnike dodaje isključivo admin.

## Objava na Vercelu

1. Vercel → **Add New → Project** → odaberi repo `test_upravljanje_brodicom`.
2. **Framework Preset: Other.** Build Command, Install Command i Output Directory ostavi prazne (`vercel.json` to već postavlja). Nema `package.json` ni build koraka.
3. Deploy. Početna stranica je `index.html`.
4. **Obavezno nakon prvog deploya:** adresu projekta (npr. `https://naziv.vercel.app`, i vlastitu domenu ako je bude) dodaj u Supabase → Edge Functions → **Secrets** → `ALLOWED_ORIGINS` (više adresa odvoji zarezom). Bez toga admin ne može kreirati korisnike s te adrese.

`vercel.json` šalje zaglavlja: zabrana indeksiranja, CSP (dopušta samo vlastiti sadržaj, Google Fonts i Supabase projekt), `X-Frame-Options: DENY` i ostala. `.vercelignore` sprječava objavu `supabase/` i `*.md`. Ako se promijeni adresa Supabase projekta, treba izmijeniti `connect-src` u CSP-u.

## Ograničenja i sljedeći koraci

- Pitanja iz skripte su i dalje u HTML-u (vidljiva prije prijave). Za produkciju ih treba premjestiti u bazu iza prijave.
- Povijest neuspjelih prijava upisuje preglednik (funkcija `record_failed_login`, s ograničenjem broja zapisa). Za strožu kontrolu treba prijavu provući kroz Edge funkciju ili Auth Hook.
- Nema oporavka zaboravljene lozinke (admin postavlja novu). Za to treba slanje e-pošte.
- Jezik se pamti po uređaju, ne po računu.

## Pokretanje

- Online: GitHub Pages (`main` grana).
- Vercel: vidi niže.
- Lokalno: `python -m http.server 5178` u ovom folderu, pa `http://localhost:5178/` (prijava traži `https` ili `localhost`).

## Napomena o izvoru

Pitanja su izrađena isključivo iz priručnika *Nautika Klub — Voditelj brodice A i B*. Sam priručnik (PDF) nije uključen u repozitorij jer je autorski materijal.
