import SwiftUI

struct InsightsScreen: View {
    @Environment(AppRouter.self)    private var router
    @Environment(AppContainer.self) private var container
    @State private var vm: InsightsViewModel?
    @State private var barsVisible = false

    private let barHeights: [SpotCategory: CGFloat] = [
        .nature: 90, .urban: 68, .architecture: 82,
        .hidden: 44, .parkGarden: 60, .exhibitions: 50, .monuments: 72,
    ]

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.scoonDarker.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {

                    // ── Header ────────────────────────────────────────
                    HStack {
                        BackButton { router.navigateBack() }
                        VStack(alignment: .leading, spacing: 1) {
                            Text("Insights")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.primary)
                            Text("Creator Dashboard")
                                .font(.system(size: 12))
                                .foregroundColor(Color.scoonOrange)
                        }
                        .padding(.leading, 10)
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 56)

                    // ── Period pill ───────────────────────────────────
                    HStack(spacing: 8) {
                        Text("letzten 30 Tage")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(Color.scoonOrange)
                            .padding(.horizontal, 14).padding(.vertical, 7)
                            .background(Color.scoonOrange.opacity(0.1))
                            .clipShape(Capsule())
                            .overlay(
                                Capsule().stroke(Color.scoonOrange.opacity(0.35), lineWidth: 1)
                            )
                        Text("17. Feb – 17. Mär 2026")
                            .font(.system(size: 12))
                            .foregroundColor(Color.scoonTextSecondary)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)

                    if let vm {
                        if vm.isLoading {
                            ProgressView().tint(Color.scoonOrange)
                                .frame(maxWidth: .infinity).padding(.top, 60)
                        } else if let summary = vm.summary {

                            // ── Stat grid ─────────────────────────────
                            LazyVGrid(
                                columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)],
                                spacing: 12
                            ) {
                                InsightStatCard(
                                    label: "Spot Views",
                                    value: summary.totalViews.formatted(),
                                    icon: "eye.fill",
                                    color: Color(red: 0.3, green: 0.65, blue: 1.0)
                                )
                                InsightStatCard(
                                    label: "Ø Views / Spot",
                                    value: summary.avgViewsPerSpot.formatted(),
                                    icon: "chart.line.uptrend.xyaxis",
                                    color: Color.scoonOrange
                                )
                                InsightStatCard(
                                    label: "Ø Likes / Spot",
                                    value: summary.avgLikesPerSpot.formatted(),
                                    icon: "heart.fill",
                                    color: Color(red: 1.0, green: 0.35, blue: 0.45)
                                )
                                InsightStatCard(
                                    label: "Ø Saves / Spot",
                                    value: summary.avgSavesPerSpot.formatted(),
                                    icon: "bookmark.fill",
                                    color: Color(red: 0.4, green: 0.8, blue: 0.55)
                                )
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 20)

                            // ── Top Performer ─────────────────────────
                            HStack {
                                Text("Top Performer")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(.primary)
                                Rectangle()
                                    .fill(Color.scoonOrange)
                                    .frame(width: 20, height: 3)
                                    .cornerRadius(1.5)
                                    .padding(.top, 2)
                                Spacer()
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 28)

                            VStack(spacing: 10) {
                                ForEach(Array(vm.topSpots.enumerated()), id: \.element.id) { idx, spot in
                                    InsightTopSpotRow(spot: spot, rank: idx + 1)
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 10)

                            // ── Bar chart ─────────────────────────────
                            HStack {
                                Text("Spots nach Kategorie")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(.primary)
                                Rectangle()
                                    .fill(Color.scoonOrange)
                                    .frame(width: 20, height: 3)
                                    .cornerRadius(1.5)
                                    .padding(.top, 2)
                                Spacer()
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 28)

                            HStack(alignment: .bottom, spacing: 8) {
                                ForEach(SpotCategory.allCases, id: \.self) { cat in
                                    let target = barHeights[cat, default: 50]
                                    VStack(spacing: 5) {
                                        Text("\(Int(target))")
                                            .font(.system(size: 9, weight: .semibold))
                                            .foregroundColor(Color.scoonOrange.opacity(barsVisible ? 1 : 0))
                                        RoundedRectangle(cornerRadius: 6)
                                            .fill(
                                                LinearGradient(
                                                    colors: [Color.scoonOrange, Color.scoonOrange.opacity(0.35)],
                                                    startPoint: .top, endPoint: .bottom
                                                )
                                            )
                                            .frame(height: barsVisible ? target : 4)
                                            .animation(
                                                .spring(response: 0.6, dampingFraction: 0.7)
                                                    .delay(Double(SpotCategory.allCases.firstIndex(of: cat) ?? 0) * 0.07),
                                                value: barsVisible
                                            )
                                        Text(cat.rawValue)
                                            .font(.system(size: 8, weight: .medium))
                                            .foregroundColor(Color.scoonTextSecondary)
                                            .multilineTextAlignment(.center)
                                            .lineLimit(2)
                                    }
                                    .frame(maxWidth: .infinity)
                                }
                            }
                            .frame(height: 140)
                            .padding(.horizontal, 20)
                            .padding(.top, 14)
                            .onAppear {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    barsVisible = true
                                }
                            }
                        }
                    }

                    Spacer().frame(height: 100)
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
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
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(color.opacity(0.15))
                    .frame(width: 38, height: 38)
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(color)
            }
            VStack(alignment: .leading, spacing: 3) {
                Text(value)
                    .font(.system(size: 26, weight: .bold))
                    .foregroundColor(.primary)
                Text(label)
                    .font(.system(size: 12))
                    .foregroundColor(Color.scoonTextSecondary)
                    .lineLimit(1)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.primary.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(Color.primary.opacity(0.08), lineWidth: 1)
                )
        )
    }
}

// MARK: – Top Spot Row

private struct InsightTopSpotRow: View {
    let spot: Spot
    let rank: Int

    var body: some View {
        HStack(spacing: 12) {
            // Rank badge
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(rank == 1 ? Color.scoonOrange : Color.primary.opacity(0.08))
                    .frame(width: 32, height: 32)
                Text("#\(rank)")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(rank == 1 ? .white : Color.scoonTextSecondary)
            }

            Text(spot.name)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.primary)
                .lineLimit(1)
            Spacer()

            HStack(spacing: 12) {
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
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.primary.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.primary.opacity(0.07), lineWidth: 1)
                )
        )
    }
}
