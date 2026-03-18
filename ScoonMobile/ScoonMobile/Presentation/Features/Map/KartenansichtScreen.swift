import SwiftUI
import MapKit

struct KartenansichtScreen: View {
    @Environment(AppRouter.self)    private var router
    @Environment(AppContainer.self) private var container
    @State private var vm: MapViewModel?

    @State private var region = MKCoordinateRegion(
        center:            CLLocationCoordinate2D(latitude: 47.0707, longitude: 15.4395),
        latitudinalMeters:  3500,
        longitudinalMeters: 3500
    )
    @State private var selectedSpot: Spot? = nil

    var body: some View {
        ZStack {
            // ── ① Full-screen Map ──────────────────────────────────────
            mapLayer

            // ── ② Top overlay: Search + Category chips ────────────────
            VStack(spacing: 0) {
                topOverlay
                Spacer()
            }

            // ── ③ Right-side FABs ─────────────────────────────────────
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    fabStack
                }
            }
        }
        // ── ④ Persistent bottom sheet ─────────────────────────────────
        .sheet(isPresented: .constant(true)) {
            spotSheetContent
                .presentationDetents([.height(220), .height(420)])
                .presentationDragIndicator(.visible)
                .presentationBackground(.ultraThinMaterial)
                .presentationCornerRadius(24)
                .presentationBackgroundInteraction(.enabled)
                .interactiveDismissDisabled()
        }
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            if vm == nil { vm = container.makeMapViewModel() }
            Task { await vm?.load() }
        }
    }

    // MARK: – Map Layer

    @ViewBuilder
    private var mapLayer: some View {
        if let vm {
            let pins: [SpotPin] = vm.filteredMappableSpots.compactMap { spot in
                guard let lat = spot.latitude, let lng = spot.longitude else { return nil }
                return SpotPin(spot: spot, coord: .init(latitude: lat, longitude: lng))
            }
            Map(coordinateRegion: $region, annotationItems: pins) { pin in
                MapAnnotation(coordinate: pin.coord) {
                    SpotPhotoPin(spot: pin.spot, isSelected: selectedSpot?.id == pin.spot.id)
                        .onTapGesture {
                            withAnimation(.spring(response: 0.32, dampingFraction: 0.7)) {
                                selectedSpot = pin.spot
                            }
                            withAnimation(.easeInOut(duration: 0.55)) {
                                region.center = pin.coord
                            }
                        }
                }
            }
            .ignoresSafeArea()
        } else {
            Map(coordinateRegion: $region).ignoresSafeArea()
        }
    }

    // MARK: – Top Overlay

    private var topOverlay: some View {
        VStack(spacing: 10) {
            // Search bar
            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(Color.scoonOrange)
                TextField("Spot suchen …", text: Binding(
                    get: { vm?.searchText ?? "" },
                    set: { vm?.searchText = $0 }
                ))
                .font(.system(size: 15))
                .foregroundColor(.primary)
                .tint(Color.scoonOrange)
                if vm?.searchText.isEmpty == false {
                    Button(action: { vm?.searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 15))
                            .foregroundColor(.white.opacity(0.4))
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
                    .environment(\.colorScheme, .dark)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.14), lineWidth: 1)
                    )
            )
            .shadow(color: .black.opacity(0.28), radius: 12, x: 0, y: 4)

            // Category filter chips
            if let vm {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        MapCategoryChip(label: "Alle", isActive: vm.selectedCategory == nil) {
                            withAnimation(.spring(response: 0.28)) { vm.selectedCategory = nil }
                        }
                        ForEach(SpotCategory.allCases, id: \.self) { cat in
                            MapCategoryChip(label: cat.rawValue, isActive: vm.selectedCategory == cat) {
                                withAnimation(.spring(response: 0.28)) {
                                    vm.selectedCategory = (vm.selectedCategory == cat) ? nil : cat
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 2)
                }
            }
        }
        .padding(.top, 56)
        .padding(.horizontal, 16)
    }

    // MARK: – FABs

    private var fabStack: some View {
        VStack(spacing: 12) {
            Button(action: { router.navigate(to: .addPhotoSpot) }) {
                ZStack {
                    Circle()
                        .fill(Color.scoonOrange)
                        .frame(width: 54, height: 54)
                        .shadow(color: Color.scoonOrange.opacity(0.55), radius: 14, x: 0, y: 5)
                    Image(systemName: "plus")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(.white)
                }
            }
        }
        .padding(.trailing, 16)
        .padding(.bottom, 240)
    }

    // MARK: – Bottom Sheet Content

    private var spotSheetContent: some View {
        VStack(spacing: 0) {
            if let vm {
                // Header
                HStack {
                    if vm.isLoading {
                        HStack(spacing: 8) {
                            ProgressView().tint(Color.scoonOrange).scaleEffect(0.8)
                            Text("Spots werden geladen…")
                                .font(.system(size: 15))
                                .foregroundColor(.secondary)
                        }
                    } else {
                        let count = vm.filteredMappableSpots.count
                        Text("\(count) Spot\(count == 1 ? "" : "s")")
                            .font(.system(size: 17, weight: .bold))
                            .foregroundColor(.primary)
                    }
                    Spacer()
                    if vm.selectedCategory != nil {
                        Button("Zurücksetzen") {
                            withAnimation(.spring(response: 0.28)) {
                                vm.selectedCategory = nil
                                selectedSpot = nil
                            }
                        }
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(Color.scoonOrange)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 4)
                .padding(.bottom, 14)

                if vm.filteredMappableSpots.isEmpty && !vm.isLoading {
                    // Empty state
                    VStack(spacing: 12) {
                        Image(systemName: "map.fill")
                            .font(.system(size: 34))
                            .foregroundColor(Color.scoonOrange.opacity(0.35))
                        Text("Keine Spots gefunden")
                            .font(.system(size: 15))
                            .foregroundColor(.secondary)
                        if vm.selectedCategory != nil || !vm.searchText.isEmpty {
                            Button("Filter zurücksetzen") {
                                vm.selectedCategory = nil
                                vm.searchText = ""
                            }
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(Color.scoonOrange)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 32)
                } else {
                    // Spot cards with auto-scroll to selected
                    ScrollViewReader { proxy in
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(vm.filteredMappableSpots) { spot in
                                    MapSpotCard(
                                        spot:       spot,
                                        isSelected: selectedSpot?.id == spot.id,
                                        onDetail:   { router.navigate(to: .placeInfo(spot)) }
                                    )
                                    .id(spot.id)
                                    .onTapGesture {
                                        withAnimation(.spring(response: 0.32, dampingFraction: 0.7)) {
                                            selectedSpot = spot
                                        }
                                        if let lat = spot.latitude, let lng = spot.longitude {
                                            withAnimation(.easeInOut(duration: 0.55)) {
                                                region.center = .init(latitude: lat, longitude: lng)
                                            }
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.bottom, 12)
                        }
                        .onChange(of: selectedSpot) { _, spot in
                            guard let spot else { return }
                            withAnimation(.spring(response: 0.4)) {
                                proxy.scrollTo(spot.id, anchor: .center)
                            }
                        }
                    }
                }
            }
        }
        .padding(.top, 4)
    }
}

// MARK: – Spot Photo Pin

private struct SpotPhotoPin: View {
    let spot:       Spot
    let isSelected: Bool

    private var ringSize:  CGFloat { isSelected ? 56 : 44 }
    private var photoSize: CGFloat { isSelected ? 46 : 36 }

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                // Glow halo when selected
                if isSelected {
                    Circle()
                        .fill(Color.scoonOrange.opacity(0.3))
                        .frame(width: ringSize + 18, height: ringSize + 18)
                        .blur(radius: 8)
                }

                // Outer ring (white = default, orange = selected)
                Circle()
                    .fill(isSelected ? Color.scoonOrange : Color.white)
                    .frame(width: ringSize, height: ringSize)
                    .shadow(
                        color: isSelected ? Color.scoonOrange.opacity(0.55) : Color.black.opacity(0.28),
                        radius: isSelected ? 14 : 6,
                        x: 0, y: 2
                    )

                // Spot photo
                AsyncImage(url: URL(string: spot.imageURL)) { phase in
                    switch phase {
                    case .success(let img):
                        img.resizable().scaledToFill()
                    default:
                        Circle()
                            .fill(Color.scoonOrange.opacity(0.15))
                            .overlay(
                                Image(systemName: "camera.fill")
                                    .font(.system(size: photoSize * 0.38))
                                    .foregroundColor(Color.scoonOrange)
                            )
                    }
                }
                .frame(width: photoSize, height: photoSize)
                .clipShape(Circle())
            }

            // Pointer triangle
            PinTriangle()
                .fill(isSelected ? Color.scoonOrange : Color.white)
                .frame(width: 10, height: 7)
                .shadow(color: .black.opacity(0.18), radius: 2, x: 0, y: 1)
        }
        .scaleEffect(isSelected ? 1.12 : 1.0)
        .animation(.spring(response: 0.28, dampingFraction: 0.65), value: isSelected)
    }
}

