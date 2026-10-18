# Kviz — Voditelj brodice A/B (Boat Training Rovinj)

Aplikacija za pripremu teorijskog ispita za voditelja brodice (kategorije A i B). Sve je u jednom fajlu: **[`kviz-brodica.html`](kviz-brodica.html)** (uz logo `btr-logo.jpg`).

## Mogućnosti

- **Tri jezika: hrvatski, engleski, njemački.** Cijela učenička aplikacija i svih 414 pitanja (tekst, odgovori, pomoć, gradivo, odgovori za upis) dostupni su na sva tri jezika; učenik bira jezik izbornikom u gornjoj traci (uz DEMO oznaku, na prijavi, u svim ekranima i usred kviza); promjena je odmah, bez osvježavanja i bez gubitka rezultata. **Admin panel je uvijek na hrvatskom.** Prijevodi pitanja su nacrt za stručni pregled, vidi [PREVODI-ZA-PREGLED.md](PREVODI-ZA-PREGLED.md).
- **414 pitanja** u 16 lekcija, složenih u 6 grupa (usmeni ispit, navigacija, oznake/svjetla/signali, pravila i sigurnost, brod i oprema, komunikacija).
- **Složi vlastitu vježbu**: lekcije, težina i vrsta (Osnovna, Napredna, Zamke, Slikovna), broj pitanja. Izbor se pamti po korisniku.
- **Slikovna i animirana pitanja** (SVG): ruža vjetrova i kursa, karta s koordinatama, kardinalne/lateralne oznake, svjetla broda, scenariji izbjegavanja sudara, karakteristike svjetala.
- Uz svako pitanje: gdje se gradivo nalazi u skripti + pomoć (hint).
- **Pametno ponavljanje** (Leitner) — pitanja koja grešiš vraćaju se češće.
- **Prijava e-mailom i lozinkom** (Supabase Auth), napredak i statistika odvojeni po korisniku i spremljeni u bazi, dostupni s bilo kojeg uređaja.
- **Admin panel** (uvijek hrvatski): kreiranje korisnika (e-mail + lozinka), deaktivacija, nova lozinka, brisanje, povijest prijava (uspješne i neuspješne). Admin ne vidi tuđi napredak.

## Arhitektura

- **Frontend:** jedan statični HTML (`kviz-brodica.html`), GitHub Pages. Bez build koraka i bez vanjskih biblioteka; prema Supabaseu ide običan `fetch`.
- **Baza i prijava:** Supabase (projekt `ouavhtfnhvfzyzzftyks`, eu-north-1). Šema i pravila pristupa su u [`supabase/`](supabase/README.md).
- **Upravljanje korisnicima:** Edge funkcija `admin-users` (kreiranje, nova lozinka, deaktivacija, brisanje). Samo ona koristi tajni `service_role` ključ, koji nikad nije u pregledniku ni u repou.
- **U pregledniku** su samo URL projekta i javni (publishable) ključ; zaštitu daju RLS pravila u bazi.
- Javna registracija je isključena: korisnike dodaje isključivo admin.

## Ograničenja i sljedeći koraci

- Pitanja iz skripte su i dalje u HTML-u (vidljiva prije prijave). Za produkciju ih treba premjestiti u bazu iza prijave.
- Povijest neuspjelih prijava upisuje preglednik (funkcija `record_failed_login`, s ograničenjem broja zapisa). Za strožu kontrolu treba prijavu provući kroz Edge funkciju ili Auth Hook.
- Nema oporavka zaboravljene lozinke (admin postavlja novu). Za to treba slanje e-pošte.
- Jezik se pamti po uređaju, ne po računu.

## Pokretanje

- Online: GitHub Pages (`main` grana).
- Lokalno: `python -m http.server 5178` u ovom folderu, pa `http://localhost:5178/kviz-brodica.html` (prijava traži `https` ili `localhost`).

## Napomena o izvoru

Pitanja su izrađena isključivo iz priručnika *Nautika Klub — Voditelj brodice A i B*. Sam priručnik (PDF) nije uključen u repozitorij jer je autorski materijal.
