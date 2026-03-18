import SwiftUI
import MapKit
import CoreLocation
import Combine
import UIKit

struct KartenansichtScreen: View {
    @Environment(AppRouter.self)    private var router
    @Environment(AppContainer.self) private var container
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var vm: MapViewModel?

    @StateObject private var locationService = MapLocationService()

    @State private var region = MKCoordinateRegion(
        center:            CLLocationCoordinate2D(latitude: 47.0707, longitude: 15.4395),
        latitudinalMeters:  3500,
        longitudinalMeters: 3500
    )
    @State private var selectedSpot: Spot?
    @State private var panelState: PanelState = .compact
    @State private var nearbyReloadTask: Task<Void, Never>?
    @State private var pendingCenterOnUserFix = false
    @State private var focusedClusterSpotIDs: Set<UUID> = []
    @State private var isShowingFilterSheet = false
    @State private var showSystemPOI = false

    var body: some View {
        ZStack(alignment: .bottom) {
            mapLayer

            VStack(spacing: 0) {
                topOverlay
                Spacer()
            }

            HStack {
                Spacer()
                fabStack
            }

            bottomPanel

            if panelState == .hidden {
                reopenPanelButton
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            if vm == nil { vm = container.makeMapViewModel() }
            vm?.updateViewport(region: region)
            locationService.requestAuthorizationIfNeeded()
            Task { await vm?.load(force: true) }
        }
        .onChange(of: regionSnapshot) { _, _ in
            vm?.updateViewport(region: region)
            scheduleNearbyReload()
        }
        .onChange(of: vm?.visibleFilteredSpots.map(\.id)) { _, ids in
            guard let selected = selectedSpot, let ids, !ids.contains(selected.id) else { return }
            selectedSpot = nil
        }
        .onReceive(NotificationCenter.default.publisher(for: .mapCitySelected)) { notification in
            guard
                let userInfo = notification.userInfo,
                let lat = userInfo["lat"] as? Double,
                let lon = userInfo["lon"] as? Double
            else {
                recenterOnUser()
                return
            }

            withAnimation(.easeInOut(duration: 0.45)) {
                region.center = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                region.span = MKCoordinateSpan(latitudeDelta: 0.06, longitudeDelta: 0.06)
            }
            panelState = .compact
            scheduleNearbyReload()
        }
        .onReceive(locationService.$lastLocation) { location in
            guard pendingCenterOnUserFix, let location else { return }
            pendingCenterOnUserFix = false
            withAnimation(.easeInOut(duration: 0.35)) {
                region.center = location.coordinate
                region.span = MKCoordinateSpan(latitudeDelta: 0.025, longitudeDelta: 0.025)
            }
            scheduleNearbyReload()
        }
    }

    private var regionSnapshot: RegionSnapshot {
        RegionSnapshot(
            lat: region.center.latitude,
            lon: region.center.longitude,
            latDelta: region.span.latitudeDelta,
            lonDelta: region.span.longitudeDelta
        )
    }

    @ViewBuilder
    private var mapLayer: some View {
        if let vm {
            let pins = clusteredPins(for: vm.visibleFilteredSpots)

            Map(
                coordinateRegion: $region,
                interactionModes: .all,
                showsUserLocation: true,
                annotationItems: pins
            ) { pin in
                MapAnnotation(coordinate: pin.coordinate) {
                    Group {
                        if pin.isCluster {
                            ClusterPinView(count: pin.spots.count)
                        } else {
                            SpotPhotoPin(spot: pin.primarySpot, isSelected: selectedSpot?.id == pin.primarySpot.id)
                        }
                    }
                        .onTapGesture {
                            if pin.isCluster {
                                Haptics.impact(.medium)
                                openCluster(pin)
                            } else {
                                Haptics.impact(.light)
                                focusedClusterSpotIDs.removeAll()
                                focus(on: pin.primarySpot)
                            }
                        }
                }
            }
            .mapStyle(
                .standard(
                    elevation: .flat,
                    pointsOfInterest: showSystemPOI ? .all : [],
                    showsTraffic: false
                )
            )
            .ignoresSafeArea()
        } else {
            Map(coordinateRegion: $region)
                .mapStyle(
                    .standard(
                        elevation: .flat,
                        pointsOfInterest: showSystemPOI ? .all : [],
                        showsTraffic: false
                    )
                )
                .ignoresSafeArea()
        }
    }

    private var topOverlay: some View {
        VStack(spacing: 12) {
            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(Color.scoonOrange)

                TextField("Spot oder Ort suchen", text: Binding(
                    get: { vm?.searchText ?? "" },
                    set: { vm?.searchText = $0 }
                ))
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.primary)
                .tint(Color.scoonOrange)

                if vm?.searchText.isEmpty == false {
                    Button(action: { vm?.searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 15))
                            .foregroundColor(.white.opacity(0.45))
                    }
                    .buttonStyle(.plain)
                }

                Button(action: { router.navigate(to: .ortSuche) }) {
                    Image(systemName: "mappin.and.ellipse")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.black)
                        .frame(width: 32, height: 32)
                        .background(Color.scoonOrange)
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Ort waehlen")

                Button(action: {
                    Haptics.impact(.light)
                    showSystemPOI.toggle()
                }) {
                    Image(systemName: showSystemPOI ? "building.2.crop.circle.fill" : "building.2.crop.circle")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(showSystemPOI ? .black : .white)
                        .frame(width: 32, height: 32)
                        .background(showSystemPOI ? Color.scoonOrange : Color.white.opacity(0.08))
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Geschaefte ein- oder ausblenden")
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 11)
            .background(
                RoundedRectangle(cornerRadius: 17)
                    .fill(.ultraThinMaterial)
                    .environment(\.colorScheme, .dark)
                    .overlay(
                        RoundedRectangle(cornerRadius: 17)
                            .stroke(Color.white.opacity(0.16), lineWidth: 1)
                    )
            )
            .shadow(color: .black.opacity(0.28), radius: 14, x: 0, y: 5)

            if let vm {
                let quickCategories = prioritizedCategories(for: vm)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        MapCategoryChip(
                            label: "Alle",
                            isActive: vm.selectedCategory == nil
                        ) {
                            withAnimation(.spring(response: 0.28, dampingFraction: 0.75)) {
                                vm.selectedCategory = nil
                            }
                        }

                        ForEach(quickCategories, id: \.self) { cat in
                            MapCategoryChip(
                                label: categoryLabel(for: cat, in: vm),
                                isActive: vm.selectedCategory == cat
                            ) {
                                withAnimation(.spring(response: 0.28, dampingFraction: 0.75)) {
                                    vm.selectedCategory = (vm.selectedCategory == cat) ? nil : cat
                                }
                            }
                        }

                        Button(action: { isShowingFilterSheet = true }) {
                            HStack(spacing: 6) {
                                Image(systemName: "line.3.horizontal.decrease.circle")
                                    .font(.system(size: 12, weight: .semibold))
                                Text("Filter")
                                    .font(.system(size: 12, weight: .semibold))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(.ultraThinMaterial)
                                    .environment(\.colorScheme, .dark)
                            )
                            .overlay(
                                Capsule()
                                    .stroke(Color.white.opacity(0.18), lineWidth: 1)
                            )
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("Alle Kategorien anzeigen")
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 2)
                }
            }
        }
        .padding(.top, 56)
        .padding(.horizontal, 16)
        .sheet(isPresented: $isShowingFilterSheet) {
            if let vm {
                MapFilterSheet(
                    selectedCategory: Binding(
                        get: { vm.selectedCategory },
                        set: { vm.selectedCategory = $0 }
                    ),
                    categoryCounts: vm.categoryCounts
                )
                .presentationDetents([.fraction(0.38), .medium])
                .presentationDragIndicator(.visible)
            }
        }
    }

    private var fabStack: some View {
        VStack(spacing: 12) {
            Button(action: recenterOnUser) {
                ZStack {
                    Circle()
                        .fill(Color.black.opacity(0.65))
                        .frame(width: 50, height: 50)
                        .overlay(
                            Circle().stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )
                    Image(systemName: "location.fill")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(Color.scoonOrange)
                }
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Auf meinen Standort zentrieren")

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
            .buttonStyle(.plain)
            .accessibilityLabel("Neuen Spot erstellen")
        }
        .padding(.trailing, 16)
        .padding(.bottom, fabBottomPadding)
        .animation(.easeInOut(duration: 0.25), value: panelState)
    }

    private var fabBottomPadding: CGFloat {
        switch panelState {
        case .hidden:   return 118
        case .compact:  return 350
        }
    }

    private var bottomPanel: some View {
        VStack(spacing: 0) {
            Capsule()
                .fill(Color.white.opacity(0.28))
                .frame(width: 40, height: 5)
                .padding(.top, 10)

            HStack {
                if let vm {
                    if vm.isLoading {
                        HStack(spacing: 8) {
                            ProgressView()
                                .tint(Color.scoonOrange)
                                .scaleEffect(0.85)
                            Text("Lade Spots ...")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                    } else {
                        Text(panelTitle(vm))
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.primary)
                    }
                }

                Spacer()

                HStack(spacing: 8) {
                    if !focusedClusterSpotIDs.isEmpty {
                        Button(action: { focusedClusterSpotIDs.removeAll() }) {
                            Text("Alle")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(Color.scoonOrange.opacity(0.9))
                                .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)
                    }

                    Button(action: togglePanel) {
                        Image(systemName: "chevron.down")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(Color.scoonOrange)
                            .frame(width: 32, height: 32)
                            .background(Color.scoonOrange.opacity(0.12))
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)

                    if panelState != .hidden {
                        Button(action: hidePanel) {
                            Image(systemName: "xmark")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.white.opacity(0.8))
                                .frame(width: 32, height: 32)
                                .background(Color.black.opacity(0.3))
                                .clipShape(Circle())
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 12)
            .background(Color.black.opacity(0.16))

            if panelState != .hidden {
                panelContent
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: panelState.height)
        .background(
            RoundedRectangle(cornerRadius: 26)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 26)
                        .stroke(Color.white.opacity(0.14), lineWidth: 1)
                )
        )
        .clipShape(RoundedRectangle(cornerRadius: 26))
        .padding(.horizontal, 10)
        .padding(.bottom, 80)
        .shadow(color: .black.opacity(0.3), radius: 16, x: 0, y: 6)
        .animation(.spring(response: 0.35, dampingFraction: 0.82), value: panelState)
        .gesture(
            DragGesture(minimumDistance: 10)
                .onEnded { value in
                    if value.translation.height > 110 {
                        panelState = .hidden
                    }
                }
        )
    }

    private var reopenPanelButton: some View {
        VStack {
            Spacer()
            Button(action: {
                Haptics.impact(.light)
                panelState = .compact
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "square.stack.3d.up.fill")
                        .font(.system(size: 13, weight: .semibold))
                    Text("Spots")
                        .font(.system(size: 14, weight: .bold))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 18)
                .padding(.vertical, 10)
                .background(
                    Capsule()
                        .fill(Color.black.opacity(0.55))
                        .overlay(
                            Capsule().stroke(Color.white.opacity(0.16), lineWidth: 1)
                        )
                )
            }
            .buttonStyle(.plain)
            .padding(.bottom, 96)
        }
    }

    @ViewBuilder
    private var panelContent: some View {
        if let vm {
            let spots = displayedSpots(for: vm)

            if spots.isEmpty && !vm.isLoading {
                VStack(spacing: 12) {
                    Image(systemName: "map")
                        .font(.system(size: 34))
                        .foregroundColor(Color.scoonOrange.opacity(0.4))
                    Text("Keine Spots gefunden")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.primary)
                    if vm.selectedCategory != nil || !vm.searchText.isEmpty {
                        Button("Filter zuruecksetzen") {
                            vm.selectedCategory = nil
                            vm.searchText = ""
                        }
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(Color.scoonOrange)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(maxHeight: .infinity)
            } else {
                if spots.count == 1, let spot = spots.first {
                    MapFeaturedCard(spot: spot, onTap: { focus(on: spot) }) {
                        router.navigate(to: .placeInfo(spot))
                    }
                    .padding(.horizontal, 18)
                    .padding(.bottom, 16)
                } else if spots.count == 2 {
                    HStack(spacing: 12) {
                        ForEach(spots) { spot in
                            MapSpotCard(
                                spot: spot,
                                isSelected: selectedSpot?.id == spot.id,
                                onDetail: { router.navigate(to: .placeInfo(spot)) }
                            )
                            .onTapGesture { focus(on: spot) }
                        }
                        Spacer(minLength: 0)
                    }
                    .padding(.horizontal, 18)
                    .padding(.bottom, 16)
                } else {
                    ScrollViewReader { proxy in
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(spots) { spot in
                                    MapSpotCard(
                                        spot: spot,
                                        isSelected: selectedSpot?.id == spot.id,
                                        onDetail: { router.navigate(to: .placeInfo(spot)) }
                                    )
                                    .id(spot.id)
                                    .onTapGesture { focus(on: spot) }
                                }
                            }
                            .padding(.horizontal, 18)
                            .padding(.bottom, 16)
                        }
                        .onChange(of: selectedSpot?.id) { _, id in
                            guard let id else { return }
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.82)) {
                                proxy.scrollTo(id, anchor: .center)
                            }
                        }
                    }
                }
            }
        }
    }

    private func togglePanel() {
        Haptics.impact(.light)
        withAnimation(.spring(response: 0.35, dampingFraction: 0.82)) {
            switch panelState {
            case .hidden: panelState = .compact
            case .compact: panelState = .hidden
            }
        }
    }

    private func hidePanel() {
        Haptics.impact(.light)
        withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
            panelState = .hidden
        }
    }

    private func focus(on spot: Spot) {
        withAnimation(.spring(response: 0.32, dampingFraction: 0.7)) {
            selectedSpot = spot
            panelState = .compact
        }

        guard let lat = spot.latitude, let lng = spot.longitude else { return }
        withAnimation(.easeInOut(duration: 0.55)) {
            region.center = .init(latitude: lat, longitude: lng)
        }
    }

    private func recenterOnUser() {
        guard let location = locationService.lastLocation else {
            pendingCenterOnUserFix = true
            locationService.requestLocationFix()
            return
        }

        Haptics.impact(.rigid)
        withAnimation(.easeInOut(duration: 0.4)) {
            region.center = location.coordinate
            region.span = MKCoordinateSpan(
                latitudeDelta: min(region.span.latitudeDelta, 0.025),
                longitudeDelta: min(region.span.longitudeDelta, 0.025)
            )
        }
        scheduleNearbyReload()
    }

    private func scheduleNearbyReload() {
        nearbyReloadTask?.cancel()
        nearbyReloadTask = Task { [weak vm] in
            try? await Task.sleep(for: .milliseconds(700))
            guard !Task.isCancelled else { return }
            await vm?.load()
        }
    }

    private func panelTitle(_ vm: MapViewModel) -> String {
        if !focusedClusterSpotIDs.isEmpty {
            let count = displayedSpots(for: vm).count
            return "Cluster: \(count) Spots"
        }
        return panelState == .hidden
            ? "Spots"
            : "\(vm.visibleFilteredSpots.count) Spots"
    }

    private func prioritizedCategories(for vm: MapViewModel) -> [SpotCategory] {
        let sorted = SpotCategory.allCases.sorted {
            vm.categoryCounts[$0, default: 0] > vm.categoryCounts[$1, default: 0]
        }

        if let selected = vm.selectedCategory {
            let withoutSelected = sorted.filter { $0 != selected }
            return [selected] + Array(withoutSelected.prefix(3))
        }

        return Array(sorted.prefix(4))
    }

    private func categoryLabel(for category: SpotCategory, in vm: MapViewModel) -> String {
        let count = vm.categoryCounts[category, default: 0]
        return vm.selectedCategory == category ? "\(category.rawValue) · \(count)" : category.rawValue
    }

    private func displayedSpots(for vm: MapViewModel) -> [Spot] {
        guard !focusedClusterSpotIDs.isEmpty else { return vm.visibleFilteredSpots }
        return vm.visibleFilteredSpots
            .filter { focusedClusterSpotIDs.contains($0.id) }
            .sorted { $0.rating > $1.rating }
    }

    private func clusteredPins(for spots: [Spot]) -> [MapPin] {
        guard !spots.isEmpty else { return [] }

        let latCellSize = max(region.span.latitudeDelta / 11.0, 0.0035)
        let lonCellSize = max(region.span.longitudeDelta / 11.0, 0.0035)

        let grouped = Dictionary(grouping: spots) { spot -> String in
            let lat = spot.latitude ?? 0
            let lon = spot.longitude ?? 0
            let latBucket = Int((lat / latCellSize).rounded(.towardZero))
            let lonBucket = Int((lon / lonCellSize).rounded(.towardZero))
            return "\(latBucket)_\(lonBucket)"
        }

        return grouped.values.compactMap { group in
            guard !group.isEmpty else { return nil }

            let latitudes = group.compactMap(\.latitude)
            let longitudes = group.compactMap(\.longitude)
            guard !latitudes.isEmpty, !longitudes.isEmpty else { return nil }

            let center = CLLocationCoordinate2D(
                latitude: latitudes.reduce(0, +) / Double(latitudes.count),
                longitude: longitudes.reduce(0, +) / Double(longitudes.count)
            )
            return MapPin(
                coordinate: center,
                spots: group,
                primarySpot: group.max(by: { $0.rating < $1.rating }) ?? group[0]
            )
        }
    }

    private func openCluster(_ pin: MapPin) {
        focusedClusterSpotIDs = Set(pin.spots.map(\.id))
        panelState = .compact

        if let bestSpot = pin.spots.max(by: { $0.rating < $1.rating }) {
            selectedSpot = bestSpot
        }

        withAnimation(.easeInOut(duration: reduceMotion ? 0.0 : 0.3)) {
            region.center = pin.coordinate

            // Only tighten the zoom when the user is still on a broad viewport.
            if region.span.latitudeDelta > 0.035 || region.span.longitudeDelta > 0.035 {
                region.span = MKCoordinateSpan(
                    latitudeDelta: max(region.span.latitudeDelta * 0.58, 0.012),
                    longitudeDelta: max(region.span.longitudeDelta * 0.58, 0.012)
                )
            }
        }
    }
}

