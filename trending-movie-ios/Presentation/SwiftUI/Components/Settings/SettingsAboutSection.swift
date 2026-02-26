import SwiftUI

// MARK: - Settings About Section
/// About section: app version, privacy, terms, help, rate app
@available(iOS 15.0, *)
struct SettingsAboutSection: View {
    let appVersion: String
    let onPrivacyPolicy: () -> Void
    let onTermsOfService: () -> Void
    let onHelp: () -> Void
    let onRateApp: () -> Void

    var body: some View {
        SettingsSectionContainer(title: "About", icon: .question) {
            VStack(spacing: 0) {
                SettingsInfoRow(
                    title: "Version",
                    value: appVersion
                )
                .accessibilityIdentifier("version_info_row")

                SettingsDivider()

                SettingsNavigationRow(
                    title: "Privacy Policy",
                    icon: .padlock
                ) {
                    onPrivacyPolicy()
                }
                .accessibilityIdentifier("privacy_policy_row")

                SettingsDivider()

                SettingsNavigationRow(
                    title: "Terms of Service",
                    icon: .shield
                ) {
                    onTermsOfService()
                }
                .accessibilityIdentifier("terms_of_service_row")

                SettingsDivider()

                SettingsNavigationRow(
                    title: "Help & Support",
                    icon: .question
                ) {
                    onHelp()
                }
                .accessibilityIdentifier("help_support_row")

                SettingsDivider()

                SettingsNavigationRow(
                    title: "Rate This App",
                    icon: .star
                ) {
                    onRateApp()
                }
                .accessibilityIdentifier("rate_app_row")
            }
        }
    }
}

// MARK: - Preview
@available(iOS 15.0, *)
#Preview {
    SettingsAboutSection(
        appVersion: "1.0.0 (1)",
        onPrivacyPolicy: {},
        onTermsOfService: {},
        onHelp: {},
        onRateApp: {}
    )
    .padding()
    .background(DSColors.backgroundSwiftUI)
}
