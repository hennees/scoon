import SwiftUI

struct HomeScreen: View {
    @Environment(AppRouter.self)    private var router
    @Environment(AppContainer.self) private var container
    @State private var vm: HomeViewModel?
    @State private var appeared = false

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.scoonDarker.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {

                    // ── Header ────────────────────────────────────────
                    HStack(alignment: .center) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("scoon")
                                .font(.system(size: 28, weight: .black, design: .rounded))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [Color.primary, Color.scoonOrange],
                                        startPoint: .leading, endPoint: .trailing
                                    )
                                )
                            HStack(spacing: 4) {
                                Image(systemName: "location.fill")
                                    .font(.system(size: 9, weight: .semibold))
                                    .foregroundColor(Color.scoonOrange)
                                Text("Graz · Österreich")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(Color.scoonOrange.opacity(0.9))
                                    .tracking(0.3)
                            }
                        }
                        Spacer()
                        Button(action: {}) {
                            ZStack {
                                Circle()
                                    .fill(Color.primary.opacity(0.08))
                                    .frame(width: 44, height: 44)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.primary.opacity(0.1), lineWidth: 1)
                                    )
                                Image(systemName: "bell.fill")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.primary)
                            }
                        }
                    }
                    .padding(.horizontal, 22)
                    .padding(.top, 58)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : -8)
                    .animation(.easeOut(duration: 0.4).delay(0.05), value: appeared)

                    // ── Subtitle ──────────────────────────────────────
                    Text("Entdecke die schönsten\nFotospots in deiner Nähe.")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.primary)
                        .lineSpacing(4)
                        .padding(.horizontal, 22)
                        .padding(.top, 20)
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 10)
                        .animation(.easeOut(duration: 0.4).delay(0.1), value: appeared)

                    // ── Search bar ────────────────────────────────────
                    if let vm {
                        SearchBarView(text: Binding(
                            get: { vm.searchText },
                            set: { vm.searchText = $0 }
                        ))
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 10)
                        .animation(.easeOut(duration: 0.4).delay(0.15), value: appeared)

                        // ── Filter chips ──────────────────────────────
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
                        .padding(.top, 14)
                        .opacity(appeared ? 1 : 0)
                        .animation(.easeOut(duration: 0.4).delay(0.2), value: appeared)
                    }

                    // ── Section header ────────────────────────────────
                    SectionHeader(title: "Beliebte Spots", onSeeAll: {})
                        .padding(.top, 28)
                        .opacity(appeared ? 1 : 0)
                        .animation(.easeOut(duration: 0.4).delay(0.25), value: appeared)

                    // ── Spot cards ────────────────────────────────────
                    if let vm {
                        if vm.isLoading {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 14) {
                                    ForEach(0..<3, id: \.self) { _ in SkeletonCard() }
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 8)
                            }
                            .padding(.top, 14)
                        } else if vm.filteredSpots.isEmpty {
                            EmptySpotState { router.navigate(to: .addPhotoSpot) }
                                .padding(.top, 14)
                        } else {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 14) {
                                    ForEach(Array(vm.filteredSpots.enumerated()), id: \.element.id) { idx, spot in
                                        SpotCardView(spot: spot) {
                                            router.navigate(to: .placeInfo(spot))
                                        }
                                        .opacity(appeared ? 1 : 0)
                                        .offset(x: appeared ? 0 : 30)
                                        .animation(
                                            .spring(response: 0.5, dampingFraction: 0.75)
                                                .delay(0.28 + Double(idx) * 0.06),
                                            value: appeared
                                        )
                                    }
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 8)
                            }
                            .padding(.top, 14)

                            // ── Nearby section ────────────────────────
                            if vm.filteredSpots.count > 2 {
                                SectionHeader(title: "In deiner Nähe", onSeeAll: {})
                                    .padding(.top, 28)
                                    .opacity(appeared ? 1 : 0)
                                    .animation(.easeOut(duration: 0.4).delay(0.4), value: appeared)

                                VStack(spacing: 12) {
                                    ForEach(Array(vm.filteredSpots.prefix(3).enumerated()), id: \.element.id) { idx, spot in
                                        NearbySpotRow(spot: spot) {
                                            router.navigate(to: .placeInfo(spot))
                                        }
                                        .opacity(appeared ? 1 : 0)
                                        .offset(y: appeared ? 0 : 12)
                                        .animation(
                                            .spring(response: 0.45, dampingFraction: 0.8)
                                                .delay(0.42 + Double(idx) * 0.07),
                                            value: appeared
                                        )
                                    }
                                }
                                .padding(.horizontal, 20)
                                .padding(.top, 12)
                            }
                        }
                    }

                    Spacer().frame(height: 110)
                }
            }
            .refreshable { await vm?.refresh() }

            // Error banner
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
            let viewModel = container.makeHomeViewModel()
            vm = viewModel
            appeared = true
            await viewModel.onAppear()
        }
    }
}