private enum PanelState {
    case hidden
    case compact

    var height: CGFloat {
        switch self {
        case .hidden: return 74
        case .compact: return 350
        }
    }
}

private struct RegionSnapshot: Equatable {
    let lat: Double
    let lon: Double
    let latDelta: Double
    let lonDelta: Double
}

private final class MapLocationService: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var lastLocation: CLLocation?

    private let manager = CLLocationManager()

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
    }

    func requestAuthorizationIfNeeded() {
        if manager.authorizationStatus == .notDetermined {
            manager.requestWhenInUseAuthorization()
        }
    }

    func requestLocationFix() {
        manager.requestLocation()
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            manager.requestLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        lastLocation = locations.last
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {}
}

private struct SpotPhotoPin: View {
    let spot: Spot
    let isSelected: Bool

    private var ringSize: CGFloat { isSelected ? 58 : 44 }
    private var photoSize: CGFloat { isSelected ? 47 : 36 }

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                if isSelected {
                    Circle()
                        .fill(Color.scoonOrange.opacity(0.3))
                        .frame(width: ringSize + 18, height: ringSize + 18)
                        .blur(radius: 8)
                }

                Circle()
                    .fill(isSelected ? Color.scoonOrange : Color.white)
                    .frame(width: ringSize, height: ringSize)
                    .shadow(
                        color: isSelected ? Color.scoonOrange.opacity(0.55) : Color.black.opacity(0.28),
                        radius: isSelected ? 14 : 6,
                        x: 0,
                        y: 2
                    )

