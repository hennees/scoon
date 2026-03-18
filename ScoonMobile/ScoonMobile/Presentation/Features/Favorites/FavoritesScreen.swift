import SwiftUI

struct FavoritesScreen: View {
    @Environment(AppRouter.self)    private var router
    @Environment(AppContainer.self) private var container
    @State private var vm: FavoritesViewModel?
    @State private var activeListTab = 0

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.scoonDarker.ignoresSafeArea()

            VStack(spacing: 0) {
                // ── Header ────────────────────────────────────────────
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Button(action: { router.switchToHome() }) {
                            Text("scoon")
                                .font(.system(size: 28, weight: .black, design: .rounded))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [Color.primary, Color.scoonOrange],
                                        startPoint: .leading, endPoint: .trailing
                                    )
                                )
                        }
                        .buttonStyle(.plain)
                        Text("Meine Orte")
                            .font(.system(size: 22, weight: .heavy))
                            .foregroundColor(.primary)
                    }
                    Spacer()
                    HStack(spacing: 10) {
                        Button(action: {}) {
                            ZStack {
                                Circle().fill(Color.primary.opacity(0.08)).frame(width: 42, height: 42)
                                    .overlay(Circle().stroke(Color.primary.opacity(0.1), lineWidth: 1))
                                Image(systemName: "bell.fill")
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(.primary)
                            }
                        }
                        Button(action: { router.navigate(to: .settings) }) {
                            ZStack {
                                Circle().fill(Color.primary.opacity(0.08)).frame(width: 42, height: 42)
                                    .overlay(Circle().stroke(Color.primary.opacity(0.1), lineWidth: 1))
                                Image(systemName: "gearshape.fill")
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(.primary)
                            }
                        }
                    }
                }
                .padding(.horizontal, 22)
                .padding(.top, 58)

                // ── Segment control ───────────────────────────────────
                HStack(spacing: 0) {
                    SegmentTabButton(title: "Favoriten", isActive: activeListTab == 0) { activeListTab = 0 }
                    SegmentTabButton(title: "Meine Orte", isActive: activeListTab == 1) { activeListTab = 1 }
                }
                .padding(.horizontal, 22)
                .padding(.top, 18)

                // ── Action row ────────────────────────────────────────
                HStack(spacing: 8) {
                    Button(action: {}) {
                        HStack(spacing: 5) {
                            Image(systemName: "arrow.up.arrow.down").font(.system(size: 11))
                            Text("Neueste").font(.system(size: 13, weight: .medium))
                        }
                        .foregroundColor(.white.opacity(0.7))
                        .padding(.horizontal, 12).padding(.vertical, 7)
                        .background(Color.primary.opacity(0.07))
                        .cornerRadius(10)
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.primary.opacity(0.09), lineWidth: 1))
                    }
                    Button(action: { router.switchTab(to: .map) }) {
                        HStack(spacing: 5) {
                            Image(systemName: "map.fill").font(.system(size: 11))
                            Text("Karte").font(.system(size: 13, weight: .medium))
                        }
                        .foregroundColor(Color.scoonOrange)
                        .padding(.horizontal, 12).padding(.vertical, 7)
                        .background(Color.scoonOrange.opacity(0.12))
                        .cornerRadius(10)
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.scoonOrange.opacity(0.25), lineWidth: 1))
                    }
                    Spacer()
                    if let vm, !vm.favorites.isEmpty {
                        Text("\(vm.favorites.count) Orte")
                            .font(.system(size: 13))
                            .foregroundColor(Color.scoonTextSecondary)
                    }
                }
                .padding(.horizontal, 22)
                .padding(.top, 14)

                // ── Content ───────────────────────────────────────────
                if let vm {
                    if vm.isLoading {
                        Spacer()
                        VStack(spacing: 14) {
                            ProgressView().tint(Color.scoonOrange).scaleEffect(1.2)
                            Text("Lade deine Orte …")
                                .font(.system(size: 13))
                                .foregroundColor(Color.scoonTextSecondary)
                        }
                        Spacer()
                    } else if vm.favorites.isEmpty {
                        Spacer()
                        FavoritesEmptyState { router.switchTab(to: .home) }
                        Spacer()
                    } else {
                        ScrollView(showsIndicators: false) {
                            VStack(spacing: 12) {
                                ForEach(vm.favorites) { spot in
                                    FavoriteSpotRow(spot: spot) {
                                        router.navigate(to: .placeInfo(spot))
                                    } onToggle: {
                                        vm.toggle(spot: spot)
                                    }
                                }
                            }
                            .padding(.horizontal, 22)
                            .padding(.top, 16)
                            .padding(.bottom, 110)
                        }
                        .refreshable { await vm.refresh() }
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
        }
        .toolbar(.hidden, for: .navigationBar)
        .task {
            let viewModel = container.makeFavoritesViewModel()
            vm = viewModel
            await viewModel.onAppear()
        }
    }
}

