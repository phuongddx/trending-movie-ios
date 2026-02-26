import SwiftUI

// MARK: - Settings Display Section
/// Display and accessibility settings: language, age ratings, haptic feedback
@available(iOS 15.0, *)
struct SettingsDisplaySection: View {
    @Binding var showAgeRatings: Bool
    @Binding var hapticEnabled: Bool
    let language: String
    let onLanguageTapped: () -> Void

    var body: some View {
        SettingsSectionContainer(title: "Display & Accessibility", icon: .settings) {
            VStack(spacing: 0) {
                SettingsNavigationRow(
                    title: "Language",
                    value: language,
                    icon: .globe
                ) {
                    onLanguageTapped()
                }
                .accessibilityIdentifier("language_row")

                Divider().background(DSColors.borderSwiftUI.opacity(0.3))

                SettingsToggleRow(
                    title: "Show Age Ratings",
                    subtitle: "Display content ratings on movie posters",
                    isOn: $showAgeRatings
                )
                .accessibilityIdentifier("show_age_ratings_toggle")

                Divider().background(DSColors.borderSwiftUI.opacity(0.3))

                SettingsToggleRow(
                    title: "Haptic Feedback",
                    subtitle: "Provides tactile feedback when tapping buttons",
                    isOn: $hapticEnabled
                )
                .accessibilityIdentifier("haptic_feedback_toggle")
            }
        }
    }
}

// MARK: - Preview
@available(iOS 15.0, *)
#Preview {
    struct PreviewWrapper: View {
        @State var showAgeRatings = true
        @State var hapticEnabled = true

        var body: some View {
            SettingsDisplaySection(
                showAgeRatings: $showAgeRatings,
                hapticEnabled: $hapticEnabled,
                language: "English",
                onLanguageTapped: {}
            )
            .padding()
            .background(DSColors.backgroundSwiftUI)
        }
    }
    return PreviewWrapper()
}
