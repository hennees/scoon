import SwiftUI
import MapKit
import PhotosUI

struct AddPhotoSpotScreen: View {
    @Environment(AppRouter.self)    private var router
    @Environment(AppContainer.self) private var container
    @State private var vm: AddSpotViewModel?

    @State private var photoItems: [PhotosPickerItem] = []
    @State private var appeared = false

    @State private var region = MKCoordinateRegion(
        center:             CLLocationCoordinate2D(latitude: 47.0707, longitude: 15.4395),
        latitudinalMeters:  1000,
        longitudinalMeters: 1000
    )

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.scoonDarker.ignoresSafeArea()

            if let vm {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {

                        // ── Header ──────────────────────────────────────
                        ZStack(alignment: .bottom) {
                            // Subtle top glow
                            RadialGradient(
                                colors: [Color.scoonOrange.opacity(0.12), .clear],
                                center: .top,
                                startRadius: 0,
                                endRadius: 260
                            )
                            .frame(height: 140)

                            HStack(alignment: .center) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("NEUER SPOT")
                                        .font(.system(size: 11, weight: .semibold))
                                        .tracking(2)
                                        .foregroundColor(Color.scoonOrange.opacity(0.8))
                                    Text("Spot hinzufügen")
                                        .font(.system(size: 26, weight: .black, design: .rounded))
                                        .foregroundColor(.white)
                                }
                                Spacer()
                                Button(action: { router.navigateBack() }) {
                                    ZStack {
                                        Circle()
                                            .fill(Color.white.opacity(0.08))
                                            .overlay(Circle().stroke(Color.white.opacity(0.1), lineWidth: 1))
                                            .frame(width: 40, height: 40)
                                        Image(systemName: "xmark")
                                            .font(.system(size: 15, weight: .semibold))
                                            .foregroundColor(.white.opacity(0.7))
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.bottom, 20)
                            .padding(.top, 60)
                        }
                        .opacity(appeared ? 1 : 0)
                        .animation(.easeOut(duration: 0.4), value: appeared)

                        // ── Name ────────────────────────────────────────
                        DarkFieldLabel(title: "Name")
                        DarkTextField(placeholder: "Name des Spots", text: Binding(get: { vm.name }, set: { vm.name = $0 }))
                            .padding(.horizontal, 20)
                            .opacity(appeared ? 1 : 0)
                            .animation(.easeOut(duration: 0.4).delay(0.05), value: appeared)

                        // ── Location ────────────────────────────────────
                        DarkFieldLabel(title: "Standort")
                        DarkTextField(placeholder: "z.B. Graz, Austria", text: Binding(get: { vm.location }, set: { vm.location = $0 }))
                            .padding(.horizontal, 20)
                            .opacity(appeared ? 1 : 0)
                            .animation(.easeOut(duration: 0.4).delay(0.08), value: appeared)

                        // ── Category ────────────────────────────────────
                        DarkFieldLabel(title: "Kategorie")
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(SpotCategory.allCases, id: \.self) { cat in
                                    let isActive = vm.category == cat
                                    Button(action: { vm.category = cat }) {
                                        Text(cat.rawValue)
                                            .font(.system(size: 13, weight: isActive ? .semibold : .regular))
                                            .foregroundColor(isActive ? .black : .white.opacity(0.75))
                                            .padding(.horizontal, 14)
                                            .padding(.vertical, 9)
                                            .background(
                                                Capsule()
                                                    .fill(isActive
                                                          ? AnyShapeStyle(Color.scoonOrange)
                                                          : AnyShapeStyle(.ultraThinMaterial))
                                                    .environment(\.colorScheme, .dark)
                                            )
                                            .overlay(
                                                Capsule().stroke(
                                                    isActive ? Color.clear : Color.white.opacity(0.12),
                                                    lineWidth: 1
                                                )
                                            )
                                    }
                                    .buttonStyle(.plain)
                                    .shadow(
                                        color: isActive ? Color.scoonOrange.opacity(0.4) : .clear,
                                        radius: 8, x: 0, y: 2
                                    )
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                        .opacity(appeared ? 1 : 0)
                        .animation(.easeOut(duration: 0.4).delay(0.1), value: appeared)

                        // ── Map preview ─────────────────────────────────
                        DarkFieldLabel(title: "Standort auf Karte")
                        ZStack(alignment: .bottomTrailing) {
                            Map(coordinateRegion: $region, annotationItems: [MapPinItem(coord: region.center)]) { pin in
                                MapAnnotation(coordinate: pin.coord) {
                                    ZStack {
                                        Circle()
                                            .fill(Color.scoonOrange.opacity(0.25))
                                            .frame(width: 36, height: 36)
                                        Circle()
                                            .fill(Color.scoonOrange)
                                            .frame(width: 18, height: 18)
                                            .overlay(Circle().stroke(.white, lineWidth: 2))
                                    }
                                }
                            }
                            .frame(height: 160)
                            .cornerRadius(16)
                            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.08), lineWidth: 1))

                            Text("Karte zum Anpassen verschieben")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(.white.opacity(0.6))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(Color.black.opacity(0.55))
                                .cornerRadius(8)
                                .padding(10)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 6)
                        .opacity(appeared ? 1 : 0)
                        .animation(.easeOut(duration: 0.4).delay(0.12), value: appeared)

