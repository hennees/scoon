import SwiftUI

// Design: 304:204 – Favorites / Meine Orte
struct FavoritesScreen: View {
    @Environment(AppRouter.self)    private var router
    @Environment(AppContainer.self) private var container
    @State private var vm: FavoritesViewModel?

    @State private var selectedTab   = NavTab.favorites
    @State private var activeListTab = 0

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.scoonDarker.ignoresSafeArea()

            VStack(spacing: 0) {
                // ── Header ────────────────────────────────────────────
                HStack {
                    Text("scoon")
                        .font(.system(size: 28, weight: .black, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.white, Color.white.opacity(0.85)],
                                startPoint: .leading, endPoint: .trailing
                            )
                        )
                    Spacer()
                    HStack(spacing: 12) {
                        Button(action: {}) {
                            ZStack {
                                Circle().fill(Color.white.opacity(0.07)).frame(width: 40, height: 40)
                                Image(systemName: "bell.fill")
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                        }
                        Button(action: { router.navigate(to: .settings) }) {
                            ZStack {
                                Circle().fill(Color.white.opacity(0.07)).frame(width: 40, height: 40)
                                Image(systemName: "gearshape.fill")
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                        }
                    }
                }
                .padding(.horizontal, 22)
                .padding(.top, 58)

                Text("Meine Orte")
                    .font(.system(size: 26, weight: .heavy))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 22)
                    .padding(.top, 14)

                // ── Tabs ──────────────────────────────────────────────
                HStack(spacing: 0) {
                    FavTabButton(title: "Meine Favoriten", isActive: activeListTab == 0) { activeListTab = 0 }
                    FavTabButton(title: "Meine Orte",      isActive: activeListTab == 1) { activeListTab = 1 }
                }
                .padding(.horizontal, 22)
                .padding(.top, 14)

                // ── Action row ────────────────────────────────────────
                HStack(spacing: 10) {
                    Button(action: {}) {
                        HStack(spacing: 6) {
                            Image(systemName: "arrow.up.arrow.down").font(.system(size: 12))
                            Text("Sort: Neueste").font(.system(size: 13, weight: .medium))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 14).padding(.vertical, 8)
                        .background(Color.white.opacity(0.07))
                        .cornerRadius(8)
                    }
                    Button(action: { router.navigate(to: .kartenansicht) }) {
                        HStack(spacing: 6) {
                            Image(systemName: "map").font(.system(size: 12))
                            Text("Karte").font(.system(size: 13, weight: .medium))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 14).padding(.vertical, 8)
                        .background(Color.white.opacity(0.07))
                        .cornerRadius(8)
                    }
                    Spacer()
                }
                .padding(.horizontal, 22)
                .padding(.top, 12)

                // ── Content ───────────────────────────────────────────
                if let vm {
                    if vm.isLoading {
                        Spacer()
                        ProgressView().tint(Color.scoonOrange)
                        Spacer()
                    } else if vm.favorites.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "heart.slash")
                                .font(.system(size: 44))
                                .foregroundColor(Color.scoonTextSecondary.opacity(0.4))
                            Text("Noch keine Favoriten")
                                .font(.system(size: 16))
                                .foregroundColor(Color.scoonTextSecondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 60)
                        Spacer()
                    } else {
                        ScrollView(showsIndicators: false) {
                            VStack(spacing: 14) {
                                ForEach(vm.favorites) { spot in
                                    FavoriteSpotRow(spot: spot) {
                                        router.navigate(to: .placeInfo(spot))
                                    } onToggle: {
                                        vm.toggle(spot: spot)
                                    }
                                }
                            }
                            .padding(.horizontal, 22)
                            .padding(.top, 14)
                            .padding(.bottom, 100)
                        }
                    }
                } else {
                    Spacer()
                }
            }

            if let vm, let error = vm.error {
                VStack {
                    Spacer()
                    ErrorBanner(message: error) { Task { await vm.onAppear() } }
                        .padding(.bottom, 90)
                }
            }

            NavBarView(selectedTab: $selectedTab)
        }
        .navigationBarHidden(true)
        .task {
            let viewModel = container.makeFavoritesViewModel()
            vm = viewModel
            await viewModel.onAppear()
        }
    }
}

// MARK: – Tab Button

private struct FavTabButton: View {
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
        .animation(.spring(response: 0.25, dampingFraction: 0.7), value: isActive)
    }
}

// MARK: – Spot Row

private struct FavoriteSpotRow: View {
    let spot: Spot
    let onTap: () -> Void
    let onToggle: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            // Thumbnail
            AsyncImage(url: URL(string: spot.imageURL)) { phase in
                switch phase {
                case .success(let img): img.resizable().scaledToFill()
                default: Rectangle().fill(Color.white.opacity(0.06))
                    .overlay(Image(systemName: "photo").foregroundColor(.white.opacity(0.2)))
                }
            }
            .frame(width: 80, height: 80)
            .clipShape(RoundedRectangle(cornerRadius: 12))

            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(spot.name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                Text(spot.description)
                    .font(.system(size: 13))
                    .foregroundColor(Color.scoonTextSecondary)
                    .lineLimit(2)
                HStack(spacing: 4) {
                    Image(systemName: "mappin.fill")
                        .font(.system(size: 10))
                        .foregroundColor(Color.scoonOrange)
                    Text(spot.location)
                        .font(.system(size: 12))
                        .foregroundColor(Color.scoonTextSecondary)
                }
                .padding(.top, 2)
                Text("Auf der Karte")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Color.scoonOrange)
                    .padding(.top, 2)
            }

            Spacer()

            // Heart
            Button(action: onToggle) {
                Image(systemName: spot.isFavorite ? "heart.fill" : "heart")
                    .foregroundColor(spot.isFavorite ? Color.scoonOrange : Color.scoonTextSecondary)
                    .font(.system(size: 18))
            }
            .buttonStyle(.plain)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                )
        )
        .contentShape(Rectangle())
        .onTapGesture(perform: onTap)
    }
}
