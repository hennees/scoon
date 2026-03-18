import SwiftUI

// Redirects to SignUpFormScreen — kept for navigation compatibility
struct SignUpEmailScreen: View {
    @Environment(AppRouter.self) private var router

    var body: some View {
        SignUpFormScreen()
    }
}