// MARK: – Map Spot Card

private struct MapSpotCard: View {
    let spot:       Spot
    let isSelected: Bool
    let onDetail:   () -> Void

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            AsyncImage(url: URL(string: spot.imageURL)) { phase in
                switch phase {
                case .success(let img):
                    img.resizable().scaledToFill()
                default:
                    Rectangle()
                        .fill(Color.primary.opacity(0.1))
                        .overlay(
                            Image(systemName: "photo")
                                .font(.system(size: 28))
                                .foregroundColor(.white.opacity(0.2))
                        )
                }
            }
            .frame(width: 160, height: 210)
            .clipped()

            // Gradient overlay
            LinearGradient(
                colors: [.clear, .black.opacity(0.82)],
                startPoint: .center, endPoint: .bottom
            )

            // Bottom info
            VStack(alignment: .leading, spacing: 5) {
                Text(spot.category.rawValue)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 8).padding(.vertical, 3)
                    .background(Color.scoonOrange.opacity(0.88))
                    .clipShape(Capsule())

                Text(spot.name)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                    .lineLimit(1)

                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 9))
                        .foregroundColor(Color.scoonOrange)
                    Text(String(format: "%.1f", spot.rating))
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.white.opacity(0.9))
                    if let dist = spot.distance {
                        Text("· \(dist)")
                            .font(.system(size: 11))
                            .foregroundColor(.white.opacity(0.55))
                    }
                }
            }
            .padding(12)
        }
        .frame(width: 160, height: 210)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(isSelected ? Color.scoonOrange : Color.clear, lineWidth: 2.5)
        )
        .shadow(
            color: isSelected ? Color.scoonOrange.opacity(0.45) : Color.black.opacity(0.22),
            radius: isSelected ? 14 : 7,
            x: 0, y: 4
        )
        // Detail arrow button — top right
        .overlay(alignment: .topTrailing) {
            Button(action: onDetail) {
                Image(systemName: "arrow.up.right")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 30, height: 30)
                    .background(Color.black.opacity(0.55))
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.white.opacity(0.15), lineWidth: 1))
            }
            .padding(8)
        }
    }
}

// MARK: – Category Chip

private struct MapCategoryChip: View {
    let label:    String
    let isActive: Bool
    let action:   () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 13, weight: isActive ? .semibold : .regular))
                .foregroundColor(isActive ? .black : .white)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(isActive
                              ? AnyShapeStyle(Color.scoonOrange)
                              : AnyShapeStyle(.ultraThinMaterial))
                        .environment(\.colorScheme, .dark)
                )
                .overlay(
                    Capsule()
                        .stroke(
                            isActive ? Color.clear : Color.white.opacity(0.18),
                            lineWidth: 1
                        )
                )
                .shadow(
                    color: isActive ? Color.scoonOrange.opacity(0.4) : Color.black.opacity(0.18),
                    radius: isActive ? 8 : 3,
                    x: 0, y: 2
                )
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.25, dampingFraction: 0.7), value: isActive)
    }
}

// MARK: – Helpers

private struct SpotPin: Identifiable {
    var id:    UUID { spot.id }
    let spot:  Spot
    let coord: CLLocationCoordinate2D
}

private struct PinTriangle: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        p.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        p.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        p.closeSubpath()
        return p
    }
}
