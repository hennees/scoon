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

    private let nearbySpots: [NearbySpot] = [
        NearbySpot(name: "Uhrturm",      distance: "0.3 km", imageURL: "https://www.figma.com/api/mcp/asset/4c92510c-b715-4ba9-b560-fb389c098aad"),
        NearbySpot(name: "Haker-Löwe",   distance: "0.7 km", imageURL: "https://www.figma.com/api/mcp/asset/5c2eff61-1398-46d1-b246-219c24477e45"),
        NearbySpot(name: "Blumenwiese",  distance: "1.2 km", imageURL: "https://www.figma.com/api/mcp/asset/ad0ee92b-65cd-4acb-804a-51f27ccd4685"),
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
                                router.navigate(to: .placeInfo)
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

private struct NearbySpot: Identifiable {
    let id = UUID()
    let name: String
    let distance: String
    let imageURL: String
}

private struct NearbySpotCard: View {
    let spot: NearbySpot
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            ZStack(alignment: .bottomLeading) {
                AsyncImage(url: URL(string: spot.imageURL)) { phase in
                    switch phase {
                    case .success(let img): img.resizable().scaledToFill()
                    default: Rectangle().fill(Color.gray.opacity(0.3))
                    }
                }
                .frame(width: 140, height: 110)
                .clipShape(RoundedRectangle(cornerRadius: 14))

                VStack(alignment: .leading, spacing: 2) {
                    Text(spot.name)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.white)
                    Text(spot.distance)
                        .font(.system(size: 11))
                        .foregroundColor(.white.opacity(0.7))
                }
                .padding(.horizontal, 8)
                .padding(.bottom, 8)
            }
        }
    }
}
