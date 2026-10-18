# Supabase — Boat Training Rovinj

Projekt: `ouavhtfnhvfzyzzftyks` (https://ouavhtfnhvfzyzzftyks.supabase.co), region eu-north-1.

## Šema

`migrations/20261018000000_init.sql` — primijenjeno u SQL editoru projekta.

| Tablica | Sadržaj | Tko čita | Tko piše |
|---|---|---|---|
| `profiles` | korisnik: e-mail, ime, uloga, aktivan, zadnja prijava, broj prijava | vlasnik, admin | samo Edge funkcija (service_role) |
| `login_events` | povijest prijava (uspješne i neuspješne) | admin | funkcije `record_login`, `record_failed_login` |
| `user_progress` | napredak po pitanju (kutija, viđeno, točno, krivo) | samo vlasnik | vlasnik |
| `user_state` | postavke i dani aktivnosti | samo vlasnik | vlasnik |

Admin namjerno **ne vidi** tuđi napredak.

## Postavke projekta

- Javna registracija (`Allow new users to sign up`) je **isključena**. Korisnike dodaje samo admin.
- Anonimne prijave isključene.

## Edge funkcija `admin-users`

`functions/admin-users/index.ts` — postavljena u projekt (Edge Functions → Deploy via Editor). Provjera tokena na ulazu ("Verify JWT with legacy secret") je isključena jer funkcija sama provjerava prijavljenog korisnika i je li aktivni admin. Dopušteno porijeklo: `https://markojankovicgit.github.io` i lokalni `5178`. Akcije: `create`, `set_password`, `set_active`, `delete`; štiti zadnjeg administratora i samog sebe.

## Provjera pravila pristupa

RLS je provjeren transakcijom koja se sama poništava (3 privremena naloga: 2 učenika i admin; učenik, anonimni, admin i deaktivirani korisnik): učenik vidi samo svoje i ne može mijenjati ulogu ni upisivati tuđe, anonimni nemaju pristup, admin vidi profile i prijave ali ne tuđi napredak, deaktiviran korisnik ne može upisivati.

## Prvi administrator

Račun se pravi ručno u dashboardu (Authentication → Users → Add user → Auto confirm). Zatim se promovira:

```sql
update public.profiles set role = 'admin' where lower(email) = lower('ADMIN_EMAIL');
```

## Ključevi

- U preglednik smije samo URL projekta i **publishable** ključ (uz RLS).
- `service_role` / secret ključ **nikad** u HTML, git ni chat; koristi se samo u Edge funkcijama.
