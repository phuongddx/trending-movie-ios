import SwiftUI

// MARK: - Common View Extensions

extension View {

    // MARK: - Conditional View Modifiers

    /// Conditionally apply a view modifier
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }

    /// Conditionally apply one of two view modifiers
    @ViewBuilder
    func `if`<TrueContent: View, FalseContent: View>(
        _ condition: Bool,
        if trueTransform: (Self) -> TrueContent,
        else falseTransform: (Self) -> FalseContent
    ) -> some View {
        if condition {
            trueTransform(self)
        } else {
            falseTransform(self)
        }
    }

    // MARK: - Keyboard Handling

    /// Hide keyboard when tapping outside
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                       to: nil, from: nil, for: nil)
    }

    /// Add tap gesture to hide keyboard
    func dismissKeyboardOnTap() -> some View {
        self.onTapGesture {
            hideKeyboard()
        }
    }

    // MARK: - Navigation

    /// Hide navigation bar
    func hideNavigationBar() -> some View {
        self.navigationBarHidden(true)
    }

    /// Custom navigation bar title
    func navigationTitle(_ title: String, displayMode: NavigationBarItem.TitleDisplayMode = .automatic) -> some View {
        self.navigationBarTitle(title, displayMode: displayMode)
    }

    // MARK: - Loading States

    /// Show loading overlay
    func loading(_ isLoading: Bool) -> some View {
        self.overlay(
            Group {
                if isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black.opacity(0.3))
                }
            }
        )
    }

    // MARK: - Error Handling

    /// Show error state
    func errorState<ErrorContent: View>(
        error: Error?,
        @ViewBuilder errorContent: @escaping (Error) -> ErrorContent
    ) -> some View {
        Group {
            if let error = error {
                errorContent(error)
            } else {
                self
            }
        }
    }

    /// Show error state with retry
    func errorState(
        error: Error?,
        retryAction: @escaping () -> Void
    ) -> some View {
        errorState(error: error) { error in
            ErrorView(error: error, retryAction: retryAction)
        }
    }

    // MARK: - Frame Utilities

    /// Fill available space
    func fillMaxSize() -> some View {
        self.frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    /// Fill available width
    func fillMaxWidth(alignment: Alignment = .center) -> some View {
        self.frame(maxWidth: .infinity, alignment: alignment)
    }

    /// Fill available height
    func fillMaxHeight(alignment: Alignment = .center) -> some View {
        self.frame(maxHeight: .infinity, alignment: alignment)
    }

    /// Square frame with equal width and height
    func square(_ size: CGFloat) -> some View {
        self.frame(width: size, height: size)
    }

    // MARK: - Safe Area

    /// Ignore specific safe area edges
    func ignoreSafeArea(_ edges: Edge.Set = .all) -> some View {
        self.ignoresSafeArea(.all, edges: edges)
    }

    // MARK: - Accessibility

    /// Add accessibility identifier
    func accessibilityId(_ identifier: String) -> some View {
        self.accessibilityIdentifier(identifier)
    }

    /// Add accessibility label and hint
    func accessibility(label: String, hint: String? = nil) -> some View {
        Group {
            if let hint = hint {
                self.accessibilityLabel(label)
                    .accessibilityHint(hint)
            } else {
                self.accessibilityLabel(label)
            }
        }
    }

    // MARK: - Haptic Feedback

    /// Add haptic feedback on tap
    func hapticFeedback(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) -> some View {
        self.onTapGesture {
            let impactFeedback = UIImpactFeedbackGenerator(style: style)
            impactFeedback.impactOccurred()
        }
    }

    // MARK: - Corner Radius

    /// Apply corner radius to specific corners
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        self.clipShape(RoundedCorner(radius: radius, corners: corners))
    }

    // MARK: - Shadow Utilities

    /// Common shadow styles
    func cardShadow() -> some View {
        self.shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 2)
    }

    func softShadow() -> some View {
        self.shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 1)
    }

    func strongShadow() -> some View {
        self.shadow(color: Color.black.opacity(0.2), radius: 12, x: 0, y: 4)
    }

    // MARK: - Animation Utilities

    /// Bounce animation
    func bounceAnimation() -> some View {
        self.animation(.spring(response: 0.3, dampingFraction: 0.6, blendDuration: 0), value: UUID())
    }

    /// Smooth animation
    func smoothAnimation(duration: Double = 0.3) -> some View {
        self.animation(.easeInOut(duration: duration), value: UUID())
    }

    // MARK: - Debug Utilities

    /// Add debug border (only in debug builds)
    func debugBorder(_ color: Color = .red, width: CGFloat = 1) -> some View {
        #if DEBUG
        return self.border(color, width: width)
        #else
        return self
        #endif
    }

    /// Print view size for debugging
    func debugSize() -> some View {
        self.background(
            GeometryReader { geometry in
                Color.clear.onAppear {
                    #if DEBUG
                    print("View size: \(geometry.size)")
                    #endif
                }
            }
        )
    }
}

// MARK: - Supporting Views

/// Custom corner radius shape
private struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

// MARK: - SwiftUI Specific Extensions

@available(iOS 14.0, *)
extension View {
    /// Present sheet with drag indicator
    func presentationDetentsCompact() -> some View {
        if #available(iOS 16.0, *) {
            return self.presentationDetents([.medium, .large])
                      .presentationDragIndicator(.visible)
        } else {
            return self
        }
    }
}

// MARK: - Preview Utilities

extension View {
    /// Wrap view in NavigationView for previews
    func previewInNavigationView() -> some View {
        NavigationView {
            self
        }
    }

    /// Add background for previews
    func previewBackground() -> some View {
        self.background(DSColors.backgroundSwiftUI)
    }

    /// Common preview setup
    func previewSetup() -> some View {
        self.previewBackground()
            .previewInNavigationView()
    }
}
