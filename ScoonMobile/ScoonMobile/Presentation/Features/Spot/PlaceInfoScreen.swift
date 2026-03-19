import SwiftUI

// MARK: – Creator photo model

struct SpotPhoto: Identifiable {
    let id          = UUID()
    let imageURL:   String
    let creatorName:   String
    let creatorHandle: String
    let avatarURL:     String
}

// MARK: – Main screen

struct PlaceInfoScreen: View {
    @State private var spot: Spot

    @Environment(AppRouter.self)    private var router
    @Environment(AppContainer.self) private var container

    @State private var isTogglingFav    = false
    @State private var appeared         = false
    @State private var selectedIndex:   Int? = nil

    init(spot: Spot) { self._spot = State(initialValue: spot) }

    // Demo multi-creator photos — swap for real API data
    private var photos: [SpotPhoto] {[
        SpotPhoto(imageURL: spot.imageURL, creatorName: "Maria K.",    creatorHandle: "@mariaphoto",   avatarURL: "https://i.pravatar.cc/150?img=5"),
        SpotPhoto(imageURL: spot.imageURL, creatorName: "Thomas H.",   creatorHandle: "@thomas.vis",   avatarURL: "https://i.pravatar.cc/150?img=12"),
        SpotPhoto(imageURL: spot.imageURL, creatorName: "Anna W.",     creatorHandle: "@anna_lens",    avatarURL: "https://i.pravatar.cc/150?img=9"),
        SpotPhoto(imageURL: spot.imageURL, creatorName: "Lukas M.",    creatorHandle: "@lukas.photo",  avatarURL: "https://i.pravatar.cc/150?img=15"),
        SpotPhoto(imageURL: spot.imageURL, creatorName: "Sophie T.",   creatorHandle: "@sophiet",      avatarURL: "https://i.pravatar.cc/150?img=22"),
        SpotPhoto(imageURL: spot.imageURL, creatorName: "Felix R.",    creatorHandle: "@felixr_graz",  avatarURL: "https://i.pravatar.cc/150?img=33"),
    ]}

    var body: some View {
        ZStack {
            Color.scoonDarker.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    topCollage
                    infoSection
                    photoGrid
                    Spacer().frame(height: 110)
                }
            }
            .ignoresSafeArea(edges: .top)

            floatingBar

            // Full-screen photo viewer overlay
            if let idx = selectedIndex {
                PhotoViewer(photos: photos, startIndex: idx) {
                    withAnimation(.easeInOut(duration: 0.25)) { selectedIndex = nil }
                }
                .zIndex(10)
                .transition(.opacity)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .animation(.easeInOut(duration: 0.25), value: selectedIndex)
        .onAppear { appeared = true }
    }

    // MARK: – Top collage

    private var topCollage: some View {
        let h: CGFloat = UIScreen.main.bounds.width * 0.9
        return ZStack(alignment: .bottom) {
            if photos.count >= 3 {
                // Instagram-style: 1 big left + 2 stacked right
                HStack(spacing: 2) {
                    PhotoThumb(photo: photos[0]) { selectedIndex = 0 }
                        .frame(width: UIScreen.main.bounds.width * 0.60 - 1, height: h)

                    VStack(spacing: 2) {
                        PhotoThumb(photo: photos[1]) { selectedIndex = 1 }
                            .frame(height: h / 2 - 1)
                        PhotoThumb(photo: photos[2]) { selectedIndex = 2 }
                            .frame(height: h / 2 - 1)
                    }
                    .frame(width: UIScreen.main.bounds.width * 0.40 - 1)
                }
                .frame(height: h)
            } else {
                PhotoThumb(photo: photos[0]) { selectedIndex = 0 }
                    .frame(maxWidth: .infinity).frame(height: h)
            }

            // Gradient into info section
            LinearGradient(
                colors: [.clear, Color.scoonDarker.opacity(0.9)],
                startPoint: .init(x: 0.5, y: 0.6), endPoint: .bottom
            )
            .allowsHitTesting(false)

            // Top scrim for floating bar
            VStack {
                LinearGradient(
                    colors: [.black.opacity(0.45), .clear],
                    startPoint: .top, endPoint: .bottom
                )
                .frame(height: 120)
                Spacer()
            }
            .allowsHitTesting(false)
        }
        .frame(height: h)
        .clipped()
    }

    // MARK: – Info section

