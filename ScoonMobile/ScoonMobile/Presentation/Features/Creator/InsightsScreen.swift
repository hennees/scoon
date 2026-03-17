import SwiftUI

// Design: 626:581 – Insights
// Dark, stats grid, top performer list, category bar chart.
struct InsightsScreen: View {
    @Environment(AppRouter.self) private var router

    @State private var selectedTab = NavTab.profile

    private let stats: [(label: String, value: String)] = [
        ("Total Spot Views",  "1,234"),
        ("Avg Views/Spot",    "123"),
        ("Avg Likes/Spot",    "45"),
        ("Avg Saves/Spot",    "67"),
    ]

    private let topSpots: [(name: String, views: Int, likes: Int, saves: Int)] = [
        ("Murinsel",    123,  45,  67),
        ("Schlossberg", 823, 425, 167),
    ]

    private let categories = ["Nature", "Urban", "Architecture", "Hidden"]

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.scoonDarker.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    // Header
                    HStack {
                        Button(action: { router.navigateBack() }) {
                            Image(systemName: "arrow.left")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(Color.scoonOrange)
                        }
                        Text("scoon")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.leading, 8)
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 56)

                    // Period pill
                    Text("letzten 30 Tage")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 6)
                        .background(Color.scoonDark)
                        .clipShape(Capsule())
                        .padding(.horizontal, 20)
                        .padding(.top, 12)

                    // Date range
                    Text("17. Feb – 17. Mär 2026")
                        .font(.system(size: 13))
                        .foregroundColor(Color.scoonTextSecondary)
                        .padding(.horizontal, 20)
                        .padding(.top, 6)

                    // 2×2 stats grid
                    LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
                        ForEach(stats, id: \.label) { stat in
                            StatCard(label: stat.label, value: stat.value)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)

                    // Top performer
                    Text("Top performer")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.top, 24)

                    VStack(spacing: 10) {
                        ForEach(topSpots, id: \.name) { spot in
                            TopSpotRow(name: spot.name, views: spot.views, likes: spot.likes, saves: spot.saves)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)

                    // Bar chart
                    Text("Spots nach Kategorien")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.top, 24)

                    HStack(alignment: .bottom, spacing: 12) {
                        ForEach(categories, id: \.self) { cat in
                            VStack(spacing: 6) {
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(Color.scoonOrange)
                                    .frame(height: 80)
                                Text(cat)
                                    .font(.system(size: 10))
                                    .foregroundColor(Color.scoonTextSecondary)
                                    .multilineTextAlignment(.center)
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 12)

                    Spacer().frame(height: 100)
                }
            }

            NavBarView(selectedTab: $selectedTab)
        }
        .navigationBarHidden(true)
    }
}

private struct StatCard: View {
    let label: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(value)
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(Color.scoonDarker)
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(Color.scoonDarker.opacity(0.6))
                .lineLimit(2)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.scoonCardLight)
        .cornerRadius(14)
    }
}

private struct TopSpotRow: View {
    let name: String
    let views: Int
    let likes: Int
    let saves: Int

    var body: some View {
        HStack {
            Text(name)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.white)
            Spacer()
            HStack(spacing: 14) {
                Label("\(views)v", systemImage: "eye")
                    .font(.system(size: 12))
                    .foregroundColor(Color.scoonTextSecondary)
                Label("\(likes)l", systemImage: "heart")
                    .font(.system(size: 12))
                    .foregroundColor(Color.scoonTextSecondary)
                Label("\(saves)s", systemImage: "bookmark")
                    .font(.system(size: 12))
                    .foregroundColor(Color.scoonTextSecondary)
            }
        }
        .padding(14)
        .background(Color.scoonDark)
        .cornerRadius(10)
    }
}
