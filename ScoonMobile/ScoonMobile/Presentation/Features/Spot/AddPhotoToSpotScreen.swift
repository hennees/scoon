import SwiftUI
import PhotosUI

struct AddPhotoToSpotScreen: View {
    @Environment(AppRouter.self)    private var router
    @Environment(AppContainer.self) private var container
    @State private var vm: AddPhotoToSpotViewModel?

    let spot: Spot

    @State private var photoItems: [PhotosPickerItem] = []

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.scoonDarker.ignoresSafeArea()

            if let vm {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {

                        // ── Header ────────────────────────────────────────
                        HStack {
                            Button(action: { router.navigateBack() }) {
                                ZStack {
                                    Circle()
                                        .fill(Color.primary.opacity(0.08))
                                        .frame(width: 40, height: 40)
                                    Image(systemName: "xmark")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(.primary)
                                }
                            }
                            VStack(alignment: .leading, spacing: 1) {
                                Text("Dein Foto")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.primary)
                                Text(spot.name)
                                    .font(.system(size: 12))
                                    .foregroundColor(Color.scoonOrange)
                                    .lineLimit(1)
                            }
                            .padding(.leading, 10)
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 56)

                        // ── Spot banner ────────────────────────────────────
                        ZStack(alignment: .bottomLeading) {
                            AsyncImage(url: URL(string: spot.imageURL)) { phase in
                                switch phase {
                                case .success(let img):
                                    img.resizable().scaledToFill()
                                default:
                                    Rectangle()
                                        .fill(Color.primary.opacity(0.08))
                                        .overlay(
                                            Image(systemName: "photo")
                                                .font(.system(size: 30))
                                                .foregroundColor(Color.white.opacity(0.2))
                                        )
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 164)
                            .clipped()

                            // Gradient overlay
                            LinearGradient(
                                colors: [Color.black.opacity(0.72), Color.clear],
                                startPoint: .bottom, endPoint: .init(x: 0.5, y: 0.4)
                            )

                            VStack(alignment: .leading, spacing: 5) {
                                Text(spot.name)
                                    .font(.system(size: 17, weight: .bold))
                                    .foregroundColor(.white)
                                HStack(spacing: 5) {
                                    Image(systemName: "mappin.fill")
                                        .font(.system(size: 10))
                                        .foregroundColor(.scoonOrange)
                                    Text(spot.location)
                                        .font(.system(size: 13))
                                        .foregroundColor(.white.opacity(0.7))
                                }
                            }
                            .padding(16)
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                        .padding(.horizontal, 20)
                        .padding(.top, 20)

                        // ── Section label ──────────────────────────────────
                        Text("FOTOS AUSWÄHLEN")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(Color.white.opacity(0.4))
                            .tracking(1.2)
                            .padding(.horizontal, 20)
                            .padding(.top, 24)
                            .padding(.bottom, 10)

                        // ── Photo picker ───────────────────────────────────
                        SpotPhotoPicker(
                            selectedImages: Binding(
                                get: { vm.selectedImages },
                                set: { vm.selectedImages = $0 }
                            ),
                            photoItems: $photoItems
                        )
                        .padding(.horizontal, 20)

                        // ── Error ─────────────────────────────────────────
                        if let error = vm.error {
                            HStack(spacing: 8) {
                                Image(systemName: "exclamationmark.circle.fill").foregroundColor(.red)
                                Text(error).font(.system(size: 13)).foregroundColor(.red)
                            }
                            .padding(12)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.red.opacity(0.08))
                            .cornerRadius(10)
                            .padding(.horizontal, 20)
                            .padding(.top, 12)
                        }

                        // ── Submit ─────────────────────────────────────────
                        Button(action: { Task { await vm.submit() } }) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                Color.scoonOrange.opacity(vm.canSubmit ? 1 : 0.35),
                                                Color(red: 1.0, green: 0.55, blue: 0.15).opacity(vm.canSubmit ? 1 : 0.35),
                                            ],
                                            startPoint: .leading, endPoint: .trailing
                                        )
                                    )
                                if vm.isLoading {
                                    VStack(spacing: 6) {
                                        ProgressView().tint(.white)
                                        Text("Fotos werden hochgeladen…")
                                            .font(.system(size: 12))
                                            .foregroundColor(.white.opacity(0.8))
                                    }
                                } else {
                                    HStack(spacing: 8) {
                                        Image(systemName: "arrow.up.circle.fill")
                                            .font(.system(size: 16))
                                        Text("Foto hinzufügen")
                                            .font(.system(size: 16, weight: .bold))
                                    }
                                    .foregroundColor(.white)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                        }
                        .shadow(color: vm.canSubmit ? Color.scoonOrange.opacity(0.45) : .clear,
                                radius: 14, x: 0, y: 6)
                        .disabled(!vm.canSubmit)
                        .padding(.horizontal, 20)
                        .padding(.top, 24)
                        .padding(.bottom, 50)
                    }
                }
                .onChange(of: vm.isSuccess) { _, success in
                    guard success else { return }
                    router.navigateBack()
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
                        vm.selectedImages = images
                    }
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            if vm == nil { vm = container.makeAddPhotoToSpotViewModel(spot: spot) }
        }
    }
}

