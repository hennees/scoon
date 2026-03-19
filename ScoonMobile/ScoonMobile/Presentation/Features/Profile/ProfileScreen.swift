import SwiftUI
import PhotosUI

struct ProfileScreen: View {
    @Environment(AppRouter.self)    private var router
    @Environment(AppContainer.self) private var container
    @State private var vm: ProfileViewModel?
    @State private var avatarPickerItem: PhotosPickerItem?

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
                    // ── Header bar ────────────────────────────────────
                    HStack {
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
                        Spacer()
                        Button(action: { router.navigate(to: .settings) }) {
                            ZStack {
                                Circle().fill(Color.primary.opacity(0.08)).frame(width: 42, height: 42)
                                    .overlay(Circle().stroke(Color.primary.opacity(0.1), lineWidth: 1))
                                Image(systemName: "gearshape.fill")
                                    .font(.system(size: 15))
                                    .foregroundColor(.primary)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 56)

                    if let vm {
                        if vm.isLoading {
                            ProgressView().tint(Color.scoonOrange).padding(.top, 60)
                        } else if let user = vm.user {
                            // ── Avatar + gradient banner ───────────────
                            ZStack(alignment: .bottom) {
                                // Gradient banner
                                LinearGradient(
                                    colors: [Color.scoonOrange.opacity(0.25), Color.scoonOrange.opacity(0.0)],
                                    startPoint: .top, endPoint: .bottom
                                )
                                .frame(height: 100)
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                                .padding(.horizontal, 20)
                                .padding(.top, 12)

                                // Avatar
                                ZStack(alignment: .bottomTrailing) {
                                    Circle()
                                        .fill(Color.scoonDarker)
                                        .frame(width: 88, height: 88)
                                        .overlay(
                                            Circle()
                                                .stroke(Color.scoonOrange.opacity(0.6), lineWidth: 2.5)
                                        )
                                        .overlay(
                                            AsyncImage(url: URL(string: user.avatarURL)) { phase in
                                                switch phase {
                                                case .success(let img): img.resizable().scaledToFill()
                                                default:
                                                    Image(systemName: "person.fill")
                                                        .font(.system(size: 36))
                                                        .foregroundColor(Color.scoonTextSecondary)
                                                }
                                            }
                                            .clipShape(Circle())
                                        )

                                    // Camera badge
                                    PhotosPicker(
                                        selection: $avatarPickerItem,
                                        matching: .images,
                                        photoLibrary: .shared()
                                    ) {
                                        Circle()
                                            .fill(Color.scoonOrange)
                                            .frame(width: 26, height: 26)
                                            .overlay(
                                                Image(systemName: "camera.fill")
                                                    .font(.system(size: 10))
                                                    .foregroundColor(.white)
                                            )
                                            .shadow(color: Color.scoonOrange.opacity(0.5), radius: 4, x: 0, y: 2)
                                    }
                                    .offset(x: 2, y: 2)
                                }
                                .padding(.bottom, -44)
                            }
                            .padding(.top, 16)

                            // ── Name + Bio ────────────────────────────
                            VStack(spacing: 5) {
                                HStack(spacing: 6) {
                                    Text("@\(user.username)")
                                        .font(.system(size: 20, weight: .bold))
                                        .foregroundColor(.primary)
                                    if user.isCreator {
                                        Text("Creator")
                                            .font(.system(size: 11, weight: .bold))
                                            .foregroundColor(.white)
                                            .padding(.horizontal, 8).padding(.vertical, 3)
                                            .background(Color.scoonOrange)
                                            .clipShape(Capsule())
                                    }
                                }
                                .padding(.top, 52)

                                if !user.bio.isEmpty {
                                    Text(user.bio)
                                        .font(.system(size: 14))
                                        .foregroundColor(Color.scoonTextSecondary)
                                        .multilineTextAlignment(.center)
                                        .padding(.horizontal, 40)
                                }
                            }

                            // ── Stats ─────────────────────────────────
                            HStack(spacing: 0) {
                                ProfileStatItem(value: "\(user.postCount)",      label: "Spots")
                                Divider().frame(height: 32).background(Color.primary.opacity(0.12))
                                ProfileStatItem(value: "\(user.followerCount)",  label: "Follower")
                                Divider().frame(height: 32).background(Color.primary.opacity(0.12))
                                ProfileStatItem(value: "\(user.followingCount)", label: "Folgt")
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 20)
                            .background(
                                RoundedRectangle(cornerRadius: 18)
                                    .fill(Color.primary.opacity(0.05))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 18)
                                            .stroke(Color.primary.opacity(0.08), lineWidth: 1)
                                    )
                            )
                            .padding(.horizontal, 20)
                            .padding(.top, 16)

                            // ── Action buttons ────────────────────────
                            HStack(spacing: 10) {
                                Button(action: { router.navigate(to: .editProfile(user)) }) {
                                    Text("Profil bearbeiten")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(.primary)
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 42)
                                        .background(Color.primary.opacity(0.08))
                                        .cornerRadius(12)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(Color.primary.opacity(0.12), lineWidth: 1)
                                        )
                                }
                                if user.isCreator {
                                    Button(action: { router.navigate(to: .insights) }) {
                                        HStack(spacing: 6) {
                                            Image(systemName: "chart.bar.fill")
                                                .font(.system(size: 13))
                                            Text("Dashboard")
                                                .font(.system(size: 14, weight: .semibold))
                                        }
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 42)
                                        .background(Color.scoonOrange)
                                        .cornerRadius(12)
                                        .shadow(color: Color.scoonOrange.opacity(0.35), radius: 8, x: 0, y: 3)
                                    }
                                } else {
                                    Button(action: { router.navigate(to: .becomeCreator) }) {
                                        HStack(spacing: 6) {
                                            Image(systemName: "star.fill")
                                                .font(.system(size: 13))
                                            Text("Werde Creator")
                                                .font(.system(size: 14, weight: .semibold))
                                        }
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 42)
                                        .background(
                                            LinearGradient(
                                                colors: [Color.scoonOrange, Color(red: 1.0, green: 0.55, blue: 0.1)],
                                                startPoint: .leading, endPoint: .trailing
                                            )
                                        )
                                        .cornerRadius(12)
                                        .shadow(color: Color.scoonOrange.opacity(0.35), radius: 8, x: 0, y: 3)
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 12)

