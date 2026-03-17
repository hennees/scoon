import SwiftUI

// Design: 209:165 – PlaceInfo
// Full-bleed image carousel, spot metadata, info section, map preview, bottom nav.
struct PlaceInfoScreen: View {
    let spot: Spot

    @Environment(AppRouter.self) private var router
    @State private var selectedTab  = NavTab.home
    @State private var currentImage = 0

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.scoonDark.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {

                    // ── Image carousel ────────────────────────────────
                    ZStack(alignment: .topLeading) {
                        GeometryReader { geo in
                            TabView(selection: $currentImage) {
                                AsyncImage(url: URL(string: spot.imageURL)) { phase in
                                    switch phase {
                                    case .success(let img): img.resizable().scaledToFill()
                                    default: Rectangle().fill(Color.white.opacity(0.06))
                                    }
                                }
                                .tag(0)
                            }
                            .tabViewStyle(.page(indexDisplayMode: .never))
                            .frame(width: geo.size.width, height: geo.size.width * 1.5)
                        }
                        .aspectRatio(2/3, contentMode: .fit)
                        .clipped()

                        // scoon logo
                        Text("scoon")
                            .font(.system(size: 28, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.top, 51)
                            .padding(.leading, 20)

                        // Top overlay: back + share
                        HStack {
                            Button(action: { router.navigateBack() }) {
                                ZStack {
                                    Circle()
                                        .fill(.ultraThinMaterial)
                                        .environment(\.colorScheme, .dark)
                                        .frame(width: 38, height: 38)
                                    Image(systemName: "arrow.left")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.white)
                                }
                            }
                            .padding(.top, 100)
                            .padding(.leading, 20)

                            Spacer()

                            Button(action: { shareSpot() }) {
                                ZStack {
                                    Circle()
                                        .fill(.ultraThinMaterial)
                                        .environment(\.colorScheme, .dark)
                                        .frame(width: 38, height: 38)
                                    Image(systemName: "square.and.arrow.up")
                                        .font(.system(size: 15))
                                        .foregroundColor(.white)
                                }
                            }
                            .padding(.top, 100)
                            .padding(.trailing, 20)
                        }

                        // Gradient overlay at bottom of image
                        VStack {
                            Spacer()
                            LinearGradient(
                                colors: [.clear, Color.scoonDark.opacity(0.8)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                            .frame(height: 120)
                        }
                    }

                    // ── Name + Favourite ──────────────────────────────
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(spot.name)
                                .font(.system(size: 30, weight: .bold))
                                .foregroundColor(.white)
                            Text(spot.location)
                                .font(.system(size: 14))
                                .foregroundColor(Color.scoonTextSecondary)
                        }
                        Spacer()
                        ZStack {
                            Circle()
                                .fill(.ultraThinMaterial)
                                .environment(\.colorScheme, .dark)
                                .frame(width: 42, height: 42)
                            Image(systemName: spot.isFavorite ? "heart.fill" : "heart")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(spot.isFavorite ? Color.scoonOrange : .white)
                        }
                        .padding(.top, 4)
                    }
                    .padding(.horizontal, 18)
                    .padding(.top, 18)

                    // ── Stats row ─────────────────────────────────────
                    HStack(spacing: 16) {
                        HStack(spacing: 5) {
                            Image(systemName: "star.fill")
                                .font(.system(size: 13))
                                .foregroundColor(Color.scoonOrange)
                            Text(String(format: "%.1f", spot.rating))
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.white)
                        }
                        HStack(spacing: 5) {
                            Image(systemName: "eye")
                                .font(.system(size: 12))
                                .foregroundColor(Color.scoonTextSecondary)
                            Text("\(spot.viewCount) Views")
                                .font(.system(size: 12))
                                .foregroundColor(Color.scoonTextSecondary)
                        }
                        HStack(spacing: 5) {
                            Image(systemName: "heart")
                                .font(.system(size: 12))
                                .foregroundColor(Color.scoonTextSecondary)
                            Text("\(spot.likeCount)")
                                .font(.system(size: 12))
                                .foregroundColor(Color.scoonTextSecondary)
                        }
                        Spacer()
                        // Category badge
                        Text(spot.category.rawValue)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(Color.scoonOrange)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Color.scoonOrange.opacity(0.12))
                            .clipShape(Capsule())
                    }
                    .padding(.horizontal, 18)
                    .padding(.top, 10)

                    // ── Karte button ──────────────────────────────────
                    HStack {
                        Spacer()
                        Button(action: { router.navigate(to: .kartenansicht) }) {
                            HStack(spacing: 8) {
                                Text("Auf der Karte")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.white)
                                Image(systemName: "map.fill")
                                    .font(.system(size: 14))
                                    .foregroundColor(.white)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(Color.scoonOrange)
                            .cornerRadius(10)
                        }
                    }
                    .padding(.horizontal, 18)
                    .padding(.top, 12)

                    // ── Info section ──────────────────────────────────
                    Text("Info")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(Color.scoonOrange)
                        .padding(.horizontal, 18)
                        .padding(.top, 24)

                    Rectangle()
                        .fill(Color.scoonOrange)
                        .frame(width: 28, height: 3)
                        .cornerRadius(2)
                        .padding(.horizontal, 18)
                        .padding(.top, 4)

                    Text(spot.description)
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(Color.scoonTextSecondary)
                        .lineSpacing(5)
                        .padding(.horizontal, 18)
                        .padding(.top, 12)

                    // ── Photo tips ────────────────────────────────────
                    HStack(spacing: 12) {
                        SpotTipCard(icon: "sun.max.fill",    title: "Bestes Licht",  value: "Goldene Stunde")
                        SpotTipCard(icon: "camera.aperture", title: "Kategorie",     value: spot.category.rawValue)
                        SpotTipCard(icon: "bookmark.fill",   title: "Saves",         value: "\(spot.saveCount)")
                    }
                    .padding(.horizontal, 18)
                    .padding(.top, 20)

                    Spacer().frame(height: 100)
                }
            }

            NavBarView(selectedTab: $selectedTab)
        }
        .navigationBarHidden(true)
    }

    private func shareSpot() {
        let text = "Schau dir \(spot.name) auf scoon an! \(spot.location)"
        let av = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let root = scene.windows.first?.rootViewController {
            root.present(av, animated: true)
        }
    }
}

// MARK: – Tip Card

private struct SpotTipCard: View {
    let icon: String
    let title: String
    let value: String

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(Color.scoonOrange)
            Text(title)
                .font(.system(size: 10))
                .foregroundColor(Color.scoonTextSecondary)
            Text(value)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.06))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                )
        )
    }
}
