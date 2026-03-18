import SwiftUI
import MapKit

// Design: 387:934 – Kartenansicht Detail
// Map view with bottom sheet: horizontal spot cards + category filter row.
struct KartenansichtDetailScreen: View {
    @Environment(AppRouter.self) private var router

    @State private var selectedTab     = NavTab.map
    @State private var activeCategory  = "Park & Garten"
    @State private var region          = MKCoordinateRegion(
        center:     CLLocationCoordinate2D(latitude: 47.0707, longitude: 15.4395),
        latitudinalMeters:  2000,
        longitudinalMeters: 2000
    )

    private let categories = ["Park & Garten", "Ausstellungen", "Denkmäler"]

    private let nearbySpots: [Spot] = [
        Spot(id: UUID(), name: "Uhrturm",     location: "Graz, Austria", rating: 4.7,
             imageURL: "https://www.figma.com/api/mcp/asset/4c92510c-b715-4ba9-b560-fb389c098aad",
             isFavorite: false, description: "Der Uhrturm ist das Wahrzeichen von Graz.",
             viewCount: 980, likeCount: 310, saveCount: 140, distance: "0.3 km", category: .monuments,
             latitude: 47.0726, longitude: 15.4387),
        Spot(id: UUID(), name: "Haker-Löwe",  location: "Graz, Austria", rating: 4.5,
             imageURL: "https://www.figma.com/api/mcp/asset/5c2eff61-1398-46d1-b246-219c24477e45",
             isFavorite: false, description: "Historisches Stadtzentrum mit beeindruckender Architektur.",
             viewCount: 420, likeCount: 180, saveCount: 60, distance: "0.7 km", category: .architecture,
             latitude: 47.0708, longitude: 15.4386),
        Spot(id: UUID(), name: "Blumenwiese", location: "Graz, Austria", rating: 4.3,
             imageURL: "https://www.figma.com/api/mcp/asset/ad0ee92b-65cd-4acb-804a-51f27ccd4685",
             isFavorite: false, description: "Wunderschöne Wiese ideal für Naturfotos.",
             viewCount: 210, likeCount: 95, saveCount: 38, distance: "1.2 km", category: .nature,
             latitude: 47.0749, longitude: 15.4415),
    ]

    var body: some View {
        ZStack(alignment: .bottom) {
            Map(coordinateRegion: $region)
                .ignoresSafeArea()

            // Bottom sheet
            VStack(spacing: 0) {
                // Drag handle
                Capsule()
                    .fill(Color.white.opacity(0.3))
                    .frame(width: 36, height: 4)
                    .padding(.top, 10)
                    .padding(.bottom, 14)

                // Horizontal spot cards
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(nearbySpots) { spot in
                            NearbySpotCard(spot: spot) {
                                router.navigate(to: .placeInfo(spot))
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                }

                // Category filter row
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(categories, id: \.self) { cat in
                            Button(action: { activeCategory = cat }) {
                                Text(cat)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 10)
                                    .background(activeCategory == cat ? Color.scoonOrange : Color.black)
                                    .clipShape(Capsule())
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 14)
                    .padding(.bottom, 8)
                }
            }
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.scoonDark)
            )
            .padding(.bottom, 80)

            NavBarView(selectedTab: $selectedTab)
        }
        .navigationBarHidden(true)
    }
}

private struct NearbySpotCard: View {
    let spot: Spot
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            ZStack(alignment: .bottomLeading) {
                AsyncImage(url: URL(string: spot.imageURL)) { phase in
                    switch phase {
                    case .success(let img): img.resizable().scaledToFill()
                    default: Rectangle().fill(Color.white.opacity(0.06))
                    }
                }
                .frame(width: 140, height: 110)
                .clipShape(RoundedRectangle(cornerRadius: 14))

                LinearGradient(
                    colors: [.clear, .black.opacity(0.65)],
                    startPoint: .top, endPoint: .bottom
                )
                .clipShape(RoundedRectangle(cornerRadius: 14))

                VStack(alignment: .leading, spacing: 2) {
                    Text(spot.name)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.white)
                    if let distance = spot.distance {
                        Text(distance)
                            .font(.system(size: 11))
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
                .padding(.horizontal, 8)
                .padding(.bottom, 8)
            }
        }
        .buttonStyle(.plain)
    }
}
