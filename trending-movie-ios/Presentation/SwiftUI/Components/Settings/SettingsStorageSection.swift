import SwiftUI

// MARK: - Settings Storage Section
/// Data and storage settings: downloads info, cache management
@available(iOS 15.0, *)
struct SettingsStorageSection: View {
    let downloadsCount: Int
    let downloadsSize: String
    let cacheSize: String
    @Binding var showClearCacheConfirmation: Bool
    let onClearCache: () -> Void
    let onManageDownloads: () -> Void

    var body: some View {
        SettingsSectionContainer(title: "Data & Storage", icon: .folder) {
            VStack(spacing: 0) {
                SettingsInfoRow(
                    title: "Downloaded Movies",
                    value: "\(downloadsCount) movies • \(downloadsSize)",
                    icon: .download
                )
                .accessibilityIdentifier("downloads_info_row")

                SettingsDivider()

                SettingsInfoRow(
                    title: "Cache Size",
                    value: cacheSize,
                    icon: .folder
                )
                .accessibilityIdentifier("cache_size_row")

                SettingsDivider()

                SettingsButtonRow(
                    title: "Clear Cache",
                    icon: .trashBin,
                    isDestructive: false
                ) {
                    showClearCacheConfirmation = true
                }
                .accessibilityIdentifier("clear_cache_button")

                SettingsDivider()

                SettingsNavigationRow(
                    title: "Manage Downloads",
                    icon: .download
                ) {
                    onManageDownloads()
                }
                .accessibilityIdentifier("manage_downloads_row")
            }
        }
        .alert("Clear Cache", isPresented: $showClearCacheConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Clear", role: .destructive) {
                onClearCache()
            }
        } message: {
            Text("This will clear all cached images and temporary data. Your downloads will not be affected.")
        }
    }
}

// MARK: - Preview
@available(iOS 15.0, *)
#Preview {
    struct PreviewWrapper: View {
        @State var showConfirmation = false

        var body: some View {
            SettingsStorageSection(
                downloadsCount: 3,
                downloadsSize: "2.4 GB",
                cacheSize: "156 MB",
                showClearCacheConfirmation: $showConfirmation,
                onClearCache: {},
                onManageDownloads: {}
            )
            .padding()
            .background(DSColors.backgroundSwiftUI)
        }
    }
    return PreviewWrapper()
}