// MARK: – Photo picker sub-view

private struct SpotPhotoPicker: View {
    @Binding var selectedImages: [UIImage]
    @Binding var photoItems:     [PhotosPickerItem]

    private let columns = [GridItem(.flexible(), spacing: 8),
                           GridItem(.flexible(), spacing: 8),
                           GridItem(.flexible(), spacing: 8)]

    var body: some View {
        if selectedImages.isEmpty {
            PhotosPicker(selection: $photoItems, maxSelectionCount: 6, matching: .images) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.scoonOrange.opacity(0.06))
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            Color.scoonOrange.opacity(0.32),
                            style: StrokeStyle(lineWidth: 1.5, dash: [6])
                        )
                    VStack(spacing: 14) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [Color.scoonOrange, Color(red: 1.0, green: 0.55, blue: 0.15)],
                                        startPoint: .topLeading, endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 52, height: 52)
                                .shadow(color: Color.scoonOrange.opacity(0.5), radius: 12, x: 0, y: 4)
                            Image(systemName: "camera.fill")
                                .font(.system(size: 22))
                                .foregroundColor(.white)
                        }
                        VStack(spacing: 4) {
                            Text("Fotos hinzufügen")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(Color.scoonOrange)
                            Text("Bis zu 6 Fotos auswählen")
                                .font(.system(size: 12))
                                .foregroundColor(Color.white.opacity(0.35))
                        }
                    }
                    .padding(.vertical, 36)
                }
            }
            .frame(height: 170)
        } else {
            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(selectedImages.indices, id: \.self) { idx in
                    ZStack(alignment: .topTrailing) {
                        Image(uiImage: selectedImages[idx])
                            .resizable()
                            .scaledToFill()
                            .frame(height: 96)
                            .clipped()
                            .clipShape(RoundedRectangle(cornerRadius: 12))

                        Button(action: {
                            selectedImages.remove(at: idx)
                            if idx < photoItems.count { photoItems.remove(at: idx) }
                        }) {
                            ZStack {
                                Circle()
                                    .fill(Color.black.opacity(0.6))
                                    .frame(width: 24, height: 24)
                                Image(systemName: "xmark")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(.white)
                            }
                        }
                        .padding(5)
                    }
                }
                if selectedImages.count < 6 {
                    PhotosPicker(selection: $photoItems, maxSelectionCount: 6, matching: .images) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.scoonOrange.opacity(0.08))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(
                                            Color.scoonOrange.opacity(0.28),
                                            style: StrokeStyle(lineWidth: 1.5, dash: [5])
                                        )
                                )
                                .frame(height: 96)
                            Image(systemName: "plus")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(Color.scoonOrange.opacity(0.7))
                        }
                    }
                }
            }
        }
    }
}
