import SwiftUI
import MapKit

// Design: 377:447 – Kartenansicht
// Map view with colored pins, search bar, orange FAB, bottom nav.
struct KartenansichtScreen: View {
    @Environment(AppRouter.self) private var router

    @State private var selectedTab = NavTab.map
    @State private var searchText  = ""
    @State private var region      = MKCoordinateRegion(
        center:     CLLocationCoordinate2D(latitude: 47.0707, longitude: 15.4395),
        latitudinalMeters:  2000,
        longitudinalMeters: 2000
    )

    private let pins: [(coord: CLLocationCoordinate2D, color: Color, count: Int)] = [
        (CLLocationCoordinate2D(latitude: 47.0707, longitude: 15.4395), .yellow,  2),
        (CLLocationCoordinate2D(latitude: 47.075,  longitude: 15.432),  .pink,    2),
        (CLLocationCoordinate2D(latitude: 47.065,  longitude: 15.445),  Color.scoonOrange, 3),
    ]

    var body: some View {
        ZStack(alignment: .bottom) {
            // Map
            Map(coordinateRegion: $region, annotationItems: pins.indices.map { i in PinItem(id: i, coord: pins[i].coord, color: pins[i].color, count: pins[i].count) }) { pin in
                MapAnnotation(coordinate: pin.coord) {
                    MapPinView(color: pin.color, count: pin.count)
                }
            }
            .ignoresSafeArea()

            // Search bar overlay at top
            VStack(spacing: 0) {
                HStack(spacing: 12) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(Color.scoonOrange)
                            .font(.system(size: 16))
                        TextField("Suche nach Orten", text: $searchText)
                            .font(.system(size: 15))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .background(Color.scoonDark)
                    .cornerRadius(12)
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.scoonOrange.opacity(0.5), lineWidth: 1))
                }
                .padding(.horizontal, 16)
                .padding(.top, 56)

                Spacer()

                // Orange FAB bottom-left
                HStack {
                    Button(action: { router.navigate(to: .addPhotoSpot) }) {
                        ZStack {
                            Circle()
                                .fill(Color.scoonOrange)
                                .frame(width: 56, height: 56)
                                .shadow(color: Color.scoonOrange.opacity(0.5), radius: 10, x: 0, y: 4)
                            Image(systemName: "plus")
                                .font(.system(size: 24, weight: .medium))
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.leading, 20)
                    .padding(.bottom, 100)
                    Spacer()
                }
            }

            NavBarView(selectedTab: $selectedTab)
        }
        .navigationBarHidden(true)
    }
}

private struct PinItem: Identifiable {
    let id: Int
    let coord: CLLocationCoordinate2D
    let color: Color
    let count: Int
}

private struct MapPinView: View {
    let color: Color
    let count: Int

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(color)
                    .frame(width: 40, height: 30)
                Text("\(count)")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
            }
            Triangle()
                .fill(color)
                .frame(width: 12, height: 8)
        }
    }
}

private struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.closeSubpath()
        return path
    }
}
