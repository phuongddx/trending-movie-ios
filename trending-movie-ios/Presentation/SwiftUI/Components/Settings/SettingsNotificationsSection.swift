import SwiftUI

// MARK: - Settings Notifications Section
/// Push notification settings with dependency logic for sub-toggles
@available(iOS 15.0, *)
struct SettingsNotificationsSection: View {
    @Binding var pushNotifications: Bool
    @Binding var newReleasesEnabled: Bool
    @Binding var recommendationsEnabled: Bool

    var body: some View {
        SettingsSectionContainer(title: "Notifications", icon: .notification) {
            VStack(spacing: 0) {
                SettingsToggleRow(
                    title: "Push Notifications",
                    subtitle: "Receive alerts on your device",
                    isOn: $pushNotifications
                )
                .accessibilityIdentifier("push_notifications_toggle")

                Divider().background(DSColors.borderSwiftUI.opacity(0.3))

                SettingsToggleRow(
                    title: "New Releases",
                    subtitle: "Get notified about new movies and shows",
                    isOn: $newReleasesEnabled,
                    isEnabled: pushNotifications
                )
                .accessibilityIdentifier("new_releases_toggle")

                Divider().background(DSColors.borderSwiftUI.opacity(0.3))

                SettingsToggleRow(
                    title: "Recommendations",
                    subtitle: "Personalized movie suggestions",
                    isOn: $recommendationsEnabled,
                    isEnabled: pushNotifications
                )
                .accessibilityIdentifier("recommendations_toggle")
            }
        }
    }
}

// MARK: - Preview
@available(iOS 15.0, *)
#Preview {
    struct PreviewWrapper: View {
        @State var push = true
        @State var newReleases = true
        @State var recommendations = false

        var body: some View {
            SettingsNotificationsSection(
                pushNotifications: $push,
                newReleasesEnabled: $newReleases,
                recommendationsEnabled: $recommendations
            )
            .padding()
            .background(DSColors.backgroundSwiftUI)
        }
    }
    return PreviewWrapper()
}
