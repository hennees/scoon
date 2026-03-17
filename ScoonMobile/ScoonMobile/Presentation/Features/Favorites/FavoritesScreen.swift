import SwiftUI

// Design: 304:204 – Favorites / Meine Orte
// Two tabs (Meine Favoriten / Meine Orte), sort+map buttons, scrollable spot list.
struct FavoritesScreen: View {
    @Environment(AppRouter.self) private var router

    @State private var selectedTab    = NavTab.favorites
    @State private var activeListTab  = 0  // 0 = Meine Favoriten, 1 = Meine Orte

    private let favoriteSpots: [FavoriteSpot] = [
        FavoriteSpot(name: "Murinsel",    description: "Eine schwimmende Plattform auf der Mur – modernes Design trifft urbanes Erlebnis.", location: "Graz, Austria", imageURL: "https://www.figma.com/api/mcp/asset/4c92510c-b715-4ba9-b560-fb389c098aad",  isFavorite: true),
        FavoriteSpot(name: "Stadtpark",   description: "Ruhige Grünanlage im Herzen der Stadt mit wunderschönen alten Bäumen.", location: "Graz, Austria", imageURL: "https://www.figma.com/api/mcp/asset/5c2eff61-1398-46d1-b246-219c24477e45", isFavorite: true),
        FavoriteSpot(name: "Schlossberg", description: "Der markante Hausberg von Graz mit Uhrturm und Panoramablick über die Stadt.", location: "Graz, Austria", imageURL: "https://www.figma.com/api/mcp/asset/ad0ee92b-65cd-4acb-804a-51f27ccd4685", isFavorite: true),
    ]

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.scoonDarker.ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("scoon")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    Spacer()
                    HStack(spacing: 16) {
                        Button(action: {}) {
                            Image(systemName: "bell")
                                .font(.system(size: 20))
                                .foregroundColor(.white)
                        }
                        Button(action: { router.navigate(to: .settings) }) {
                            Image(systemName: "gearshape")
                                .font(.system(size: 20))
                                .foregroundColor(.white)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 56)

                Text("Meine Orte")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                    .padding(.top, 16)

                // Tabs
                HStack(spacing: 0) {
                    TabButton(title: "Meine Favoriten", isActive: activeListTab == 0) {
                        activeListTab = 0
                    }
                    TabButton(title: "Meine Orte", isActive: activeListTab == 1) {
                        activeListTab = 1
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)

                // Sort + Map row
                HStack(spacing: 10) {
                    Button(action: {}) {
                        HStack(spacing: 6) {
                            Image(systemName: "arrow.up.arrow.down")
                                .font(.system(size: 12))
                            Text("Sort by: Latest")
                                .font(.system(size: 13))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(Color.scoonDark)
                        .cornerRadius(8)
                    }
                    Button(action: { router.navigate(to: .kartenansicht) }) {
                        HStack(spacing: 6) {
                            Image(systemName: "map")
                                .font(.system(size: 12))
                            Text("Kartenview")
                                .font(.system(size: 13))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(Color.scoonDark)
                        .cornerRadius(8)
                    }
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 14)

                // Spot list
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(favoriteSpots) { spot in
                            FavoriteSpotRow(spot: spot) {
                                router.navigate(to: .placeInfo)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 14)
                    .padding(.bottom, 100)
                }
            }

            NavBarView(selectedTab: $selectedTab)
        }
        .navigationBarHidden(true)
    }
}

private struct TabButton: View {
    let title: String
    let isActive: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Text(title)
                    .font(.system(size: 15, weight: isActive ? .semibold : .regular))
                    .foregroundColor(isActive ? Color.scoonOrange : Color.scoonTextSecondary)
                Rectangle()
                    .fill(isActive ? Color.scoonOrange : Color.clear)
                    .frame(height: 2)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

private struct FavoriteSpot: Identifiable {
    let id = UUID()
    let name: String
    let description: String
    let location: String
    let imageURL: String
    let isFavorite: Bool
}

private struct FavoriteSpotRow: View {
    let spot: FavoriteSpot
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(alignment: .top, spacing: 12) {
                AsyncImage(url: URL(string: spot.imageURL)) { phase in
                    switch phase {
                    case .success(let img): img.resizable().scaledToFill()
                    default: Rectangle().fill(Color.gray.opacity(0.3))
                    }
                }
                .frame(width: 80, height: 80)
                .clipShape(RoundedRectangle(cornerRadius: 12))

                VStack(alignment: .leading, spacing: 4) {
                    Text(spot.name)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)

                    Text(spot.description)
                        .font(.system(size: 13))
                        .foregroundColor(Color.scoonTextSecondary)
                        .lineLimit(2)

                    HStack(spacing: 4) {
                        Image(systemName: "mappin.and.ellipse")
                            .font(.system(size: 11))
                            .foregroundColor(Color.scoonTextSecondary)
                        Text(spot.location)
                            .font(.system(size: 12))
                            .foregroundColor(Color.scoonTextSecondary)
                    }
                    .padding(.top, 2)

                    Button(action: {}) {
                        Text("Auf der Karte anzeigen")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(Color.scoonOrange)
                    }
                    .padding(.top, 2)
                }

                Spacer()

                Image(systemName: spot.isFavorite ? "heart.fill" : "heart")
                    .foregroundColor(spot.isFavorite ? Color.scoonOrange : Color.scoonTextSecondary)
                    .font(.system(size: 18))
            }
            .padding(12)
            .background(Color.scoonDark)
            .cornerRadius(14)
        }
    }
}
