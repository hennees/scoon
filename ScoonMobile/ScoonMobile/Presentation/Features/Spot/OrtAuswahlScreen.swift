import SwiftUI

// Design: 460:460 – Ort Auswahl (placeholder)
// This screen is a design placeholder for the location selection / spot count flow.
struct OrtAuswahlScreen: View {
    var body: some View {
        ZStack {
            Color.scoonDark.ignoresSafeArea()

            VStack(spacing: 24) {
                Text("scoon")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)

                Text("Ort auswahl – wie viele Spots")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(Color.scoonOrange)
                    .multilineTextAlignment(.center)

                Text("Dieser Bereich wird noch implementiert.")
                    .font(.system(size: 16))
                    .foregroundColor(Color.scoonTextSecondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 32)
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}

#Preview {
    OrtAuswahlScreen()
}