                        // ── Description ─────────────────────────────────
                        DarkFieldLabel(title: "Beschreibung")
                        ZStack(alignment: .topLeading) {
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color.white.opacity(0.05))
                                .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.white.opacity(0.1), lineWidth: 1))
                            TextEditor(
                                text: Binding(get: { vm.description }, set: { vm.description = $0 })
                            )
                            .font(.system(size: 15))
                            .foregroundColor(.white)
                            .tint(Color.scoonOrange)
                            .scrollContentBackground(.hidden)
                            .padding(12)
                            .frame(height: 110)
                            if vm.description.isEmpty {
                                Text("Beschreibe diesen Spot…")
                                    .font(.system(size: 15))
                                    .foregroundColor(.white.opacity(0.3))
                                    .padding(16)
                                    .allowsHitTesting(false)
                            }
                        }
                        .frame(height: 110)
                        .padding(.horizontal, 20)
                        .opacity(appeared ? 1 : 0)
                        .animation(.easeOut(duration: 0.4).delay(0.14), value: appeared)

                        // ── Photos ──────────────────────────────────────
                        DarkFieldLabel(title: "Fotos")
                        DarkPhotosPickerSection(
                            selectedImages: Binding(get: { vm.selectedImages }, set: { vm.selectedImages = $0 }),
                            photoItems: $photoItems
                        )
                        .padding(.horizontal, 20)
                        .opacity(appeared ? 1 : 0)
                        .animation(.easeOut(duration: 0.4).delay(0.16), value: appeared)

                        // ── Error ────────────────────────────────────────
                        if let error = vm.error {
                            HStack(spacing: 8) {
                                Image(systemName: "exclamationmark.circle.fill")
                                    .foregroundColor(.red.opacity(0.85))
                                Text(error)
                                    .font(.system(size: 13))
                                    .foregroundColor(.red.opacity(0.85))
                            }
                            .padding(12)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(10)
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.red.opacity(0.2), lineWidth: 1))
                            .padding(.horizontal, 20)
                            .padding(.top, 12)
                        }

                        // ── Submit ───────────────────────────────────────
                        Button(action: {
                            vm.latitude  = region.center.latitude
                            vm.longitude = region.center.longitude
                            Task { await vm.submit() }
                        }) {
                            ZStack {
                                LinearGradient(
                                    colors: [
                                        Color.scoonOrange.opacity(vm.isValid ? 1 : 0.35),
                                        Color(red: 1.0, green: 0.55, blue: 0.15).opacity(vm.isValid ? 1 : 0.35)
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                                .cornerRadius(16)

                                if vm.isLoading {
                                    HStack(spacing: 10) {
                                        ProgressView().tint(.white)
                                        if !vm.selectedImages.isEmpty {
                                            Text("Fotos werden hochgeladen…")
                                                .font(.system(size: 14, weight: .semibold))
                                                .foregroundColor(.white.opacity(0.8))
                                        }
                                    }
                                } else {
                                    HStack(spacing: 8) {
                                        Image(systemName: "plus.circle.fill")
                                            .font(.system(size: 16))
                                        Text("Spot veröffentlichen")
                                            .font(.system(size: 16, weight: .bold))
                                    }
                                    .foregroundColor(.white)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 58)
                            .shadow(
                                color: Color.scoonOrange.opacity(vm.isValid ? 0.45 : 0),
                                radius: 16, x: 0, y: 6
                            )
                        }
                        .disabled(!vm.isValid || vm.isLoading)
                        .padding(.horizontal, 20)
                        .padding(.top, 28)
                        .padding(.bottom, 50)
                        .opacity(appeared ? 1 : 0)
                        .animation(.easeOut(duration: 0.4).delay(0.2), value: appeared)
                    }
                }
                .onChange(of: vm.isSuccess) { _, success in
                    guard success else { return }
                    router.navigateBack()
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            if vm == nil { vm = container.makeAddSpotViewModel() }
            withAnimation(.easeOut(duration: 0.5)) { appeared = true }
        }
    }
}