    private var infoSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Name + rating
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(spot.name)
                        .font(.system(size: 26, weight: .bold))
                        .foregroundColor(.primary)
                    HStack(spacing: 5) {
                        Image(systemName: "mappin")
                            .font(.system(size: 10))
                            .foregroundColor(.scoonOrange)
                        Text(spot.location)
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                    }
                }
                Spacer()
                // Fav button
                Button(action: { Task { await toggleFavorite() } }) {
                    ZStack {
                        Circle()
                            .fill(spot.isFavorite ? Color.scoonOrange.opacity(0.15) : Color.primary.opacity(0.08))
                            .frame(width: 46, height: 46)
                            .overlay(Circle().stroke(
                                spot.isFavorite ? Color.scoonOrange.opacity(0.4) : Color.primary.opacity(0.1), lineWidth: 1))
                        if isTogglingFav {
                            ProgressView().tint(.scoonOrange).scaleEffect(0.7)
                        } else {
                            Image(systemName: spot.isFavorite ? "heart.fill" : "heart")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(spot.isFavorite ? .scoonOrange : .primary)
                        }
                    }
                }
            }
            .padding(.horizontal, 20).padding(.top, 16)
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 8)
            .animation(.easeOut(duration: 0.35).delay(0.05), value: appeared)

            // Stats row
            HStack(spacing: 16) {
                StatBadge(value: "\(photos.count)", label: "Fotos")
                StatBadge(value: "3",               label: "Creator")
                StatBadge(value: String(format: "%.1f", spot.rating), label: "Rating", accentColor: .scoonOrange)
                Spacer()
                Text(spot.category.rawValue)
                    .font(.system(size: 11, weight: .semibold)).lineLimit(1)
                    .foregroundColor(.scoonOrange)
                    .padding(.horizontal, 10).padding(.vertical, 5)
                    .background(Color.scoonOrange.opacity(0.1))
                    .clipShape(Capsule())
                    .overlay(Capsule().stroke(Color.scoonOrange.opacity(0.28), lineWidth: 1))
            }
            .padding(.horizontal, 20).padding(.top, 14)
            .opacity(appeared ? 1 : 0)
            .animation(.easeOut(duration: 0.35).delay(0.08), value: appeared)

            // Action row
            HStack(spacing: 10) {
                ActionBtn(icon: "map.fill",             label: "Karte")   { router.switchTab(to: .map) }
                ActionBtn(icon: "square.and.arrow.up",  label: "Teilen")  { shareSpot() }
                ActionBtn(icon: "plus",                 label: "Dein Foto", isPrimary: true) {
                    router.navigate(to: .addPhotoToSpot(spot))
                }
            }
            .padding(.horizontal, 20).padding(.top, 14)
            .opacity(appeared ? 1 : 0)
            .animation(.easeOut(duration: 0.35).delay(0.12), value: appeared)

            // Description
            Text(spot.description)
                .font(.system(size: 14))
                .foregroundColor(.secondary)
                .lineSpacing(4)
                .padding(.horizontal, 20).padding(.top, 16)
                .opacity(appeared ? 1 : 0)
                .animation(.easeOut(duration: 0.35).delay(0.15), value: appeared)
        }
    }

    // MARK: – Photo grid

    private var photoGrid: some View {
        let cols = Array(repeating: GridItem(.flexible(), spacing: 2), count: 3)
        return VStack(alignment: .leading, spacing: 0) {
            // Section header
            HStack {
                Text("Alle Fotos")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.primary)
                Text("(\(photos.count))")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                Spacer()
                Text("Neueste")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.scoonOrange)
            }
            .padding(.horizontal, 20).padding(.vertical, 16)
            .opacity(appeared ? 1 : 0)
            .animation(.easeOut(duration: 0.35).delay(0.18), value: appeared)

            // Grid
            LazyVGrid(columns: cols, spacing: 2) {
                ForEach(photos.indices, id: \.self) { idx in
                    PhotoGridCell(photo: photos[idx]) { selectedIndex = idx }
                        .opacity(appeared ? 1 : 0)
                        .animation(.easeOut(duration: 0.4).delay(0.20 + Double(idx) * 0.04), value: appeared)
                }
                // Add photo cell
                AddPhotoCell { router.navigate(to: .addPhotoToSpot(spot)) }
                    .opacity(appeared ? 1 : 0)
                    .animation(.easeOut(duration: 0.4).delay(0.20 + Double(photos.count) * 0.04), value: appeared)
            }
        }
        .padding(.top, 8)
    }

    // MARK: – Floating bar

    private var floatingBar: some View {
        VStack {
            HStack {
                Button(action: { router.navigateBack() }) {
                    ZStack {
                        Circle().fill(.ultraThinMaterial)
                            .environment(\.colorScheme, .dark)
                            .frame(width: 40, height: 40)
                        Image(systemName: "arrow.left")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                    }
                }
                Spacer()
                Button(action: { router.switchToHome() }) {
                    Text("scoon")
                        .font(.system(size: 18, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.5), radius: 4)
                }
                .buttonStyle(.plain)
                Spacer()
                Button(action: { shareSpot() }) {
                    ZStack {
                        Circle().fill(.ultraThinMaterial)
                            .environment(\.colorScheme, .dark)
                            .frame(width: 40, height: 40)
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 14))
                            .foregroundColor(.white)
                    }
                }
            }
            .padding(.horizontal, 20).padding(.top, 56)
            Spacer()
        }
        .allowsHitTesting(true)
    }

    // MARK: – Actions

    private func toggleFavorite() async {
        guard !isTogglingFav else { return }
        isTogglingFav = true
        spot.isFavorite.toggle()
        do {
            try await container.toggleFavoriteUseCase.execute(spotID: spot.id)
        } catch {
            spot.isFavorite.toggle()
        }
        isTogglingFav = false
    }

    private func shareSpot() {
        let text = "Schau dir \(spot.name) auf scoon an! \(spot.location)"
        let av = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let root = scene.windows.first?.rootViewController {
            root.present(av, animated: true)
        }
    }
}