                AsyncImage(url: URL(string: spot.imageURL)) { phase in
                    switch phase {
                    case .success(let img):
                        img.resizable().scaledToFill()
                    default:
                        Circle()
                            .fill(Color.scoonOrange.opacity(0.16))
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

            PinTriangle()
                .fill(isSelected ? Color.scoonOrange : Color.white)
                .frame(width: 10, height: 7)
                .shadow(color: .black.opacity(0.18), radius: 2, x: 0, y: 1)
        }
        .scaleEffect(isSelected ? 1.12 : 1.0)
        .animation(.spring(response: 0.28, dampingFraction: 0.65), value: isSelected)
    }
}

private struct ClusterPinView: View {
    let count: Int

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                Circle()
                    .fill(Color.scoonOrange.opacity(0.28))
                    .frame(width: 70, height: 70)

                Circle()
                    .fill(Color.scoonOrange)
                    .frame(width: 52, height: 52)
                    .overlay(
                        Text("\(count)")
                            .font(.system(size: 16, weight: .black))
                            .foregroundColor(.white)
                    )
                    .overlay(
                        Circle().stroke(Color.white.opacity(0.55), lineWidth: 1.5)
                    )
            }

            PinTriangle()
                .fill(Color.scoonOrange)
                .frame(width: 10, height: 7)
                .shadow(color: .black.opacity(0.18), radius: 2, x: 0, y: 1)
        }
        .shadow(color: Color.scoonOrange.opacity(0.45), radius: 12, x: 0, y: 4)
    }
}

