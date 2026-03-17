import SwiftUI

// Design: 626:581 – Insights
struct InsightsScreen: View {
    @Environment(AppRouter.self)    private var router
    @Environment(AppContainer.self) private var container
    @State private var vm: InsightsViewModel?

    @State private var selectedTab = NavTab.profile

    // Stable placeholder heights per category (no random)
    private let barHeights: [SpotCategory: CGFloat] = [
        .nature: 80, .urban: 60, .architecture: 75,
        .hidden: 40, .parkGarden: 55, .exhibitions: 45, .monuments: 65,
    ]

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.scoonDarker.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    // ── Header ────────────────────────────────────────
                    HStack {
                        Button(action: { router.navigateBack() }) {
                            Image(systemName: "arrow.left")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(Color.scoonOrange)
                        }
                        Text("scoon")
                            .font(.system(size: 28, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.leading, 8)
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 56)

                    // ── Period pill ───────────────────────────────────
                    Text("letzten 30 Tage")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 14).padding(.vertical, 6)
                        .background(Color.white.opacity(0.07))
                        .clipShape(Capsule())
                        .padding(.horizontal, 20)
                        .padding(.top, 12)

                    Text("17. Feb – 17. Mär 2026")
                        .font(.system(size: 13))
                        .foregroundColor(Color.scoonTextSecondary)
                        .padding(.horizontal, 20)
                        .padding(.top, 6)

                    if let vm {
                        if vm.isLoading {
                            ProgressView().tint(Color.scoonOrange)
                                .frame(maxWidth: .infinity).padding(.top, 40)
                        } else if let summary = vm.summary {
                            // ── Stats grid ────────────────────────────
                            LazyVGrid(
                                columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)],
                                spacing: 12
                            ) {
                                InsightStatCard(label: "Total Spot Views",  value: summary.totalViews.formatted())
                                InsightStatCard(label: "Avg Views/Spot",    value: summary.avgViewsPerSpot.formatted())
                                InsightStatCard(label: "Avg Likes/Spot",    value: summary.avgLikesPerSpot.formatted())
                                InsightStatCard(label: "Avg Saves/Spot",    value: summary.avgSavesPerSpot.formatted())
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 20)

                            // ── Top performer ─────────────────────────
                            Text("Top Performer")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 20)
                                .padding(.top, 24)

                            VStack(spacing: 10) {
                                ForEach(vm.topSpots) { spot in
                                    InsightTopSpotRow(spot: spot)
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 10)

                            // ── Bar chart ─────────────────────────────
                            Text("Spots nach Kategorien")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 20)
                                .padding(.top, 24)

                            HStack(alignment: .bottom, spacing: 10) {
                                ForEach(SpotCategory.allCases, id: \.self) { cat in
                                    VStack(spacing: 6) {
                                        RoundedRectangle(cornerRadius: 6)
                                            .fill(
                                                LinearGradient(
                                                    colors: [Color.scoonOrange, Color.scoonOrange.opacity(0.4)],
                                                    startPoint: .top, endPoint: .bottom
                                                )
                                            )
                                            .frame(height: barHeights[cat, default: 50])
                                        Text(cat.rawValue)
                                            .font(.system(size: 9))
                                            .foregroundColor(Color.scoonTextSecondary)
                                            .multilineTextAlignment(.center)
                                            .lineLimit(2)
                                    }
                                    .frame(maxWidth: .infinity)
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 12)
                        }
                    }

                    Spacer().frame(height: 100)
                }
            }

            NavBarView(selectedTab: $selectedTab)
        }
        .navigationBarHidden(true)
        .task {
            let viewModel = container.makeInsightsViewModel()
            vm = viewModel
            await viewModel.onAppear()
        }
    }
}

// MARK: – Stat Card

private struct InsightStatCard: View {
    let label: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(value)
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.white)
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(Color.scoonTextSecondary)
                .lineLimit(2)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.white.opacity(0.06))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                )
        )
    }
}

// MARK: – Top Spot Row

private struct InsightTopSpotRow: View {
    let spot: Spot

    var body: some View {
        HStack {
            Text(spot.name)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.white)
            Spacer()
            HStack(spacing: 14) {
                Label("\(spot.viewCount)", systemImage: "eye")
                    .font(.system(size: 12))
                    .foregroundColor(Color.scoonTextSecondary)
                Label("\(spot.likeCount)", systemImage: "heart")
                    .font(.system(size: 12))
                    .foregroundColor(Color.scoonTextSecondary)
                Label("\(spot.saveCount)", systemImage: "bookmark")
                    .font(.system(size: 12))
                    .foregroundColor(Color.scoonTextSecondary)
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.white.opacity(0.07), lineWidth: 1)
                )
        )
    }
}
