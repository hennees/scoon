import SwiftUI

struct LegalScreen: View {
    @Environment(AppRouter.self) private var router
    let title:   String
    let content: String

    var body: some View {
        ZStack {
            Color.scoonDarker.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {

                    // ── Header ────────────────────────────────────────
                    HStack {
                        BackButton { router.navigateBack() }
                        VStack(alignment: .leading, spacing: 1) {
                            Text(title)
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.primary)
                            Text("scoon")
                                .font(.system(size: 12))
                                .foregroundColor(Color.scoonOrange)
                        }
                        .padding(.leading, 10)
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 56)

                    // ── Content card ──────────────────────────────────
                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(Array(parsedSections.enumerated()), id: \.offset) { idx, section in
                            VStack(alignment: .leading, spacing: 10) {
                                if section.isHeader {
                                    HStack(alignment: .center, spacing: 10) {
                                        Rectangle()
                                            .fill(Color.scoonOrange)
                                            .frame(width: 3, height: 15)
                                            .cornerRadius(1.5)
                                        Text(section.title)
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundColor(.primary)
                                    }
                                    .padding(.top, idx == 0 ? 0 : 20)
                                }

                                if !section.body.isEmpty {
                                    Text(section.body)
                                        .font(.system(size: 14))
                                        .foregroundColor(Color.white.opacity(0.5))
                                        .lineSpacing(5)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                            }
                        }
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 18)
                            .fill(Color.primary.opacity(0.04))
                            .overlay(
                                RoundedRectangle(cornerRadius: 18)
                                    .stroke(Color.primary.opacity(0.07), lineWidth: 1)
                            )
                    )
                    .padding(.horizontal, 20)
                    .padding(.top, 24)

                    Spacer().frame(height: 80)
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }

    // MARK: – Content parser

    private struct LegalSection {
        let title:    String
        let body:     String
        let isHeader: Bool
    }

    private var parsedSections: [LegalSection] {
        var sections: [LegalSection] = []
        // Split by double newline = paragraph groups
        let paragraphs = content
            .components(separatedBy: "\n\n")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        for paragraph in paragraphs {
            let lines = paragraph.components(separatedBy: "\n")
            let first = lines.first ?? ""

            // Numbered header: "1. Title" or "2. Something"
            if first.first?.isNumber == true, let dotRange = first.range(of: ". ") {
                let sectionTitle = String(first[dotRange.upperBound...])
                let bodyLines = lines.dropFirst()
                    .map { $0.trimmingCharacters(in: .whitespaces) }
                    .filter { !$0.isEmpty }
                sections.append(.init(
                    title:    sectionTitle,
                    body:     bodyLines.joined(separator: "\n"),
                    isHeader: true
                ))
            } else if sections.isEmpty {
                // Lead paragraph (document title + meta)
                sections.append(.init(
                    title: first,
                    body:  lines.dropFirst().joined(separator: "\n").trimmingCharacters(in: .whitespaces),
                    isHeader: false
                ))
            } else {
                // Plain body paragraph
                sections.append(.init(title: "", body: paragraph, isHeader: false))
            }
        }
        return sections
    }
}

// MARK: – Legal content (Placeholder)

enum LegalContent {
    static let privacy = """
Datenschutzerklärung

Zuletzt aktualisiert: März 2026

1. Verantwortlicher
scoon GmbH, Graz, Österreich

2. Erhobene Daten
Wir erheben folgende personenbezogene Daten:
- E-Mail-Adresse und Benutzername bei der Registrierung
- Hochgeladene Fotos und Ortsbeschreibungen
- Standortdaten (nur bei expliziter Erlaubnis)
- Nutzungsstatistiken (anonymisiert)

3. Zweck der Verarbeitung
Ihre Daten werden ausschließlich zur Bereitstellung der scoon-App, zur Kommunikation mit Ihnen und zur Verbesserung unserer Dienste verarbeitet.

4. Datenweitergabe
Wir geben Ihre Daten nicht an Dritte weiter, es sei denn, dies ist zur Erfüllung unserer Leistungen erforderlich (z.B. Cloud-Hosting über Supabase).

5. Speicherdauer
Ihre Daten werden gespeichert, solange Ihr Konto aktiv ist. Nach Löschung des Kontos werden alle Daten innerhalb von 30 Tagen entfernt.

6. Ihre Rechte
Sie haben das Recht auf Auskunft, Berichtigung, Löschung und Einschränkung der Verarbeitung Ihrer Daten. Kontakt: datenschutz@scoon.app

7. Cookies & Tracking
Die App verwendet keine Werbe-Cookies. Anonyme Nutzungsstatistiken dienen ausschließlich der App-Verbesserung.
"""

    static let terms = """
Nutzungsbedingungen

Zuletzt aktualisiert: März 2026

1. Geltungsbereich
Diese Nutzungsbedingungen gelten für die Nutzung der scoon-App.

2. Leistungsbeschreibung
scoon ist eine Plattform zur Entdeckung und Teilen von Foto-Spots. Nutzer können Orte erstellen, bewerten und als Favoriten speichern.

3. Nutzerkonto
- Sie müssen mindestens 13 Jahre alt sein
- Ein Konto pro Person ist erlaubt
- Sie sind für die Sicherheit Ihres Passworts verantwortlich

4. Inhalte
- Sie behalten das Urheberrecht an Ihren hochgeladenen Fotos
- Durch das Hochladen erteilen Sie scoon eine nicht-exklusive Lizenz zur Darstellung
- Verboten sind: illegale, diskriminierende oder urheberrechtsverletzende Inhalte

5. Creator-Programm
Creator verdienen Einnahmen basierend auf Views und Engagement ihrer Spots. Details regelt die Creator-Vereinbarung.

6. Haftung
scoon haftet nicht für Schäden, die durch die Nutzung von Informationen auf der Plattform entstehen.

7. Änderungen
Wir behalten uns vor, diese Bedingungen anzupassen. Wesentliche Änderungen werden per E-Mail mitgeteilt.

8. Kontakt
Fragen: support@scoon.app
"""

    static let imprint = """
Impressum

Angaben gemäß § 5 ECG (Österreich)

1. Unternehmensbezeichnung
scoon GmbH (in Gründung)

2. Adresse
Graz, Steiermark, Österreich

3. Kontakt
E-Mail: hello@scoon.app
Web: www.scoon.app

4. Unternehmensgegenstand
Entwicklung und Betrieb einer Plattform zur Entdeckung von Foto-Spots

5. Aufsichtsbehörde
Wirtschaftskammer Steiermark

6. Haftungshinweis
Trotz sorgfältiger inhaltlicher Kontrolle übernehmen wir keine Haftung für die Inhalte externer Links. Für den Inhalt der verlinkten Seiten sind ausschließlich deren Betreiber verantwortlich.

7. Urheberrecht
Die durch die Seitenbetreiber erstellten Inhalte und Werke auf diesen Seiten unterliegen dem österreichischen Urheberrecht.

Stand: März 2026
"""
}
