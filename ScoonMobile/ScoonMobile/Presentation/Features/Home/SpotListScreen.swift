import SwiftUI

struct SpotListScreen: View {
    let filter: SpotFilter

    @Environment(AppRouter.self)    private var router
    @Environment(AppContainer.self) private var container
    @State private var vm: HomeViewModel?

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.scoonDarker.ignoresSafeArea()

            VStack(spacing: 0) {
                // ── Header ────────────────────────────────────────────
                HStack {
                    BackButton { router.navigateBack() }
                    VStack(alignment: .leading, spacing: 2) {
                        Text(filter.rawValue)
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.primary)
                        Text("Alle Spots")
                            .font(.system(size: 12))
                            .foregroundColor(Color.scoonOrange)
                    }
                    .padding(.leading, 10)
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 56)

                if let vm {
                    if vm.isLoading {
                        Spacer()
                        VStack(spacing: 14) {
                            ProgressView().tint(Color.scoonOrange).scaleEffect(1.2)
                            Text("Lade Spots …")
                                .font(.system(size: 13))
                                .foregroundColor(Color.scoonTextSecondary)
                        }
                        Spacer()
                    } else if vm.filteredSpots.isEmpty {
                        Spacer()
                        VStack(spacing: 14) {
                            Image(systemName: "photo.on.rectangle.angled")
                                .font(.system(size: 36))
                                .foregroundColor(Color.scoonTextSecondary.opacity(0.4))
                            Text("Keine Spots gefunden")
                                .font(.system(size: 16))
                                .foregroundColor(Color.scoonTextSecondary)
                        }
                        Spacer()
                    } else {
                        ScrollView(showsIndicators: false) {
                            VStack(spacing: 12) {
                                ForEach(vm.filteredSpots) { spot in
                                    SpotListRow(spot: spot) {
                                        router.navigate(to: .placeInfo(spot))
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
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
            let viewModel = container.makeHomeViewModel()
            vm = viewModel
            viewModel.applyFilter(filter)
            await viewModel.onAppear()
        }
    }
}

// MARK: – Spot Row

private struct SpotListRow: View {
    let spot: Spot
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 14) {
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

                VStack(alignment: .leading, spacing: 4) {
                    Text(spot.name)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.primary)
                        .lineLimit(1)

                    HStack(spacing: 4) {
                        Image(systemName: "mappin")
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

                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(Color.scoonTextSecondary.opacity(0.5))
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
        }
        .buttonStyle(.plain)
    }
}
