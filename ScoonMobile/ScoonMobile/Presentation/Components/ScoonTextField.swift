import SwiftUI

struct ScoonTextField: View {
    let label: String
    let placeholder: String
    @Binding var text: String
    var isSecure: Bool = false
    var isDark: Bool = true

    @State private var showPassword = false

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            if !label.isEmpty {
                Text(label)
                    .font(.system(size: 14))
                    .foregroundColor(isDark ? .white : .black)
            }

            HStack {
                Group {
                    if isSecure && !showPassword {
                        SecureField(placeholder, text: $text)
                            .foregroundColor(
                                isDark ? Color.white.opacity(0.5) : Color.black.opacity(0.5)
                            )
                    } else {
                        TextField(placeholder, text: $text)
                            .foregroundColor(
                                isDark ? Color.white.opacity(0.5) : Color.black.opacity(0.5)
                            )
                    }
                }
                .font(.system(size: 16))
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)

                if isSecure {
                    Button(action: { showPassword.toggle() }) {
                        Image(systemName: showPassword ? "eye" : "eye.slash")
                            .foregroundColor(
                                isDark ? Color.white.opacity(0.5) : Color.black.opacity(0.5)
                            )
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 18)
            .background(isDark ? Color.scoonDark : Color.clear)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.scoonOrange.opacity(0.3), lineWidth: 1)
            )
            .cornerRadius(10)
        }
    }
}
