import SwiftUI

// Design: 209:165 – PlaceInfo
// Full-bleed image carousel, spot metadata, info section, map preview, bottom nav.
struct PlaceInfoScreen: View {
    @Environment(AppRouter.self) private var router

    @State private var selectedTab     = NavTab.home
    @State private var currentImage    = 0

    private let placeImages = [
        "https://www.figma.com/api/mcp/asset/17d6f519-4c00-4270-afde-da5c2e79392e",
        "https://www.figma.com/api/mcp/asset/63b80154-86c3-4c88-a421-bc005da2fe1d",
        "https://www.figma.com/api/mcp/asset/447286b9-211c-47e1-8472-ecebfb714bcd",
        "https://www.figma.com/api/mcp/asset/cb4029e0-21ac-4ac3-a194-74ad17dd1290",
    ]

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.scoonDark.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    // Image carousel (full-width, swipeable)
                    ZStack(alignment: .topLeading) {
                        GeometryReader { geo in
                            TabView(selection: $currentImage) {
                                ForEach(placeImages.indices, id: \.self) { i in
                                    AsyncImage(url: URL(string: placeImages[i])) { phase in
                                        switch phase {
                                        case .success(let img):
                                            img.resizable().scaledToFill()
                                        default:
                                            Rectangle().fill(Color.gray.opacity(0.3))
                                        }
                                    }
                                    .tag(i)
                                }
                            }
                            .tabViewStyle(.page(indexDisplayMode: .never))
                            .frame(width: geo.size.width, height: geo.size.width * 1.5)
                        }
                        .aspectRatio(2/3, contentMode: .fit)
                        .clipped()

                        // Top overlay: logo + back + share
                        HStack {
                            // Back button
                            Button(action: { router.navigateBack() }) {
                                Image(systemName: "arrow.left")
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(Color.scoonOrange)
                                    .frame(width: 30, height: 30)
                            }
                            .padding(.top, 104)
                            .padding(.leading, 20)

                            Spacer()

                            // Share button
                            Button(action: {}) {
                                Image(systemName: "square.and.arrow.up")
                                    .font(.system(size: 18))
                                    .foregroundColor(.white)
                                    .frame(width: 24, height: 24)
                            }
                            .padding(.top, 110)
                            .padding(.trailing, 20)
                        }

                        // scoon logo
                        Text("scoon")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.top, 51)
                            .padding(.leading, 20)
                    }

                    // Place name + favourite
                    HStack(alignment: .top) {
                        Text("Murinsel")
                            .font(.system(size: 30, weight: .medium))
                            .foregroundColor(.white)
                        Spacer()
                        Image(systemName: "heart.fill")
                            .font(.system(size: 18))
                            .foregroundColor(Color.scoonOrange)
                            .padding(.top, 6)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)

                    // Location
                    Text("Graz, Austria")
                        .font(.system(size: 14))
                        .foregroundColor(Color.scoonTextSecondary)
                        .padding(.horizontal, 18)
                        .padding(.top, 4)

                    // Rating row
                    HStack(spacing: 6) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 14))
                            .foregroundColor(Color.scoonOrange)
                        Text("4.8     135 Bewertungen")
                            .font(.system(size: 12))
                            .foregroundColor(Color.scoonOrange)

                        Spacer()

                        Image(systemName: "eye")
                            .font(.system(size: 12))
                            .foregroundColor(Color.scoonOrange)
                        Text("1420 Views")
                            .font(.system(size: 12))
                            .foregroundColor(Color.scoonOrange)
                    }
                    .padding(.horizontal, 17)
                    .padding(.top, 4)

                    // Karte button
                    HStack {
                        Spacer()
                        Button(action: {}) {
                            HStack(spacing: 8) {
                                Text("Karte")
                                    .font(.system(size: 14))
                                    .foregroundColor(Color.scoonTextSecondary)
                                Image(systemName: "map")
                                    .font(.system(size: 16))
                                    .foregroundColor(.white)
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .background(Color.scoonOrange)
                            .cornerRadius(10)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)

                    // Info section
                    Text("Info")
                        .font(.system(size: 30))
                        .foregroundColor(Color.scoonOrange)
                        .padding(.horizontal, 16)
                        .padding(.top, 20)

                    Text(
                        "Die Murinsel ist ein architektonisches Highlight inmitten der Stadt Graz – " +
                        "eine schwimmende Plattform auf der Mur, die modernes Design mit urbanem " +
                        "Erlebnis vereint..."
                    )
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(Color.scoonTextSecondary)
                    .tracking(0.09)
                    .padding(.horizontal, 17)
                    .padding(.top, 10)

                    // Map section
                    Text("Map")
                        .font(.system(size: 30))
                        .foregroundColor(Color.scoonOrange)
                        .padding(.horizontal, 16)
                        .padding(.top, 24)

                    AsyncImage(
                        url: URL(string: "https://www.figma.com/api/mcp/asset/da75412e-221f-4c60-a9bf-de2aebbd2378")
                    ) { phase in
                        switch phase {
                        case .success(let img):
                            img.resizable().scaledToFill()
                        default:
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .overlay(
                                    Image(systemName: "map")
                                        .font(.system(size: 40))
                                        .foregroundColor(.white.opacity(0.3))
                                )
                        }
                    }
                    .frame(height: 103)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal, 17)
                    .padding(.top, 10)

                    // Padding above nav bar
                    Spacer().frame(height: 100)
                }
            }

            // Bottom nav
            NavBarView(selectedTab: $selectedTab)
        }
        .navigationBarHidden(true)
    }
}
