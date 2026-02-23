import SwiftUI

/// Shimmer loading effect modifier
struct ShimmerModifier: ViewModifier {
    @State private var isInitialState = true
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    func body(content: Content) -> some View {
        if reduceMotion {
            // Static gray for reduce motion
            content
                .overlay(Color.gray.opacity(0.3))
        } else {
            content
                .mask(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            .black.opacity(0.4),
                            .black,
                            .black.opacity(0.4)
                        ]),
                        startPoint: isInitialState ? UnitPoint(x: -0.3, y: -0.3) : UnitPoint(x: 1, y: 1),
                        endPoint: isInitialState ? UnitPoint(x: 0, y: 0) : UnitPoint(x: 1.3, y: 1.3)
                    )
                )
                .onAppear {
                    withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                        isInitialState = false
                    }
                }
        }
    }
}

// MARK: - View Extension
extension View {
    /// Apply shimmer loading effect
    func shimmer() -> some View {
        modifier(ShimmerModifier())
    }
}
