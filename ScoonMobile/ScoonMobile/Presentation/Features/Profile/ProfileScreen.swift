import SwiftUI

// Design: 453:453 – Profile
struct ProfileScreen: View {
    @Environment(AppRouter.self)    private var router
    @Environment(AppContainer.self) private var container
    @State private var vm: ProfileViewModel?

    @State private var selectedTab = NavTab.profile

    private let gridColumns = [
        GridItem(.flexible(), spacing: 2),
        GridItem(.flexible(), spacing: 2),
        GridItem(.flexible(), spacing: 2),
    ]

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.scoonDarker.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // ── Header ────────────────────────────────────────
                    HStack {
                        Button(action: { router.navigateBack() }) {
                            Image(systemName: "arrow.left")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(Color.scoonOrange)
                        }
                        Spacer()
                        Button(action: { router.navigate(to: .settings) }) {
                            ZStack {
                                Circle().fill(Color.white.opacity(0.07)).frame(width: 40, height: 40)
                                Image(systemName: "gearshape.fill")
                                    .font(.system(size: 15))
                                    .foregroundColor(.white)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 56)

                    if let vm {
                        if vm.isLoading {
                            ProgressView().tint(Color.scoonOrange).padding(.top, 60)
                        } else if let user = vm.user {
                            // ── Avatar ────────────────────────────────
                            ZStack(alignment: .bottomTrailing) {
                                Circle()
                                    .fill(Color.white.opacity(0.06))
                                    .frame(width: 90, height: 90)
                                    .overlay(
                                        AsyncImage(url: URL(string: user.avatarURL)) { phase in
                                            switch phase {
                                            case .success(let img): img.resizable().scaledToFill()
                                            default:
                                                Image(systemName: "person.fill")
                                                    .font(.system(size: 38))
                                                    .foregroundColor(Color.scoonTextSecondary)
                                            }
                                        }
                                        .clipShape(Circle())
                                    )
                                Circle()
                                    .fill(Color.scoonOrange)
                                    .frame(width: 26, height: 26)
                                    .overlay(
                                        Image(systemName: "camera.fill")
                                            .font(.system(size: 10))
                                            .foregroundColor(.white)
                                    )
                                    .offset(x: 2, y: 2)
                            }
                            .padding(.top, 20)

                            // ── Name + Bio ────────────────────────────
                            Text(user.username)
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.top, 12)

                            Text(user.bio)
                                .font(.system(size: 14))
                                .foregroundColor(Color.scoonTextSecondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 40)
                                .padding(.top, 6)

                            // ── Stats ─────────────────────────────────
                            HStack(spacing: 0) {
                                ProfileStatItem(value: "\(user.postCount)",      label: "Beiträge")
                                Rectangle().fill(Color.white.opacity(0.1)).frame(width: 1, height: 30)
                                ProfileStatItem(value: "\(user.followerCount)",  label: "Abonnenten")
                                Rectangle().fill(Color.white.opacity(0.1)).frame(width: 1, height: 30)
                                ProfileStatItem(value: "\(user.followingCount)", label: "Abonniert")
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 20)

                            // ── Edit button ───────────────────────────
                            Button(action: {}) {
                                Text("Profil bearbeiten")
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(Color.scoonOrange)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 44)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color.scoonOrange, lineWidth: 1.5)
                                    )
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 16)

                            // ── Tab bar ───────────────────────────────
                            HStack(spacing: 0) {
                                ProfileTabButton(title: "Erkundigt", isActive: vm.activeTab == .explored) {
                                    vm.activeTab = .explored
                                }
                                ProfileTabButton(title: "Gespeichert", isActive: vm.activeTab == .saved) {
                                    vm.activeTab = .saved
                                }
                            }
                            .padding(.top, 16)

                            // ── Photo grid ────────────────────────────
                            LazyVGrid(columns: gridColumns, spacing: 2) {
                                ForEach(vm.displayedSpots) { spot in
                                    AsyncImage(url: URL(string: spot.imageURL)) { phase in
                                        switch phase {
                                        case .success(let img): img.resizable().scaledToFill()
                                        default: Rectangle().fill(Color.white.opacity(0.06))
                                        }
                                    }
                                    .containerRelativeFrame(.horizontal, count: 3, spacing: 2)
                                    .clipped()
                                }
                            }
                            .padding(.top, 2)
                        }
                    }

                    Spacer().frame(height: 100)
                }
            }

            NavBarView(selectedTab: $selectedTab)
        }
        .navigationBarHidden(true)
        .task {
            let viewModel = container.makeProfileViewModel()
            vm = viewModel
            await viewModel.onAppear()
        }
    }
}

// MARK: – Stat Item

private struct ProfileStatItem: View {
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

// MARK: – Tab Button

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
        .animation(.spring(response: 0.25, dampingFraction: 0.7), value: isActive)
    }
}
