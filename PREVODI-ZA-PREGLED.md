# Prijevodi pitanja (EN, DE): popis za stručni pregled

Sva 414 pitanja prevedena su s hrvatskog na engleski i njemački strojno (Claude). To je **nacrt**: prije korištenja s pravim polaznicima treba ga pregledati osoba koja zna pomorsku terminologiju na tom jeziku.

Prijevodi su u `kviz-brodica.html` u objektu `I18N_Q` (ključ = id pitanja). Hrvatski izvornik je ostao netaknut.

## Što je automatski provjereno

- Svih 414 pitanja ima en i de.
- Isti broj i **isti redoslijed** ponuđenih odgovora (prvi je uvijek točan).
- Brojčani odgovori i koordinate nisu promijenjeni.
- Pitanja s upisom odgovora imaju vlastite liste prihvatljivih odgovora na svakom jeziku (en 310, de 355 unosa); sve ih aplikacija prihvaća.

## Što prevoditelj nije bio siguran: pregledati prvo

| Id pitanja | Tema nesigurnosti |
|---|---|
| kart11, svj3 | oznake na karti (dno „p", hrvatska kratica „Bl") |
| sid4, sid8, sid11, sid-n1 | sidreni pojmovi (mačak, sklopiva kolva, uteg „anđeo", orepina, „kolač") |
| opr5 | plovidbena dozvola |
| vje25 | strane svijeta u odgovoru (njemački koristi O za istok: NO, SO) |
| vje-t1, vje-n6, vje-t3 | nazivi tipova bure; pijavica (waterspout / Wasserhose) |
| zvu-n1 | brod koji ne ostvaruje kretanje kroz vodu |
| svl6, svl7, svl-t2 | ribarice: koča (trawler / Schleppnetzfischer), plivarica (purse seiner / Ringwadenfischer) |
| uzl1–uzl12 | nazivi čvorova (pašnjak, plutačni, vrtni, sidreni); uz prijevod je ostao hrvatski naziv |
| pula28–pula32 | izgovor slova u ITU abecedi; hrvatska fonetska transkripcija iz skripte dodana kao bilješka |
| pula45–pula47 | hrvatske oznake dna K, P, T (kamen / pijesak / trava) |

## Napomene

- Hrvatska imena vjetrova (Bura, Jugo, Maestral…) ostaju lokalna imena, uz opći naziv gdje pomaže.
- Pitanja o hrvatskim kraticama na karti (Bl, Izo, Pk) zadržavaju hrvatsku kraticu uz međunarodnu (Fl, Iso, Oc).
- Engleski koristi decimalnu točku, njemački decimalni zarez.
