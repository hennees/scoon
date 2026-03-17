import SwiftUI

// Design: 204:754 – Onboarding / Splash
// Dark-to-orange gradient with large "scoon" logo centred.
struct SplashScreen: View {
    var body: some View {
        ZStack {
            LinearGradient(
                stops: [
                    .init(color: Color(red: 47/255, green: 47/255, blue: 47/255), location: 0.0),
                    .init(color: Color(red: 47/255, green: 47/255, blue: 47/255), location: 0.43),
                    .init(color: Color.scoonOrange,                               location: 0.66),
                    .init(color: Color.scoonOrange,                               location: 1.0),
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 10) {
                Text("scoon")
                    .font(.system(size: 72, weight: .black, design: .rounded))
                    .foregroundColor(.white)

                Text("YOUR SPOT – YOUR STORY")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.white.opacity(0.9))
                    .tracking(1.5)
            }
            .offset(y: -90)
        }
    }
}

#Preview {
    SplashScreen()
}