// MARK: – Section Header

private struct SectionHeader: View {
    let title: String
    let onSeeAll: () -> Void

    var body: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 20, weight: .heavy))
                    .foregroundColor(.primary)
                Rectangle()
                    .fill(Color.scoonOrange)
                    .frame(width: 24, height: 3)
                    .cornerRadius(2)
            }
            Spacer()
            Button(action: onSeeAll) {
                HStack(spacing: 3) {
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
                .foregroundColor(.primary)
                .tint(Color.scoonOrange)

            Spacer()

            if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(Color.scoonTextSecondary)
                }
            } else {
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
        }
        .padding(.leading, 16)
        .padding(.trailing, 10)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.primary.opacity(0.07))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.primary.opacity(0.1), lineWidth: 1)
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
                .foregroundColor(isActive ? .black : Color.primary.opacity(0.6))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(isActive ? Color.scoonOrange : Color.primary.opacity(0.08))
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

// MARK: – Spot Card (horizontal scroll)

private struct SpotCardView: View {
    let spot: Spot
    let onTap: () -> Void
    @State private var pressed = false

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
                            .fill(Color.primary.opacity(0.07))
                            .overlay(
                                Image(systemName: "photo")
                                    .font(.system(size: 32))
                                    .foregroundColor(.white.opacity(0.18))
                            )
                    }
                }
                .frame(width: 210, height: 300)
                .clipShape(RoundedRectangle(cornerRadius: 22))

                // Gradient
                LinearGradient(
                    colors: [.clear, .clear, .black.opacity(0.8)],
                    startPoint: .top, endPoint: .bottom
                )
                .clipShape(RoundedRectangle(cornerRadius: 22))

                // Info overlay
                VStack(alignment: .leading, spacing: 5) {
                    Text(spot.name)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .lineLimit(1)
                    HStack(spacing: 5) {
                        Image(systemName: "mappin.fill")
                            .font(.system(size: 10))
                            .foregroundColor(Color.scoonOrange)
                        Text(spot.location)
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.75))
                            .lineLimit(1)
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

                // Heart badge
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
            .frame(width: 210, height: 300)
            .shadow(color: .black.opacity(0.4), radius: 20, x: 0, y: 8)
            .scaleEffect(pressed ? 0.97 : 1.0)
        }
        .buttonStyle(.plain)
        .onLongPressGesture(minimumDuration: 99, pressing: { p in
            withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) { pressed = p }
        }, perform: {})
    }
}

// MARK: – Nearby Spot Row

private struct NearbySpotRow: View {
    let spot: Spot
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 14) {
                AsyncImage(url: URL(string: spot.imageURL)) { phase in
                    switch phase {
                    case .success(let img): img.resizable().scaledToFill()
                    default: Rectangle().fill(Color.primary.opacity(0.07))
                            .overlay(Image(systemName: "photo").foregroundColor(.white.opacity(0.2)))
                    }
                }
                .frame(width: 72, height: 72)
                .clipShape(RoundedRectangle(cornerRadius: 14))

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
                            .foregroundColor(Color.scoonTextSecondary.opacity(0.5))
                        Text(spot.category.rawValue)
                            .font(.system(size: 12))
                            .foregroundColor(Color.scoonTextSecondary)
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(Color.scoonTextSecondary.opacity(0.5))
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.primary.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.primary.opacity(0.08), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: – Empty State

private struct EmptySpotState: View {
    let onAdd: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.scoonOrange.opacity(0.1))
                    .frame(width: 80, height: 80)
                Image(systemName: "camera.aperture")
                    .font(.system(size: 36))
                    .foregroundColor(Color.scoonOrange.opacity(0.7))
            }
            Text("Noch keine Spots")
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(.white.opacity(0.7))
            Text("Sei der Erste und füge einen\nFotospot in deiner Nähe hinzu.")
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.4))
                .multilineTextAlignment(.center)
            Button(action: onAdd) {
                Label("Spot hinzufügen", systemImage: "plus")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Color.scoonOrange)
                    .cornerRadius(20)
            }
            .padding(.top, 4)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .padding(.horizontal, 20)
    }
}

// MARK: – Skeleton Card

private struct SkeletonCard: View {
    @State private var shimmer = false

    var body: some View {
        RoundedRectangle(cornerRadius: 22)
            .fill(Color.primary.opacity(0.06))
            .frame(width: 210, height: 300)
            .overlay(
                LinearGradient(
                    colors: [.clear, .white.opacity(shimmer ? 0.07 : 0.02), .clear],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .clipShape(RoundedRectangle(cornerRadius: 22))
                .animation(.easeInOut(duration: 1.3).repeatForever(autoreverses: true), value: shimmer)
            )
            .onAppear { shimmer = true }
    }
}
