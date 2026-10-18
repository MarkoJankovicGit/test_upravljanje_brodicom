# Kviz — Voditelj brodice A/B (Boat Training Rovinj)

Aplikacija za pripremu teorijskog ispita za voditelja brodice (kategorije A i B). Sve je u jednom fajlu: **[`kviz-brodica.html`](kviz-brodica.html)**.

## Mogućnosti

- **414 pitanja** u 16 lekcija, složenih u 6 grupa (ispitna pitanja, navigacija, oznake/svjetla/signali, pravila i sigurnost, brod i oprema, komunikacija).
- **Složi svoj kviz** — uvijek vidljiv: lekcije, težina i vrsta (Osnovna, Napredna, Zamke, Slikovna), broj pitanja. Izbor se pamti po korisniku.
- **Slikovna i animirana pitanja** (SVG): ruža vjetrova i kursa, karta s koordinatama, kardinalne/lateralne oznake, svjetla broda, scenariji izbjegavanja sudara, karakteristike svjetala.
- Uz svako pitanje: gdje se gradivo nalazi u skripti + pomoć (hint).
- **Pametno ponavljanje** (Leitner) — pitanja koja grešiš vraćaju se češće.
- **Prijava e-mailom i lozinkom**, statistika odvojena po korisniku.
- **Admin panel**: kreiranje korisnika (e-mail + lozinka), deaktivacija, nova lozinka, brisanje, povijest prijava (uspješne i neuspješne).

## Demo način — važno

Ovo je **demo bez poslužitelja**. Korisnici, lozinke (SHA-256 sa soli), napredak i povijest prijava spremaju se u `localStorage` preglednika:

- korisnik kreiran u adminu može se prijaviti **samo u istom pregledniku/uređaju**;
- admin vidi prijave **samo s tog uređaja**;
- zaštita je samo simulacija (klijentska strana) — nije za stvarne korisnike.

Sav pristup podacima ide kroz objekte `KV` i `Auth` u skripti. Za produkciju se oni zamjenjuju API pozivima prema bazi (npr. Supabase/Postgres), bez promjene ekrana.

### Demo računi (seed)

| Uloga | E-mail | Lozinka |
|---|---|---|
| Administrator | `admin@demo.hr` | `admin-demo-2026` |
| Učenik | `ucenik@demo.hr` | `ucenik-demo-2026` |

Na ekranu prijave postoji i „Demo pristup" koji popunjava formu.

## Pokretanje

- Online: GitHub Pages (`main` grana).
- Lokalno: `python -m http.server 5178` u ovom folderu pa otvori `http://localhost:5178/kviz-brodica.html` (prijava treba `localStorage` i Web Crypto, koji ne rade pri otvaranju fajla dvoklikom u svim preglednicima).

## Napomena o izvoru

Pitanja su izrađena isključivo iz priručnika *Nautika Klub — Voditelj brodice A i B*. Sam priručnik (PDF) nije uključen u repozitorij jer je autorski materijal.
