# scoon – App Konzept

## Vision

scoon ist eine Community-Plattform für Fotospots im DACH-Raum. Fotografen, Reisende und Locals entdecken gemeinsam die schönsten und verstecktesten Orte zum Fotografieren – kuratiert, bewertet und geteilt von der Community.

Im Gegensatz zu Google Maps oder Instagram stehen bei scoon **Qualität über Quantität** und **der Fotograf im Mittelpunkt**: Jeder Spot gehört einem Creator, jede Information ist auf Fotografie ausgerichtet.

---

## Zielgruppe

- **Hobby-Fotografen** (Smartphone & Kamera) die die besten Spots in ihrer Stadt suchen
- **Reisende** die abseits der Touristenpfade fotografieren wollen
- **Locals & Entdecker** die ihre eigene Stadt neu entdecken
- **Foto Studios** die über Lizenzverträge in die Plattform eingebunden werden

---

## Was macht einen Spot aus?

Jeder Spot auf scoon enthält:

| Feld | Beschreibung |
|------|-------------|
| Fotos | Hochwertige Community-Fotos des Spots |
| Name & Location | Name, Adresse, GPS-Koordinaten |
| Beste Zeit & Licht | Golden Hour, Sonnenauf-/-untergang, beste Jahreszeit |
| Bewertungen & Reviews | Community-Bewertungen, Erfahrungsberichte, Kommentare |
| Creator | Wer hat diesen Spot eingetragen / kuratiert |

---

## Business Model

### Phase 1 – Creator Economy (Launch)
- **Creators** verdienen Geld basierend auf Views, Aufrufen und Engagement ihrer Spots
- Ziel: Anreiz schaffen damit die Plattform schnell mit hochwertigen Spots befüllt wird
- Je mehr ein Spot aufgerufen wird, desto mehr verdient der Creator

### Phase 2 – Premium Abo
- **Nutzer** mit Premium-Abo können eigene Spots hinzufügen
- Ohne Abo: nur Entdecken & Bewerten
- Mögliche weitere Premium-Features: Offline-Karten, erweiterte Spot-Infos, Download in hoher Qualität

### Zusätzlich
- **Foto Studio Lizenzverträge**: Studios zahlen für Sichtbarkeit, Buchbarkeit und Integration auf der Plattform

---

## USP – Was unterscheidet scoon?

**Kuratierte Qualität.** Kein Spam, kein Noise.

- Google Maps hat alles – scoon hat nur das Beste für Fotografen
- Instagram ist zeitbasiert – scoon ist ortsbasiert und dauerhaft
- Jeder Spot ist verifiziert und von der Community bewertet
- Foto Studios als vertrauenswürdige Partner erhöhen die Qualität zusätzlich

---

## Launch-Markt

**DACH-Raum** – Österreich, Deutschland, Schweiz von Anfang an.

Start-Stadt: **Graz** (Seed-Content, erste Creator, erste Foto Studios)

---

## User Roles

| Rolle | Kann | Bezahlt |
|-------|------|---------|
| Free User | Spots entdecken, bewerten, kommentieren | Nein |
| Premium User | + Spots hinzufügen | Abo |
| Creator | + Geld verdienen durch Views | Revenue Share |
| Foto Studio | + Eigenes Profil, Buchbarkeit | Lizenzvertrag |

---

## Screens (aktuell implementiert)

- **Auth**: Splash, Welcome, Login, SignUp (Social, Form, Email)
- **Discovery**: Home, PlaceInfo, Kartenansicht, KartenansichtDetail, OrtSuche, OrtAuswahl
- **Community**: Favorites, Profile
- **Creator**: Insights, Einnahmen, Transaktionen, AddPhotoSpot
- **Settings**: Settings

---

## Tech Stack

- **iOS**: SwiftUI, Swift 6, iOS 26, Clean Architecture
- **Backend**: Supabase (Auth, PostgREST, Storage)
- **Maps**: MapKit (SwiftUI Map API)
- **Architecture**: Domain / Data / Presentation / Core / App
