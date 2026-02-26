import SwiftUI

// MARK: - Settings View
/// Main settings screen composed of modular section components
@available(iOS 15.0, *)
struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Profile Section
                    SettingsProfileSection(
                        displayName: "Movie Enthusiast",
                        email: "movie.fan@email.com",
                        onEditProfile: { /* Navigate to edit profile */ }
                    )

                    // Video Playback Section
                    SettingsVideoSection(
                        autoplayTrailers: $viewModel.videoSettings.autoplayTrailers,
                        streamingQuality: viewModel.videoSettings.streamingQuality.rawValue,
                        downloadQuality: viewModel.videoSettings.downloadQuality.rawValue,
                        onStreamingQualityTapped: { /* Navigate to quality picker */ },
                        onDownloadQualityTapped: { /* Navigate to quality picker */ }
                    )

                    // Notifications Section
                    SettingsNotificationsSection(
                        pushNotifications: $viewModel.notificationSettings.pushEnabled,
                        newReleasesEnabled: $viewModel.notificationSettings.newReleasesEnabled,
                        recommendationsEnabled: $viewModel.notificationSettings.recommendationsEnabled
                    )

                    // Display & Accessibility Section
                    SettingsDisplaySection(
                        showAgeRatings: $viewModel.displaySettings.showAgeRatings,
                        hapticEnabled: $viewModel.displaySettings.hapticFeedbackEnabled,
                        language: viewModel.displaySettings.language,
                        onLanguageTapped: { /* Navigate to language picker */ }
                    )

                    // Storage Section
                    SettingsStorageSection(
                        downloadsCount: viewModel.storageInfo.downloadedMoviesCount,
                        downloadsSize: viewModel.storageInfo.downloadedMoviesSize,
                        cacheSize: viewModel.storageInfo.cacheSize,
                        showClearCacheConfirmation: $viewModel.showClearCacheConfirmation,
                        onClearCache: { viewModel.clearCache() },
                        onManageDownloads: { /* Navigate to download management */ }
                    )

                    // About Section
                    SettingsAboutSection(
                        appVersion: viewModel.versionString,
                        onPrivacyPolicy: { openURL("https://example.com/privacy") },
                        onTermsOfService: { openURL("https://example.com/terms") },
                        onHelp: { openURL("https://example.com/help") },
                        onRateApp: { openAppStore() }
                    )

                    // Sign Out
                    actionsSection

                    Spacer(minLength: 100)
                }
                .padding(20)
            }
            .background(DSColors.backgroundSwiftUI)
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .alert("Sign Out", isPresented: $viewModel.showSignOutConfirmation) {
                Button("Cancel", role: .cancel) {}
                Button("Sign Out", role: .destructive) {
                    viewModel.signOut()
                }
            } message: {
                Text("Are you sure you want to sign out? Your downloaded movies will remain on this device.")
            }
        }
    }

    // MARK: - Actions Section
    private var actionsSection: some View {
        VStack(spacing: 12) {
            DSActionButton(
                title: "Sign Out",
                style: .destructive,
                icon: nil
            ) {
                viewModel.showSignOutConfirmation = true
            }
            .accessibilityIdentifier("sign_out_button")
        }
    }

    // MARK: - Helpers
    private func openURL(_ urlString: String) {
        guard let url = URL(string: urlString) else { return }
        UIApplication.shared.open(url)
    }

    private func openAppStore() {
        guard let url = URL(string: "itms-apps://itunes.apple.com/app/id123456789?action=write-review") else { return }
        UIApplication.shared.open(url)
    }
}

// MARK: - Preview
@available(iOS 15.0, *)
#Preview {
    SettingsView()
}
