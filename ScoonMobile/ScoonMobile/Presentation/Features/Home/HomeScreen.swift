import SwiftUI

// Design: 190:878 – Home
struct HomeScreen: View {
    @Environment(AppRouter.self)    private var router
    @Environment(AppContainer.self) private var container
    @State private var vm: HomeViewModel?

    @State private var selectedTab = NavTab.home

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.scoonDarker.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    // ── Header ───────────────────────────────────────
                    HStack(alignment: .center) {
                        VStack(alignment: .leading, spacing: 3) {
                            Text("scoon")
                                .font(.system(size: 30, weight: .black, design: .rounded))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.white, Color.white.opacity(0.85)],
                                        startPoint: .leading, endPoint: .trailing
                                    )
                                )
                            Text("Graz · Österreich")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(Color.scoonOrange.opacity(0.9))
                                .tracking(0.5)
                        }
                        Spacer()
                        Button(action: {}) {
                            ZStack {
                                Circle()
                                    .fill(Color.white.opacity(0.07))
                                    .frame(width: 42, height: 42)
                                Image(systemName: "bell.fill")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                        }
                    }
                    .padding(.horizontal, 22)
                    .padding(.top, 58)

                    // ── Subtitle ─────────────────────────────────────
                    Text("Entdecke die schönsten\nFotospots in deiner Nähe.")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.white)
                        .lineSpacing(3)
                        .padding(.horizontal, 22)
                        .padding(.top, 18)

                    // ── Search bar ───────────────────────────────────
                    if let vm {
                        SearchBarView(text: Binding(
                            get: { vm.searchText },
                            set: { vm.searchText = $0 }
                        ))
                        .padding(.horizontal, 20)
                        .padding(.top, 20)

                        // ── Filter chips ─────────────────────────────
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(SpotFilter.allCases, id: \.self) { filter in
                                    FilterChip(
                                        label: filter.rawValue,
                                        isActive: vm.activeFilter == filter
                                    ) { vm.applyFilter(filter) }
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 2)
                        }
                        .padding(.top, 16)
                    }

                    // ── Section header ───────────────────────────────
                    HStack(alignment: .center) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Beliebte Fotospots")
                                .font(.system(size: 20, weight: .heavy))
                                .foregroundColor(.white)
                            Rectangle()
                                .fill(Color.scoonOrange)
                                .frame(width: 28, height: 3)
                                .cornerRadius(2)
                        }
                        Spacer()
                        Button(action: {}) {
                            HStack(spacing: 4) {
                                Text("Alle")
                                    .font(.system(size: 13, weight: .semibold))
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 11, weight: .bold))
                            }
                            .foregroundColor(Color.scoonOrange)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.scoonOrange.opacity(0.12))
                            .cornerRadius(20)
                        }
                    }
                    .padding(.horizontal, 22)
                    .padding(.top, 28)

                    // ── Spot cards ───────────────────────────────────
                    if let vm {
                        if vm.isLoading {
                            HStack(spacing: 14) {
                                ForEach(0..<3, id: \.self) { _ in
                                    SkeletonCard()
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 14)
                        } else {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 14) {
                                    ForEach(vm.filteredSpots) { spot in
                                        SpotCardView(spot: spot) {
                                            router.navigate(to: .placeInfo)
                                        }
                                    }
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 8)
                            }
                            .padding(.top, 14)
                        }
                    }

                    Spacer().frame(height: 100)
                }
            }

            NavBarView(selectedTab: $selectedTab)
        }
        .navigationBarHidden(true)
        .task {
            let viewModel = container.makeHomeViewModel()
            vm = viewModel
            await viewModel.onAppear()
        }
    }
}

// MARK: – Search Bar

private struct SearchBarView: View {
    @Binding var text: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(Color.scoonTextSecondary)

            TextField("Ort, Name oder Kategorie …", text: $text)
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(.white)
                .tint(Color.scoonOrange)

            Spacer()

            Divider()
                .frame(width: 1, height: 20)
                .background(Color.white.opacity(0.12))

            Button(action: {}) {
                ZStack {
                    Circle()
                        .fill(Color.scoonOrange)
                        .frame(width: 36, height: 36)
                    Image(systemName: "location.fill")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                }
            }
        }
        .padding(.leading, 16)
        .padding(.trailing, 10)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.06))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
        .frame(height: 54)
    }
}

// MARK: – Filter Chip

private struct FilterChip: View {
    let label: String
    let isActive: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 13, weight: isActive ? .semibold : .regular))
                .foregroundColor(isActive ? .black : Color.white.opacity(0.6))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(isActive ? Color.scoonOrange : Color.white.opacity(0.08))
                        .shadow(
                            color: isActive ? Color.scoonOrange.opacity(0.45) : .clear,
                            radius: 10, x: 0, y: 4
                        )
                )
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.25, dampingFraction: 0.7), value: isActive)
    }
}

// MARK: – Spot Card

private struct SpotCardView: View {
    let spot: Spot
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            ZStack(alignment: .bottom) {
                // Photo
                AsyncImage(url: URL(string: spot.imageURL)) { phase in
                    switch phase {
                    case .success(let img):
                        img.resizable().scaledToFill()
                    default:
                        Rectangle()
                            .fill(Color.white.opacity(0.06))
                            .overlay(
                                Image(systemName: "photo")
                                    .font(.system(size: 32))
                                    .foregroundColor(.white.opacity(0.2))
                            )
                    }
                }
                .frame(width: 210, height: 310)
                .clipShape(RoundedRectangle(cornerRadius: 24))

                // Gradient overlay
                LinearGradient(
                    colors: [.clear, .clear, .black.opacity(0.75)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .clipShape(RoundedRectangle(cornerRadius: 24))

                // Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(spot.name)
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(.white)
                    HStack(spacing: 6) {
                        Image(systemName: "mappin.fill")
                            .font(.system(size: 10))
                            .foregroundColor(Color.scoonOrange)
                        Text(spot.location)
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.75))
                        Spacer()
                        Image(systemName: "star.fill")
                            .font(.system(size: 11))
                            .foregroundColor(Color.scoonOrange)
                        Text(String(format: "%.1f", spot.rating))
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.white)
                    }
                }
                .padding(.horizontal, 14)
                .padding(.bottom, 16)
                .frame(width: 210, alignment: .leading)

                // Favourite badge
                VStack {
                    HStack {
                        Spacer()
                        ZStack {
                            Circle()
                                .fill(.ultraThinMaterial)
                                .environment(\.colorScheme, .dark)
                                .frame(width: 34, height: 34)
                            Image(systemName: spot.isFavorite ? "heart.fill" : "heart")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(spot.isFavorite ? Color.scoonOrange : .white)
                        }
                        .padding(.top, 14)
                        .padding(.trailing, 12)
                    }
                    Spacer()
                }
                .frame(width: 210)
            }
            .frame(width: 210, height: 310)
            .shadow(color: .black.opacity(0.35), radius: 18, x: 0, y: 8)
        }
        .buttonStyle(.plain)
    }
}

// MARK: – Skeleton Card (loading state)

private struct SkeletonCard: View {
    @State private var shimmer = false

    var body: some View {
        RoundedRectangle(cornerRadius: 24)
            .fill(Color.white.opacity(0.06))
            .frame(width: 210, height: 310)
            .overlay(
                LinearGradient(
                    colors: [.clear, .white.opacity(shimmer ? 0.06 : 0.02), .clear],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .clipShape(RoundedRectangle(cornerRadius: 24))
                .animation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true), value: shimmer)
            )
            .onAppear { shimmer = true }
    }
}
