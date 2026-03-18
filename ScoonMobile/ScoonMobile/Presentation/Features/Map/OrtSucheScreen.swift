import SwiftUI

extension Notification.Name {
    static let mapCitySelected = Notification.Name("scoon.mapCitySelected")
}

// Design: 557:424 – Ort Suche (dark redesign)
struct OrtSucheScreen: View {
    @Environment(AppRouter.self) private var router

    @State private var searchText = ""
    @State private var appeared   = false

    private let cities: [(country: String, list: [String])] = [
        ("Österreich", ["Wien", "Graz", "Linz", "Salzburg", "Innsbruck"]),
        ("Deutschland", ["Hamburg", "Frankfurt", "Berlin", "München"]),
        ("Schweiz",    ["Zürich", "Basel", "Bern"]),
    ]

    private let cityCoordinates: [String: (Double, Double)] = [
        "Wien":      (48.2082, 16.3738),
        "Graz":      (47.0707, 15.4395),
        "Linz":      (48.3069, 14.2858),
        "Salzburg":  (47.8095, 13.0550),
        "Innsbruck": (47.2692, 11.4041),
        "Hamburg":   (53.5511,  9.9937),
        "Frankfurt": (50.1109,  8.6821),
        "Berlin":    (52.5200, 13.4050),
        "München":   (48.1351, 11.5820),
        "Zürich":    (47.3769,  8.5417),
        "Basel":     (47.5596,  7.5886),
        "Bern":      (46.9480,  7.4474),
    ]

    var body: some View {
        ZStack(alignment: .top) {
            Color.scoonDarker.ignoresSafeArea()

            // Subtle top glow
            RadialGradient(
                colors: [Color.scoonOrange.opacity(0.1), .clear],
                center: .top,
                startRadius: 0,
                endRadius: 300
            )
            .ignoresSafeArea()
            .allowsHitTesting(false)

            VStack(alignment: .leading, spacing: 0) {

                // ── Header ─────────────────────────────────────────
                HStack(alignment: .center) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("ENTDECKEN")
                            .font(.system(size: 11, weight: .semibold))
                            .tracking(2)
                            .foregroundColor(Color.scoonOrange.opacity(0.8))
                        Text("Stadt wählen")
                            .font(.system(size: 26, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                    }
                    Spacer()
                    Button(action: { router.navigateBack() }) {
                        ZStack {
                            Circle()
                                .fill(Color.white.opacity(0.08))
                                .overlay(Circle().stroke(Color.white.opacity(0.1), lineWidth: 1))
                                .frame(width: 40, height: 40)
                            Image(systemName: "xmark")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white.opacity(0.7))
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 60)
                .padding(.bottom, 20)
                .opacity(appeared ? 1 : 0)
                .animation(.easeOut(duration: 0.4), value: appeared)

                // ── Search bar ─────────────────────────────────────
                HStack(spacing: 10) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.white.opacity(0.4))
                    TextField(
                        "",
                        text: $searchText,
                        prompt: Text("Stadt suchen…").foregroundColor(.white.opacity(0.3))
                    )
                    .font(.system(size: 15))
                    .foregroundColor(.white)
                    .tint(Color.scoonOrange)
                    if !searchText.isEmpty {
                        Button(action: { searchText = "" }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.white.opacity(0.4))
                        }
                    }
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 13)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color.white.opacity(0.06))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
                .padding(.horizontal, 20)
                .opacity(appeared ? 1 : 0)
                .animation(.easeOut(duration: 0.4).delay(0.05), value: appeared)

                // ── In der Nähe ────────────────────────────────────
                Button(action: {
                    NotificationCenter.default.post(name: .mapCitySelected, object: nil)
                    router.navigateBack()
                }) {
                    HStack(spacing: 14) {
                        ZStack {
                            Circle()
                                .fill(Color.scoonOrange.opacity(0.15))
                                .frame(width: 40, height: 40)
                            Image(systemName: "location.fill")
                                .font(.system(size: 16))
                                .foregroundColor(Color.scoonOrange)
                        }
                        VStack(alignment: .leading, spacing: 2) {
                            Text("In der Nähe")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.white)
                            Text("Meinen Standort verwenden")
                                .font(.system(size: 12))
                                .foregroundColor(.white.opacity(0.45))
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.white.opacity(0.25))
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 14)
                }
                .buttonStyle(.plain)
                .padding(.top, 10)
                .opacity(appeared ? 1 : 0)
                .animation(.easeOut(duration: 0.4).delay(0.08), value: appeared)

                // Divider
                Rectangle()
                    .fill(Color.white.opacity(0.06))
                    .frame(height: 1)
                    .padding(.horizontal, 20)
                    .padding(.top, 4)

                // ── City list ──────────────────────────────────────
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(Array(filteredCities.enumerated()), id: \.element.country) { groupIdx, group in
                            // Country header
                            Text(group.country.uppercased())
                                .font(.system(size: 11, weight: .semibold))
                                .tracking(1.5)
                                .foregroundColor(.white.opacity(0.35))
                                .padding(.horizontal, 20)
                                .padding(.top, 22)
                                .padding(.bottom, 6)

                            // Cities
                            VStack(spacing: 0) {
                                ForEach(Array(group.list.enumerated()), id: \.element) { idx, city in
                                    Button(action: {
                                        if let coord = cityCoordinates[city] {
                                            NotificationCenter.default.post(
                                                name: .mapCitySelected,
                                                object: nil,
                                                userInfo: ["lat": coord.0, "lon": coord.1]
                                            )
                                        }
                                        router.navigateBack()
                                    }) {
                                        HStack(spacing: 14) {
                                            ZStack {
                                                Circle()
                                                    .fill(Color.white.opacity(0.06))
                                                    .frame(width: 36, height: 36)
                                                Image(systemName: "mappin")
                                                    .font(.system(size: 14, weight: .medium))
                                                    .foregroundColor(.white.opacity(0.5))
                                            }
                                            Text(city)
                                                .font(.system(size: 16, weight: .medium))
                                                .foregroundColor(.white)
                                            Spacer()
                                            Image(systemName: "chevron.right")
                                                .font(.system(size: 12, weight: .semibold))
                                                .foregroundColor(.white.opacity(0.2))
                                        }
                                        .padding(.horizontal, 20)
                                        .padding(.vertical, 13)
                                    }
                                    .buttonStyle(.plain)

                                    if idx < group.list.count - 1 {
                                        Rectangle()
                                            .fill(Color.white.opacity(0.05))
                                            .frame(height: 1)
                                            .padding(.leading, 70)
                                    }
                                }
                            }
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.white.opacity(0.04))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.white.opacity(0.07), lineWidth: 1)
                            )
                            .padding(.horizontal, 20)
                            .opacity(appeared ? 1 : 0)
                            .animation(.easeOut(duration: 0.4).delay(0.1 + Double(groupIdx) * 0.06), value: appeared)
                        }
                    }
                    .padding(.bottom, 50)
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) { appeared = true }
        }
    }

    private var filteredCities: [(country: String, list: [String])] {
        guard !searchText.isEmpty else { return cities }
        return cities.compactMap { group in
            let filtered = group.list.filter { $0.localizedCaseInsensitiveContains(searchText) }
            return filtered.isEmpty ? nil : (group.country, filtered)
        }
    }
}

// cornerRadius(_:corners:) is defined in Core/Extensions/View+RoundedCorners.swift