                            // ── Tab bar ───────────────────────────────
                            HStack(spacing: 0) {
                                SegmentTabButton(title: "Erkundigt", isActive: vm.activeTab == .explored) {
                                    vm.activeTab = .explored
                                }
                                SegmentTabButton(title: "Gespeichert", isActive: vm.activeTab == .saved) {
                                    vm.activeTab = .saved
                                }
                            }
                            .padding(.top, 20)
                            .padding(.horizontal, 20)

                            // ── Photo grid ────────────────────────────
                            if vm.displayedSpots.isEmpty {
                                VStack(spacing: 12) {
                                    Image(systemName: "photo.on.rectangle.angled")
                                        .font(.system(size: 36))
                                        .foregroundColor(Color.scoonTextSecondary.opacity(0.4))
                                    Text("Noch keine Spots")
                                        .font(.system(size: 15))
                                        .foregroundColor(Color.scoonTextSecondary)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 40)
                            } else {
                                LazyVGrid(columns: gridColumns, spacing: 2) {
                                    ForEach(vm.displayedSpots) { spot in
                                        AsyncImage(url: URL(string: spot.imageURL)) { phase in
                                            switch phase {
                                            case .success(let img): img.resizable().scaledToFill()
                                            default:
                                                Rectangle()
                                                    .fill(Color.primary.opacity(0.07))
                                                    .overlay(
                                                        Image(systemName: "photo")
                                                            .foregroundColor(.white.opacity(0.15))
                                                    )
                                            }
                                        }
                                        .containerRelativeFrame(.horizontal, count: 3, spacing: 2)
                                        .clipped()
                                        .onTapGesture { router.navigate(to: .placeInfo(spot)) }
                                    }
                                }
                                .padding(.top, 2)
                            }
                        }
                    }

                    Spacer().frame(height: 110)
                }
            }
            .refreshable { await vm?.refresh() }
        }
        .toolbar(.hidden, for: .navigationBar)
        .task {
            let viewModel = container.makeProfileViewModel()
            vm = viewModel
            await viewModel.onAppear()
        }
        .onChange(of: avatarPickerItem) { _, item in
            guard item != nil, let user = vm?.user else { return }
            router.navigate(to: .editProfile(user))
            avatarPickerItem = nil
        }
    }
}

// MARK: – Stat Item

private struct ProfileStatItem: View {
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 3) {
            Text(value)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.primary)
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(Color.scoonTextSecondary)
        }
        .frame(maxWidth: .infinity)
    }
}