// MARK: – Empty State

private struct FavoritesEmptyState: View {
    let onExplore: () -> Void
    @State private var pulse = false

    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(Color.scoonOrange.opacity(0.08))
                    .frame(width: 100, height: 100)
                    .scaleEffect(pulse ? 1.1 : 1.0)
                    .animation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true), value: pulse)
                Circle()
                    .fill(Color.scoonOrange.opacity(0.14))
                    .frame(width: 76, height: 76)
                Image(systemName: "heart.slash.fill")
                    .font(.system(size: 30))
                    .foregroundColor(Color.scoonOrange.opacity(0.6))
            }
            .onAppear { pulse = true }

            VStack(spacing: 6) {
                Text("Noch keine Favoriten")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.primary)
                Text("Entdecke Fotospots und speichere\ndeine Lieblinge hier.")
                    .font(.system(size: 14))
                    .foregroundColor(Color.scoonTextSecondary)
                    .multilineTextAlignment(.center)
            }

            Button(action: onExplore) {
                HStack(spacing: 8) {
                    Image(systemName: "safari.fill")
                    Text("Spots entdecken")
                        .fontWeight(.semibold)
                }
                .font(.system(size: 15))
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(Color.scoonOrange)
                .cornerRadius(14)
                .shadow(color: Color.scoonOrange.opacity(0.4), radius: 10, x: 0, y: 4)
            }
        }
        .padding(.horizontal, 40)
    }
}

// MARK: – Spot Row

private struct FavoriteSpotRow: View {
    let spot: Spot
    let onTap: () -> Void
    let onToggle: () -> Void

    var body: some View {
        HStack(alignment: .center, spacing: 14) {
            // Thumbnail
            AsyncImage(url: URL(string: spot.imageURL)) { phase in
                switch phase {
                case .success(let img): img.resizable().scaledToFill()
                default:
                    Rectangle()
                        .fill(Color.primary.opacity(0.07))
                        .overlay(
                            Image(systemName: "photo")
                                .font(.system(size: 20))
                                .foregroundColor(.white.opacity(0.18))
                        )
                }
            }
            .frame(width: 78, height: 78)
            .clipShape(RoundedRectangle(cornerRadius: 14))

            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(spot.name)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.primary)
                    .lineLimit(1)

                HStack(spacing: 4) {
                    Image(systemName: "mappin.fill")
                        .font(.system(size: 10))
                        .foregroundColor(Color.scoonOrange)
                    Text(spot.location)
                        .font(.system(size: 12))
                        .foregroundColor(Color.scoonTextSecondary)
                        .lineLimit(1)
                }

                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 10))
                        .foregroundColor(Color.scoonOrange)
                    Text(String(format: "%.1f", spot.rating))
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.primary)
                    Text("·")
                        .foregroundColor(Color.scoonTextSecondary.opacity(0.4))
                    Text(spot.category.rawValue)
                        .font(.system(size: 12))
                        .foregroundColor(Color.scoonTextSecondary)
                }
            }

            Spacer()

            // Heart toggle
            Button(action: onToggle) {
                ZStack {
                    Circle()
                        .fill(spot.isFavorite ? Color.scoonOrange.opacity(0.15) : Color.primary.opacity(0.07))
                        .frame(width: 38, height: 38)
                    Image(systemName: spot.isFavorite ? "heart.fill" : "heart")
                        .foregroundColor(spot.isFavorite ? Color.scoonOrange : Color.scoonTextSecondary)
                        .font(.system(size: 16, weight: .semibold))
                }
            }
            .buttonStyle(.plain)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: spot.isFavorite)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.primary.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(Color.primary.opacity(0.08), lineWidth: 1)
                )
        )
        .contentShape(Rectangle())
        .onTapGesture(perform: onTap)
    }
}
