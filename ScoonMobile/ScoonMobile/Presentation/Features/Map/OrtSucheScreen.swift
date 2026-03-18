import SwiftUI

// Design: 557:424 – Ort Suche
// Dark top + light bottom sheet with city list grouped by country.
struct OrtSucheScreen: View {
    @Environment(AppRouter.self) private var router

    @State private var searchText = ""

    private let cities: [(country: String, list: [String])] = [
        ("Österreich", ["Wien", "Graz", "Linz", "Salzburg", "Innsbruck"]),
        ("Deutschland", ["Hamburg", "Frankfurt"]),
        ("Schweiz",    ["Zürich"]),
    ]

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.scoonDarker.ignoresSafeArea()

            // Bottom sheet
            VStack(alignment: .leading, spacing: 0) {
                // Drag handle
                Capsule()
                    .fill(Color.scoonTextSecondary.opacity(0.4))
                    .frame(width: 36, height: 4)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 10)
                    .padding(.bottom, 4)

                // Close + title row
                HStack {
                    Button(action: { router.navigateBack() }) {
                        Text("Schließen")
                            .font(.system(size: 15))
                            .foregroundColor(Color.scoonTextSecondary)
                    }
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 6)

                Text("Stadt wählen")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Color.scoonDarker)
                    .padding(.horizontal, 20)
                    .padding(.top, 14)

                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(Color.scoonTextSecondary)
                    TextField("Suchen", text: $searchText)
                        .font(.system(size: 15))
                        .foregroundColor(Color.scoonDarker)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(Color.white)
                .cornerRadius(10)
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.scoonBorder, lineWidth: 1))
                .padding(.horizontal, 20)
                .padding(.top, 14)

                // In der Nähe
                CityRow(name: "In der Nähe", icon: "location.fill") {
                    router.navigateBack()
                }
                .padding(.top, 10)

                // Grouped city list
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(filteredCities, id: \.country) { group in
                            Text(group.country)
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(Color.scoonTextSecondary)
                                .padding(.horizontal, 20)
                                .padding(.top, 16)
                                .padding(.bottom, 4)

                            ForEach(group.list, id: \.self) { city in
                                CityRow(name: city, icon: "mappin") {
                                    router.navigateBack()
                                }
                                if city != group.list.last {
                                    Divider()
                                        .padding(.leading, 52)
                                }
                            }
                        }
                    }
                    .padding(.bottom, 40)
                }
            }
            .background(Color.scoonCardLight)
            .cornerRadius(24, corners: [.topLeft, .topRight])
            .frame(maxHeight: .infinity)
        }
        .toolbar(.hidden, for: .navigationBar)
    }

    private var filteredCities: [(country: String, list: [String])] {
        guard !searchText.isEmpty else { return cities }
        return cities.compactMap { group in
            let filtered = group.list.filter { $0.localizedCaseInsensitiveContains(searchText) }
            return filtered.isEmpty ? nil : (group.country, filtered)
        }
    }
}

private struct CityRow: View {
    let name: String
    let icon: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(Color.scoonOrange)
                    .frame(width: 24)
                    .padding(.leading, 16)
                Text(name)
                    .font(.system(size: 16))
                    .foregroundColor(Color.scoonDarker)
                Spacer()
            }
            .padding(.vertical, 14)
        }
    }
}

// cornerRadius(_:corners:) is defined in Core/Extensions/View+RoundedCorners.swift