// MARK: – Full-screen photo viewer

struct PhotoViewer: View {
    let photos:       [SpotPhoto]
    let startIndex:   Int
    let onDismiss:    () -> Void

    @State private var currentIndex: Int
    @State private var dragOffset: CGSize = .zero
    @GestureState private var isDragging = false

    init(photos: [SpotPhoto], startIndex: Int, onDismiss: @escaping () -> Void) {
        self.photos = photos
        self.startIndex = startIndex
        self.onDismiss = onDismiss
        self._currentIndex = State(initialValue: startIndex)
    }

    var body: some View {
        ZStack(alignment: .top) {
            Color.black.ignoresSafeArea()

            TabView(selection: $currentIndex) {
                ForEach(photos.indices, id: \.self) { idx in
                    AsyncImage(url: URL(string: photos[idx].imageURL)) { phase in
                        switch phase {
                        case .success(let img):
                            img.resizable()
                                .scaledToFit()
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        default:
                            Color.black
                                .overlay(ProgressView().tint(.white))
                        }
                    }
                    .tag(idx)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .ignoresSafeArea()

            // Bottom creator bar
            VStack {
                Spacer()
                HStack(spacing: 12) {
                    AsyncImage(url: URL(string: photos[currentIndex].avatarURL)) { phase in
                        switch phase {
                        case .success(let img): img.resizable().scaledToFill()
                        default: Color.scoonOrange.opacity(0.4)
                        }
                    }
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.white.opacity(0.5), lineWidth: 1.5))

                    VStack(alignment: .leading, spacing: 2) {
                        Text(photos[currentIndex].creatorName)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.white)
                        Text(photos[currentIndex].creatorHandle)
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.65))
                    }
                    Spacer()

                    // Page counter
                    Text("\(currentIndex + 1) / \(photos.count)")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.white.opacity(0.7))
                        .padding(.horizontal, 12).padding(.vertical, 6)
                        .background(Color.white.opacity(0.12))
                        .clipShape(Capsule())
                }
                .padding(.horizontal, 20).padding(.bottom, 48).padding(.top, 20)
                .background(
                    LinearGradient(colors: [.clear, .black.opacity(0.7)], startPoint: .top, endPoint: .bottom)
                )
            }
            .ignoresSafeArea(edges: .bottom)

            // Top bar
            HStack {
                Button(action: onDismiss) {
                    ZStack {
                        Circle().fill(.ultraThinMaterial).environment(\.colorScheme, .dark).frame(width: 38, height: 38)
                        Image(systemName: "xmark").font(.system(size: 14, weight: .semibold)).foregroundColor(.white)
                    }
                }
                Spacer()
                // Dot indicators
                HStack(spacing: 5) {
                    ForEach(photos.indices, id: \.self) { idx in
                        Circle()
                            .fill(idx == currentIndex ? Color.white : Color.white.opacity(0.35))
                            .frame(width: idx == currentIndex ? 7 : 5, height: idx == currentIndex ? 7 : 5)
                            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: currentIndex)
                    }
                }
                Spacer()
                // Invisible balance
                Circle().fill(.clear).frame(width: 38, height: 38)
            }
            .padding(.horizontal, 20).padding(.top, 56)
        }
        .offset(y: dragOffset.height)
        .gesture(
            DragGesture()
                .onChanged { val in
                    if val.translation.height > 0 { dragOffset = val.translation }
                }
                .onEnded { val in
                    if val.translation.height > 100 {
                        onDismiss()
                    } else {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) { dragOffset = .zero }
                    }
                }
        )
    }
}

