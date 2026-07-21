# Kviz — Voditelj brodice A/B

Mini aplikacija za samo-testiranje za teorijski ispit za upravljanje brodicom (kategorije A i B).

Sve je u jednom fajlu: **[`kviz-brodica.html`](kviz-brodica.html)**. Nije potreban internet ni server — otvori fajl u browseru (dvoklik) i uči.

## Mogućnosti

- **354 pitanja** organizirana u 15 celina (nautička karta, kurs i pozicija, svjetionici, sidrenje, kardinalne/lateralne oznake, oprema i dokumentacija, vjetrovi, zvučni signali, izbjegavanje sudara, svjetla broda, radiofonija, spelovanje, konopi i uzlovi, motori, sigurnost i postupci).
- **Tipovi pitanja**: Osnovna, Napredna, Triki (zamke) i Vizuelna.
- **Vizuelna pitanja** (crtano kao SVG): ruža vjetrova, čitanje koordinata i kursa na karti, kardinalne/lateralne oznake, svjetla broda.
- Uz svako pitanje piše **gdje se gradivo nalazi u skripti** (strana + poglavlje).
- **Hint** za svako pitanje.
- **Pametno ponavljanje** (Leitner sistem) — pitanja koja grešiš vraćaju se češće; celine se miješaju (nije linearno).
- **Napredak i statistika** se pamte u browseru (localStorage); možeš se vraćati neograničeno puta.

## Napomena o izvoru

Pitanja su izrađena isključivo iz priručnika *Nautika Klub — Voditelj brodice A i B*. Sam priručnik (PDF) nije uključen u repozitorij jer je autorski materijal.

## Pokretanje

Otvori `kviz-brodica.html` u bilo kojem modernom browseru. Za online verziju možeš uključiti GitHub Pages (Settings → Pages → Deploy from branch → main).
