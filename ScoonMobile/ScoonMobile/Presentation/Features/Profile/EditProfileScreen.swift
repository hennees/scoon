import SwiftUI
import PhotosUI

struct EditProfileScreen: View {
    @Environment(AppRouter.self)    private var router
    @Environment(AppContainer.self) private var container
    @State private var vm: EditProfileViewModel?

    let user: User

    @State private var avatarItem: PhotosPickerItem?

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.scoonDarker.ignoresSafeArea()

            if let vm {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {

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
                                Text("Profil bearbeiten")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.primary)
                                Text("scoon")
                                    .font(.system(size: 12))
                                    .foregroundColor(Color.scoonOrange)
                            }
                            .padding(.leading, 10)
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 56)

                        // ── Avatar ────────────────────────────────────────
                        VStack(spacing: 12) {
                            PhotosPicker(selection: $avatarItem, matching: .images) {
                                ZStack(alignment: .bottomTrailing) {
                                    Group {
                                        if let img = vm.selectedAvatar {
                                            Image(uiImage: img)
                                                .resizable()
                                                .scaledToFill()
                                        } else {
                                            AsyncImage(url: URL(string: user.avatarURL)) { phase in
                                                switch phase {
                                                case .success(let img): img.resizable().scaledToFill()
                                                default:
                                                    Image(systemName: "person.fill")
                                                        .font(.system(size: 42))
                                                        .foregroundColor(Color.white.opacity(0.3))
                                                }
                                            }
                                        }
                                    }
                                    .frame(width: 100, height: 100)
                                    .background(Color.primary.opacity(0.1))
                                    .clipShape(Circle())
                                    .overlay(
                                        Circle()
                                            .stroke(
                                                LinearGradient(
                                                    colors: [Color.scoonOrange, Color.scoonOrange.opacity(0.4)],
                                                    startPoint: .topLeading, endPoint: .bottomTrailing
                                                ),
                                                lineWidth: 2.5
                                            )
                                    )
                                    .shadow(color: Color.scoonOrange.opacity(0.4), radius: 14, x: 0, y: 4)

                                    // Camera badge
                                    Circle()
                                        .fill(Color.scoonOrange)
                                        .frame(width: 32, height: 32)
                                        .overlay(
                                            Image(systemName: "camera.fill")
                                                .font(.system(size: 13))
                                                .foregroundColor(.white)
                                        )
                                        .shadow(color: Color.scoonOrange.opacity(0.5), radius: 8)
                                        .offset(x: 3, y: 3)
                                }
                            }

                            Text("Foto ändern")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(Color.scoonOrange)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 32)

                        // ── Form fields ───────────────────────────────────
                        VStack(spacing: 0) {
                            formField(label: "Benutzername") {
                                TextField("Benutzername", text: Binding(
                                    get: { vm.username },
                                    set: { vm.username = $0 }
                                ))
                                .tint(Color.scoonOrange)
                                .font(.system(size: 16))
                                .foregroundColor(.primary)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 14)
                                .background(Color.primary.opacity(0.06))
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(Color.primary.opacity(0.09), lineWidth: 1)
                                )
                            }

                            formField(label: "Bio") {
                                VStack(alignment: .trailing, spacing: 8) {
                                    ZStack(alignment: .topLeading) {
                                        RoundedRectangle(cornerRadius: 14)
                                            .fill(Color.primary.opacity(0.06))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 14)
                                                    .stroke(Color.primary.opacity(0.09), lineWidth: 1)
                                            )

                                        TextEditor(text: Binding(
                                            get: { vm.bio },
                                            set: { if $0.count <= 140 { vm.bio = $0 } }
                                        ))
                                        .tint(Color.scoonOrange)
                                        .font(.system(size: 15))
                                        .foregroundColor(.primary)
                                        .scrollContentBackground(.hidden)
                                        .padding(12)
                                        .frame(minHeight: 100)

                                        if vm.bio.isEmpty {
                                            Text("Erzähl etwas über dich…")
                                                .font(.system(size: 15))
                                                .foregroundColor(Color.white.opacity(0.25))
                                                .padding(16)
                                                .allowsHitTesting(false)
                                        }
                                    }
                                    Text("\(vm.bio.count)/140")
                                        .font(.system(size: 11, weight: .medium))
                                        .foregroundColor(vm.bio.count > 130
                                            ? Color.scoonOrange
                                            : Color.white.opacity(0.3))
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 28)

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

                        // ── Save button ───────────────────────────────────
                        Button(action: { Task { await vm.submit() } }) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                Color.scoonOrange.opacity(vm.hasChanges ? 1 : 0.35),
                                                Color(red: 1.0, green: 0.55, blue: 0.15).opacity(vm.hasChanges ? 1 : 0.35),
                                            ],
                                            startPoint: .leading, endPoint: .trailing
                                        )
                                    )
                                if vm.isLoading {
                                    ProgressView().tint(.white)
                                } else {
                                    Text("Speichern")
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(.white)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                        }
                        .shadow(color: vm.hasChanges ? Color.scoonOrange.opacity(0.45) : .clear,
                                radius: 14, x: 0, y: 6)
                        .disabled(!vm.hasChanges || vm.isLoading)
                        .padding(.horizontal, 20)
                        .padding(.top, 28)
                        .padding(.bottom, 50)
                    }
                }
                .onChange(of: vm.isSuccess) { _, success in
                    guard success else { return }
                    router.navigateBack()
                }
                .onChange(of: avatarItem) { _, item in
                    Task {
                        guard let item,
                              let data = try? await item.loadTransferable(type: Data.self),
                              let img  = UIImage(data: data) else { return }
                        vm.selectedAvatar = img
                    }
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            if vm == nil { vm = container.makeEditProfileViewModel(user: user) }
        }
    }

    @ViewBuilder
    private func formField<Content: View>(label: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label.uppercased())
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(Color.white.opacity(0.4))
                .tracking(1.0)
            content()
        }
        .padding(.bottom, 16)
    }
}