// MARK: – Dark Photos Picker Section

private struct DarkPhotosPickerSection: View {
    @Binding var selectedImages: [UIImage]
    @Binding var photoItems:     [PhotosPickerItem]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if selectedImages.isEmpty {
                PhotosPicker(
                    selection: $photoItems,
                    maxSelectionCount: 6,
                    matching: .images
                ) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white.opacity(0.04))
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.scoonOrange.opacity(0.35), style: StrokeStyle(lineWidth: 1.5, dash: [7]))

                        VStack(spacing: 14) {
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [Color.scoonOrange, Color(red: 1.0, green: 0.55, blue: 0.15)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 60, height: 60)
                                    .shadow(color: Color.scoonOrange.opacity(0.45), radius: 14, x: 0, y: 4)
                                Image(systemName: "photo.badge.plus")
                                    .font(.system(size: 26, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                            VStack(spacing: 4) {
                                Text("Fotos hinzufügen")
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundColor(.white)
                                Text("Bis zu 6 Fotos · JPG, PNG")
                                    .font(.system(size: 12))
                                    .foregroundColor(.white.opacity(0.4))
                            }
                        }
                        .padding(.vertical, 28)
                    }
                    .frame(height: 150)
                }
                .buttonStyle(.plain)
            } else {
                let columns = [GridItem(.adaptive(minimum: 80), spacing: 8)]
                LazyVGrid(columns: columns, spacing: 8) {
                    ForEach(selectedImages.indices, id: \.self) { i in
                        ZStack(alignment: .topTrailing) {
                            Image(uiImage: selectedImages[i])
                                .resizable()
                                .scaledToFill()
                                .frame(width: 80, height: 80)
                                .clipped()
                                .cornerRadius(10)
                                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.white.opacity(0.08), lineWidth: 1))

                            Button(action: { selectedImages.remove(at: i) }) {
                                ZStack {
                                    Circle().fill(Color.black.opacity(0.65)).frame(width: 22, height: 22)
                                    Image(systemName: "xmark")
                                        .font(.system(size: 9, weight: .black))
                                        .foregroundColor(.white)
                                }
                            }
                            .padding(4)
                        }
                    }

                    if selectedImages.count < 6 {
                        PhotosPicker(
                            selection: $photoItems,
                            maxSelectionCount: 6,
                            matching: .images
                        ) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.white.opacity(0.05))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color.scoonOrange.opacity(0.35), style: StrokeStyle(lineWidth: 1.5, dash: [5]))
                                    )
                                Image(systemName: "plus")
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundColor(Color.scoonOrange)
                            }
                            .frame(width: 80, height: 80)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .onChange(of: photoItems) { _, items in
            Task {
                var images: [UIImage] = []
                for item in items {
                    if let data = try? await item.loadTransferable(type: Data.self),
                       let img  = UIImage(data: data) {
                        images.append(img)
                    }
                }
                selectedImages = images
            }
        }
    }
}

// MARK: – Helpers

private struct MapPinItem: Identifiable {
    let id = UUID()
    let coord: CLLocationCoordinate2D
}

private struct DarkFieldLabel: View {
    let title: String
    var body: some View {
        Text(title.uppercased())
            .font(.system(size: 11, weight: .semibold))
            .tracking(1.0)
            .foregroundColor(.white.opacity(0.4))
            .padding(.horizontal, 20)
            .padding(.top, 22)
            .padding(.bottom, 8)
    }
}

private struct DarkTextField: View {
    let placeholder: String
    @Binding var text: String

    var body: some View {
        TextField("", text: $text, prompt: Text(placeholder).foregroundColor(.white.opacity(0.3)))
            .font(.system(size: 15))
            .foregroundColor(.white)
            .tint(Color.scoonOrange)
            .padding(.horizontal, 16)
            .padding(.vertical, 15)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.white.opacity(0.05))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
    }
}
