import SwiftUI
import MapKit

// Design: 560:1271 – Add Photo Spot
struct AddPhotoSpotScreen: View {
    @Environment(AppRouter.self)    private var router
    @Environment(AppContainer.self) private var container
    @State private var vm: AddSpotViewModel?

    @State private var region = MKCoordinateRegion(
        center:             CLLocationCoordinate2D(latitude: 47.0707, longitude: 15.4395),
        latitudinalMeters:  1000,
        longitudinalMeters: 1000
    )

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.scoonCardLight.ignoresSafeArea()

            if let vm {
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        // ── Header ────────────────────────────────────
                        HStack {
                            Text("Add Photo Spot")
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(Color.scoonDarker)
                            Spacer()
                            Button(action: { router.navigateBack() }) {
                                Image(systemName: "xmark")
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(Color.scoonDarker)
                                    .frame(width: 36, height: 36)
                                    .background(Color.white)
                                    .clipShape(Circle())
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 56)

                        // ── Name ──────────────────────────────────────
                        FieldLabel(title: "Name")
                        LightTextField(
                            placeholder: "Name des Spots",
                            text: Binding(get: { vm.name }, set: { vm.name = $0 })
                        )
                        .padding(.horizontal, 20)

                        // ── Location ──────────────────────────────────
                        FieldLabel(title: "Location")
                        LightTextField(
                            placeholder: "z.B. Graz, Austria",
                            text: Binding(get: { vm.location }, set: { vm.location = $0 })
                        )
                        .padding(.horizontal, 20)

                        // ── Category ──────────────────────────────────
                        FieldLabel(title: "Kategorie")
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(SpotCategory.allCases, id: \.self) { cat in
                                    let isActive = vm.category == cat
                                    Button(action: { vm.category = cat }) {
                                        Text(cat.rawValue)
                                            .font(.system(size: 13, weight: isActive ? .semibold : .regular))
                                            .foregroundColor(isActive ? .white : Color.scoonDarker)
                                            .padding(.horizontal, 14)
                                            .padding(.vertical, 8)
                                            .background(isActive ? Color.scoonOrange : Color.white)
                                            .clipShape(Capsule())
                                            .overlay(
                                                Capsule().stroke(isActive ? Color.clear : Color.scoonBorder, lineWidth: 1)
                                            )
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal, 20)
                        }

                        // ── Map preview ───────────────────────────────
                        Map(coordinateRegion: $region, annotationItems: [MapPin(coord: region.center)]) { pin in
                            MapAnnotation(coordinate: pin.coord) {
                                Image(systemName: "mappin.circle.fill")
                                    .font(.system(size: 28))
                                    .foregroundColor(Color.scoonOrange)
                            }
                        }
                        .frame(height: 150)
                        .cornerRadius(12)
                        .padding(.horizontal, 20)
                        .padding(.top, 12)

                        // ── Description ───────────────────────────────
                        FieldLabel(title: "Beschreibung")
                        ZStack(alignment: .topLeading) {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.white)
                                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.scoonBorder, lineWidth: 1))
                            TextEditor(
                                text: Binding(get: { vm.description }, set: { vm.description = $0 })
                            )
                            .font(.system(size: 15))
                            .foregroundColor(Color.scoonDarker)
                            .padding(10)
                            .frame(height: 100)
                            if vm.description.isEmpty {
                                Text("Beschreibe diesen Spot…")
                                    .font(.system(size: 15))
                                    .foregroundColor(Color.scoonTextSecondary)
                                    .padding(14)
                                    .allowsHitTesting(false)
                            }
                        }
                        .frame(height: 100)
                        .padding(.horizontal, 20)

                        // ── Photos ────────────────────────────────────
                        FieldLabel(title: "Fotos")
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.scoonBorder, style: StrokeStyle(lineWidth: 2, dash: [6]))
                                .background(Color.white.cornerRadius(12))
                            VStack(spacing: 12) {
                                Image(systemName: "photo.on.rectangle.angled")
                                    .font(.system(size: 36))
                                    .foregroundColor(Color.scoonTextSecondary)
                                HStack(spacing: 12) {
                                    Button(action: {}) {
                                        Text("Add Photos")
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(.white)
                                            .padding(.horizontal, 20).padding(.vertical, 10)
                                            .background(Color.scoonOrange)
                                            .cornerRadius(8)
                                    }
                                    Button(action: {}) {
                                        Text("Add Tags")
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(Color.scoonOrange)
                                            .padding(.horizontal, 20).padding(.vertical, 10)
                                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.scoonOrange, lineWidth: 1))
                                    }
                                }
                            }
                            .padding(.vertical, 24)
                        }
                        .frame(height: 130)
                        .padding(.horizontal, 20)

                        // ── Error ─────────────────────────────────────
                        if let error = vm.error {
                            HStack(spacing: 8) {
                                Image(systemName: "exclamationmark.circle.fill")
                                    .foregroundColor(.red)
                                Text(error)
                                    .font(.system(size: 13))
                                    .foregroundColor(.red)
                            }
                            .padding(12)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.red.opacity(0.08))
                            .cornerRadius(8)
                            .padding(.horizontal, 20)
                            .padding(.top, 12)
                        }

                        // ── Submit ────────────────────────────────────
                        Button(action: { Task { await vm.submit() } }) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(vm.isValid ? Color.scoonOrange : Color.scoonOrange.opacity(0.5))
                                if vm.isLoading {
                                    ProgressView().tint(.white)
                                } else {
                                    Text("Spot hinzufügen")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.white)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                        }
                        .disabled(vm.isLoading)
                        .padding(.horizontal, 20)
                        .padding(.top, 24)
                        .padding(.bottom, 40)
                    }
                }
                .onChange(of: vm.isSuccess) { _, success in
                    guard success else { return }
                    router.navigateBack()
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            if vm == nil { vm = container.makeAddSpotViewModel() }
        }
    }
}

private struct MapPin: Identifiable {
    let id = UUID()
    let coord: CLLocationCoordinate2D
}

private struct FieldLabel: View {
    let title: String
    var body: some View {
        Text(title)
            .font(.system(size: 15, weight: .semibold))
            .foregroundColor(Color.scoonDarker)
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 6)
    }
}

private struct LightTextField: View {
    let placeholder: String
    @Binding var text: String
    var body: some View {
        TextField(placeholder, text: $text)
            .font(.system(size: 15))
            .foregroundColor(Color.scoonDarker)
            .padding(.horizontal, 14)
            .padding(.vertical, 14)
            .background(Color.white)
            .cornerRadius(10)
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.scoonBorder, lineWidth: 1))
    }
}