// MARK: – Photo thumbnail (collage)

private struct PhotoThumb: View {
    let photo:  SpotPhoto
    let onTap:  () -> Void

    var body: some View {
        Button(action: onTap) {
            ZStack(alignment: .bottomLeading) {
                AsyncImage(url: URL(string: photo.imageURL)) { phase in
                    switch phase {
                    case .success(let img): img.resizable().scaledToFill()
                    default: Color.scoonDarker
                    }
                }
                .clipped()

                // Creator micro-badge
                HStack(spacing: 5) {
                    AsyncImage(url: URL(string: photo.avatarURL)) { phase in
                        switch phase {
                        case .success(let img): img.resizable().scaledToFill()
                        default: Color.scoonOrange.opacity(0.4)
                        }
                    }
                    .frame(width: 22, height: 22)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.white.opacity(0.6), lineWidth: 1))

                    Text(photo.creatorHandle)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.white.opacity(0.85))
                        .lineLimit(1)
                }
                .padding(.horizontal, 8).padding(.vertical, 6)
                .background(
                    Capsule().fill(.ultraThinMaterial).environment(\.colorScheme, .dark).opacity(0.8)
                )
                .padding(8)
            }
        }
        .buttonStyle(.plain)
        .clipped()
    }
}

// MARK: – Photo grid cell

private struct PhotoGridCell: View {
    let photo:  SpotPhoto
    let onTap:  () -> Void

    private let side = (UIScreen.main.bounds.width - 4) / 3

    var body: some View {
        Button(action: onTap) {
            ZStack(alignment: .bottomLeading) {
                AsyncImage(url: URL(string: photo.imageURL)) { phase in
                    switch phase {
                    case .success(let img): img.resizable().scaledToFill()
                    default: Color.scoonDarker
                    }
                }
                .frame(width: side, height: side)
                .clipped()

                // Avatar badge
                AsyncImage(url: URL(string: photo.avatarURL)) { phase in
                    switch phase {
                    case .success(let img): img.resizable().scaledToFill()
                    default: Color.scoonOrange.opacity(0.4)
                    }
                }
                .frame(width: 22, height: 22)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.white.opacity(0.7), lineWidth: 1.5))
                .padding(5)
            }
            .frame(width: side, height: side)
        }
        .buttonStyle(.plain)
    }
}

// MARK: – Add photo cell

private struct AddPhotoCell: View {
    let onTap: () -> Void
    private let side = (UIScreen.main.bounds.width - 4) / 3

    var body: some View {
        Button(action: onTap) {
            ZStack {
                Color.scoonOrange.opacity(0.06)
                RoundedRectangle(cornerRadius: 0)
                    .stroke(Color.scoonOrange.opacity(0.2),
                            style: StrokeStyle(lineWidth: 1.5, dash: [6]))

                VStack(spacing: 7) {
                    ZStack {
                        Circle().fill(Color.scoonOrange).frame(width: 36, height: 36)
                        Image(systemName: "camera.fill")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    Text("Dein Foto")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.scoonOrange)
                }
            }
            .frame(width: side, height: side)
        }
        .buttonStyle(.plain)
    }
}

// MARK: – Stat badge

private struct StatBadge: View {
    let value:       String
    let label:       String
    var accentColor: Color = .primary

    var body: some View {
        VStack(spacing: 1) {
            Text(value)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(accentColor)
            Text(label)
                .font(.system(size: 11))
                .foregroundColor(.secondary)
        }
    }
}

// MARK: – Action button

private struct ActionBtn: View {
    let icon:       String
    let label:      String
    var isPrimary:  Bool = false
    let action:     () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon).font(.system(size: 12))
                Text(label).font(.system(size: 13, weight: .semibold))
            }
            .foregroundColor(isPrimary ? .white : .primary)
            .frame(maxWidth: .infinity).frame(height: 40)
            .background(isPrimary ? Color.scoonOrange : Color.primary.opacity(0.07))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isPrimary ? Color.clear : Color.primary.opacity(0.1), lineWidth: 1)
            )
            .shadow(color: isPrimary ? Color.scoonOrange.opacity(0.35) : .clear, radius: 8, x: 0, y: 3)
        }
    }
}