private struct MapSpotCard: View {
    let spot: Spot
    let isSelected: Bool
    let onDetail: () -> Void

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
            .frame(width: 170, height: 222)
            .clipped()

            LinearGradient(
                colors: [.clear, .black.opacity(0.82)],
                startPoint: .center,
                endPoint: .bottom
            )

            VStack(alignment: .leading, spacing: 5) {
                Text(spot.category.rawValue)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
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
        .frame(width: 170, height: 222)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(isSelected ? Color.scoonOrange : Color.clear, lineWidth: 2.5)
        )
        .shadow(
            color: isSelected ? Color.scoonOrange.opacity(0.45) : Color.black.opacity(0.22),
            radius: isSelected ? 14 : 7,
            x: 0,
            y: 4
        )
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
            .buttonStyle(.plain)
        }
    }
}

private struct MapFeaturedCard: View {
    let spot: Spot
    let onTap: () -> Void
    let onDetail: () -> Void

    var body: some View {
        Button(action: onTap) {
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
                .frame(height: 188)
                .clipped()

                LinearGradient(
                    colors: [.clear, .black.opacity(0.82)],
                    startPoint: .center,
                    endPoint: .bottom
                )

                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 8) {
                        Text(spot.category.rawValue)
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Color.scoonOrange.opacity(0.9))
                            .clipShape(Capsule())

                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .font(.system(size: 10))
                            Text(String(format: "%.1f", spot.rating))
                                .font(.system(size: 13, weight: .bold))
                        }
                        .foregroundColor(.white)
                    }

                    Text(spot.name)
                        .font(.system(size: 28, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                        .lineLimit(1)
                }
                .padding(16)
            }
            .clipShape(RoundedRectangle(cornerRadius: 22))
            .overlay(
                RoundedRectangle(cornerRadius: 22)
                    .stroke(Color.scoonOrange, lineWidth: 3)
            )
            .shadow(color: Color.scoonOrange.opacity(0.35), radius: 14, x: 0, y: 5)
            .overlay(alignment: .topTrailing) {
                Button(action: onDetail) {
                    Image(systemName: "arrow.up.right")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 34, height: 34)
                        .background(Color.black.opacity(0.55))
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.white.opacity(0.15), lineWidth: 1))
                }
                .padding(10)
                .buttonStyle(.plain)
            }
        }
        .buttonStyle(.plain)
    }
}

