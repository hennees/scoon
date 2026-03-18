import SwiftUI
import MapKit

// Design: 387:934 – Kartenansicht Detail
// Map view with bottom sheet: horizontal spot cards + category filter row.
struct KartenansichtDetailScreen: View {
    @Environment(AppRouter.self)    private var router
    @Environment(AppContainer.self) private var container
    @State private var vm: MapViewModel?

    @State private var activeCategory: SpotCategory? = nil
    @State private var region = MKCoordinateRegion(
        center:     CLLocationCoordinate2D(latitude: 47.0707, longitude: 15.4395),
        latitudinalMeters:  2000,
        longitudinalMeters: 2000
    )

    private var filteredSpots: [Spot] {
        guard let vm else { return [] }
        guard let cat = activeCategory else { return vm.mappableSpots }
        return vm.mappableSpots.filter { $0.category == cat }
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            Map(coordinateRegion: $region)
                .ignoresSafeArea()

            // Bottom sheet
            VStack(spacing: 0) {
                // Drag handle
                Capsule()
                    .fill(Color.primary.opacity(0.3))
                    .frame(width: 36, height: 4)
                    .padding(.top, 10)
                    .padding(.bottom, 14)

                // Horizontal spot cards
                if let vm, vm.isLoading {
                    ProgressView().tint(Color.scoonOrange).padding(.vertical, 20)
                } else {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(filteredSpots) { spot in
                                NearbySpotCard(spot: spot) {
                                    router.navigate(to: .placeInfo(spot))
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                }

                // Category filter row
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        Button(action: { activeCategory = nil }) {
                            Text("Alle")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                .background(activeCategory == nil ? Color.scoonOrange : Color.black)
                                .clipShape(Capsule())
                        }
                        ForEach(SpotCategory.allCases, id: \.self) { cat in
                            Button(action: { activeCategory = cat }) {
                                Text(cat.rawValue)
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
        }
        .toolbar(.hidden, for: .navigationBar)
        .task {
            let viewModel = container.makeMapViewModel()
            vm = viewModel
            await viewModel.load()
        }
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
                    default: Rectangle().fill(Color.primary.opacity(0.06))
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
