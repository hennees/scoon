# Supabase Setup – scoon

Dieser Guide führt dich in ~15 Minuten von 0 zu einem laufenden Backend.

---

## Schritt 1 – Supabase Projekt erstellen

1. Gehe auf [supabase.com](https://supabase.com) → **Start your project**
2. Organisation erstellen (z.B. `scoon`)
3. Neues Projekt:
   - **Name:** `scoon`
   - **Database Password:** sicheres Passwort wählen + notieren
   - **Region:** `Central EU (Frankfurt)` → nächste Region für DACH
4. Warten bis das Projekt bereit ist (~1–2 Min)

---

## Schritt 2 – Datenbank Schema einrichten

1. Im Supabase Dashboard → **SQL Editor** (linke Sidebar)
2. Klick auf **New query**
3. Inhalt der Datei `scripts/supabase_schema.sql` komplett reinkopieren
4. Klick auf **Run** (oder `Cmd+Enter`)
5. Grüne Meldung = Erfolg

Das erstellt automatisch:
- Tabellen: `profiles`, `spots`, `favorites`, `transactions`
- View: `spots_with_favorites` (Spots mit `is_favorite` pro User)
- Row Level Security Policies
- Trigger: erstellt automatisch ein Profil wenn sich ein User registriert
- Indexes für Performance

---

## Schritt 3 – Google OAuth einrichten

### 3a – Google Cloud Console

1. Gehe auf [console.cloud.google.com](https://console.cloud.google.com)
2. Neues Projekt erstellen → Name: `scoon`
3. Linke Sidebar → **APIs & Services** → **OAuth consent screen**
   - User Type: **External**
   - App Name: `scoon`
   - Support Email: deine E-Mail
   - Speichern
4. Linke Sidebar → **Credentials** → **Create Credentials** → **OAuth 2.0 Client ID**
   - Application type: **Web application**
   - Name: `scoon-supabase`
   - **Authorized redirect URIs** → Add URI:
     ```
     https://DEIN-PROJECT-REF.supabase.co/auth/v1/callback
     ```
     *(Project Ref findest du im Supabase Dashboard URL oder unter Settings → General)*
5. **Create** → du bekommst **Client ID** und **Client Secret** → beide notieren

### 3b – In Supabase eintragen

1. Supabase Dashboard → **Authentication** → **Providers**
2. **Google** aufklappen → Enable
3. **Client ID** und **Client Secret** von Google eintragen
4. **Save**

### 3c – URL Scheme in Xcode registrieren

1. Xcode → Projekt auswählen → **Info** Tab
2. **URL Types** → `+` klicken
3. **URL Schemes:** `scoon`
4. **Identifier:** `at.scoon.app`

Das erlaubt Supabase nach dem Google Login zurück zur App zu redirecten.

---

## Schritt 4 – Xcode Scheme konfigurieren

1. Xcode → oben beim Scheme-Selector → **Edit Scheme...**
2. **Run** → **Arguments** → **Environment Variables**
3. Diese drei Variablen hinzufügen:

| Name | Wert |
|------|------|
| `SUPABASE_URL` | `https://DEIN-PROJECT-REF.supabase.co` |
| `SUPABASE_ANON_KEY` | dein Anon Key (siehe unten) |
| `SCOON_USE_REMOTE_DATA` | `true` |

**Wo findest du URL und Anon Key?**
Supabase Dashboard → **Settings** → **API**
- **Project URL** = `SUPABASE_URL`
- **anon public** Key = `SUPABASE_ANON_KEY`

> ⚠️ Den `SUPABASE_ANON_KEY` nie in den Code committen.
> Er bleibt nur in den Xcode Scheme Environment Variables (werden nicht gepusht).

---

## Schritt 5 – Testen

1. App in Xcode bauen und auf Simulator/Device starten
2. Registrieren mit E-Mail + Passwort
3. Im Supabase Dashboard → **Authentication** → **Users** → dein User sollte erscheinen
4. Im **Table Editor** → `profiles` → dein Profil wurde automatisch erstellt (via Trigger)
5. Google Login testen → Button in der App → Browser öffnet sich → Google auswählen → zurück zur App

---

## Troubleshooting

**"Missing apikey"** → `SUPABASE_ANON_KEY` fehlt oder falsch geschrieben in Xcode Scheme

**Google Login öffnet sich nicht** → URL Scheme `scoon` in Info Tab nicht eingetragen

**Google Login redirectet nicht zurück** → Redirect URI in Google Cloud Console stimmt nicht mit Supabase Project URL überein

**Profile wird nicht erstellt** → SQL Schema nicht komplett ausgeführt (Trigger fehlt) → nochmal den SQL Editor laufen lassen

**App nutzt noch Mock-Daten** → `SCOON_USE_REMOTE_DATA` nicht auf `true` gesetzt

---

## Supabase Storage (für Foto-Upload – Phase 3)

1. Supabase Dashboard → **Storage** → **New bucket**
2. Name: `spot-images`
3. **Public bucket**: ✅ (Fotos sollen öffentlich sichtbar sein)
4. Policies → Add Policy → **Allow authenticated uploads**

> Das wird in Phase 3 eingebaut wenn Image Upload implementiert wird.