private struct MapCategoryChip: View {
    let label: String
    let isActive: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 12, weight: isActive ? .semibold : .regular))
                .foregroundColor(isActive ? .black : .white)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(isActive ? AnyShapeStyle(Color.scoonOrange) : AnyShapeStyle(.ultraThinMaterial))
                        .environment(\.colorScheme, .dark)
                )
                .overlay(
                    Capsule()
                        .stroke(isActive ? Color.clear : Color.white.opacity(0.18), lineWidth: 1)
                )
                .shadow(
                    color: isActive ? Color.scoonOrange.opacity(0.4) : Color.black.opacity(0.18),
                    radius: isActive ? 8 : 3,
                    x: 0,
                    y: 2
                )
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.25, dampingFraction: 0.7), value: isActive)
    }
}

private struct MapFilterSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedCategory: SpotCategory?
    let categoryCounts: [SpotCategory: Int]

    var body: some View {
        NavigationStack {
            List {
                Button(action: { selectedCategory = nil }) {
                    HStack {
                        Text("Alle Kategorien")
                            .font(.system(size: 15, weight: .semibold))
                        Spacer()
                        if selectedCategory == nil {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(Color.scoonOrange)
                        }
                    }
                }
                .buttonStyle(.plain)

                ForEach(SpotCategory.allCases, id: \.self) { category in
                    Button(action: { selectedCategory = category }) {
                        HStack {
                            Text(category.rawValue)
                                .font(.system(size: 15, weight: .medium))
                            Spacer()
                            Text("\(categoryCounts[category, default: 0])")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.secondary)
                            if selectedCategory == category {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(Color.scoonOrange)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .navigationTitle("Filter")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Fertig") { dismiss() }
                }
            }
        }
    }
}

private struct MapPin: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
    let spots: [Spot]
    let primarySpot: Spot

    var isCluster: Bool { spots.count > 1 }
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

private enum Haptics {
    static func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred()
    }
}
