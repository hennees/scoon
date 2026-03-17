import SwiftUI

// Design: 453:453 – Profile
// Dark, circular avatar, name, bio, stats, edit button, photo grid, NavBar.
struct ProfileScreen: View {
    @Environment(AppRouter.self) private var router

    @State private var selectedTab      = NavTab.profile
    @State private var activeListTab    = 0  // 0 = Erkundigt, 1 = Gespeichert

    private let gridImages: [String] = [
        "https://www.figma.com/api/mcp/asset/4c92510c-b715-4ba9-b560-fb389c098aad",
        "https://www.figma.com/api/mcp/asset/5c2eff61-1398-46d1-b246-219c24477e45",
        "https://www.figma.com/api/mcp/asset/ad0ee92b-65cd-4acb-804a-51f27ccd4685",
        "https://www.figma.com/api/mcp/asset/cb4029e0-21ac-4ac3-a194-74ad17dd1290",
        "https://www.figma.com/api/mcp/asset/17d6f519-4c00-4270-afde-da5c2e79392e",
        "https://www.figma.com/api/mcp/asset/63b80154-86c3-4c88-a421-bc005da2fe1d",
    ]

    private let gridColumns = [
        GridItem(.flexible(), spacing: 2),
        GridItem(.flexible(), spacing: 2),
        GridItem(.flexible(), spacing: 2),
    ]

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.scoonDarker.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 0) {
                    // Header
                    HStack {
                        Button(action: { router.navigateBack() }) {
                            Image(systemName: "arrow.left")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(Color.scoonOrange)
                        }
                        Spacer()
                        Button(action: { router.navigate(to: .settings) }) {
                            Image(systemName: "gearshape")
                                .font(.system(size: 20))
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 56)

                    // Avatar
                    Circle()
                        .fill(Color.scoonDark)
                        .frame(width: 90, height: 90)
                        .overlay(
                            AsyncImage(url: URL(string: "https://www.figma.com/api/mcp/asset/4c92510c-b715-4ba9-b560-fb389c098aad")) { phase in
                                switch phase {
                                case .success(let img): img.resizable().scaledToFill()
                                default: Image(systemName: "person.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(Color.scoonTextSecondary)
                                }
                            }
                            .clipShape(Circle())
                        )
                        .padding(.top, 20)

                    // Name
                    Text("Patrick Hennes")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.top, 12)

                    // Bio
                    Text("Fotograf & Entdecker aus Graz. Immer auf der Suche nach dem perfekten Spot.")
                        .font(.system(size: 14))
                        .foregroundColor(Color.scoonTextSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                        .padding(.top, 6)

                    // Stats row
                    HStack(spacing: 0) {
                        StatItem(value: "12", label: "Beiträge")
                        Divider().frame(height: 30).background(Color.scoonDark)
                        StatItem(value: "612", label: "Abonnenten")
                        Divider().frame(height: 30).background(Color.scoonDark)
                        StatItem(value: "124", label: "Abonniert")
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)

                    // Edit profile button
                    Button(action: {}) {
                        Text("Profil bearbeiten")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(Color.scoonOrange)
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.scoonOrange, lineWidth: 1.5))
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)

                    // Tab bar
                    HStack(spacing: 0) {
                        ProfileTabButton(title: "Erkundigt", isActive: activeListTab == 0) {
                            activeListTab = 0
                        }
                        ProfileTabButton(title: "Gespeichert", isActive: activeListTab == 1) {
                            activeListTab = 1
                        }
                    }
                    .padding(.top, 16)

                    // Photo grid
                    LazyVGrid(columns: gridColumns, spacing: 2) {
                        ForEach(gridImages.indices, id: \.self) { i in
                            AsyncImage(url: URL(string: gridImages[i])) { phase in
                                switch phase {
                                case .success(let img):
                                    img.resizable().scaledToFill()
                                default:
                                    Rectangle().fill(Color.gray.opacity(0.3))
                                }
                            }
                            .containerRelativeFrame(.horizontal, count: 3, spacing: 2)
                            .clipped()
                        }
                    }
                    .padding(.top, 2)

                    Spacer().frame(height: 100)
                }
            }

            NavBarView(selectedTab: $selectedTab)
        }
        .navigationBarHidden(true)
    }
}

private struct StatItem: View {
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(Color.scoonTextSecondary)
        }
        .frame(maxWidth: .infinity)
    }
}

private struct ProfileTabButton: View {
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
