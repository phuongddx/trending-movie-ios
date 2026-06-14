# Phase 5: Storage & About Sections

## Overview
Create data/storage management and about section views.

**Priority:** Medium | **Effort:** Low | **Status:** Pending

## Files to Create

### 1. SettingsStorageSection.swift

```swift
// MARK: - Data & Storage Section
struct SettingsStorageSection: View {
    @ObservedObject var viewModel: SettingsViewModel

    var body: some View {
        SettingsSectionContainer(title: "Data & Storage", icon: .folder) {
            VStack(spacing: 0) {
                SettingsInfoRow(
                    title: "Downloaded Movies",
                    value: viewModel.storageInfo.downloadsSummary,
                    icon: .download
                )

                Divider().background(DSColors.borderSwiftUI.opacity(0.3))

                SettingsInfoRow(
                    title: "Cache Size",
                    value: viewModel.storageInfo.cacheSizeFormatted,
                    icon: .folder
                )

                Divider().background(DSColors.borderSwiftUI.opacity(0.3))

                SettingsButtonRow(
                    title: "Clear Cache",
                    icon: .trashBin,
                    isDestructive: false
                ) {
                    viewModel.showClearCacheConfirmation = true
                }

                Divider().background(DSColors.borderSwiftUI.opacity(0.3))

                SettingsNavigationRow(
                    title: "Manage Downloads",
                    icon: .download
                ) {
                    viewModel.showDownloadManagement()
                }
            }
        }
        .alert("Clear Cache", isPresented: $viewModel.showClearCacheConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Clear", role: .destructive) {
                Task { await viewModel.clearCache() }
            }
        } message: {
            Text("This will clear all cached images and temporary data. Your downloads will not be affected.")
        }
    }
}
```

**Lines:** ~60

### 2. SettingsAboutSection.swift

```swift
// MARK: - About Section
struct SettingsAboutSection: View {
    @ObservedObject var viewModel: SettingsViewModel

    var body: some View {
        SettingsSectionContainer(title: "About", icon: .question) {
            VStack(spacing: 0) {
                SettingsInfoRow(
                    title: "Version",
                    value: viewModel.appVersion
                )

                Divider().background(DSColors.borderSwiftUI.opacity(0.3))

                SettingsNavigationRow(
                    title: "Privacy Policy",
                    icon: .padlock
                ) {
                    viewModel.openPrivacyPolicy()
                }

                Divider().background(DSColors.borderSwiftUI.opacity(0.3))

                SettingsNavigationRow(
                    title: "Terms of Service",
                    icon: .shield
                ) {
                    viewModel.openTermsOfService()
                }

                Divider().background(DSColors.borderSwiftUI.opacity(0.3))

                SettingsNavigationRow(
                    title: "Help & Support",
                    icon: .question
                ) {
                    viewModel.openHelp()
                }

                Divider().background(DSColors.borderSwiftUI.opacity(0.3))

                SettingsNavigationRow(
                    title: "Rate This App",
                    icon: .star
                ) {
                    viewModel.rateApp()
                }
            }
        }
    }
}
```

**Lines:** ~65

## File Locations
```
Presentation/SwiftUI/Views/Settings/SettingsStorageSection.swift
Presentation/SwiftUI/Views/Settings/SettingsAboutSection.swift
```

## StorageInfo Model

```swift
struct StorageInfo {
    var downloadedMoviesCount: Int
    var downloadedMoviesBytes: Int64
    var cacheBytes: Int64

    var downloadsSummary: String {
        "\(downloadedMoviesCount) movies • \(ByteCountFormatter.string(fromByteCount: downloadedMoviesBytes, countStyle: .file))"
    }

    var cacheSizeFormatted: String {
        ByteCountFormatter.string(fromByteCount: cacheBytes, countStyle: .file)
    }

    static var empty: StorageInfo {
        StorageInfo(downloadedMoviesCount: 0, downloadedMoviesBytes: 0, cacheBytes: 0)
    }
}
```

## ViewModel Methods to Implement

### Cache Management
```swift
func clearCache() async {
    URLCache.shared.removeAllCachedResponses()
    // Clear Kingfisher/SDWebImage cache if used
    await refreshStorageInfo()
}

func refreshStorageInfo() async {
    let cacheSize = URLCache.shared.currentDiskUsage
    // Calculate downloads size from storage
    storageInfo.cacheBytes = Int64(cacheSize)
}
```

### Navigation Actions
```swift
func openPrivacyPolicy() {
    // Open URL in Safari/SFSafariViewController
    if let url = URL(string: "https://example.com/privacy") {
        UIApplication.shared.open(url)
    }
}

func openTermsOfService() {
    if let url = URL(string: "https://example.com/terms") {
        UIApplication.shared.open(url)
    }
}

func openHelp() {
    // Navigate to help screen or open URL
}

func rateApp() {
    // Use SKStoreReviewController or App Store URL
    if let url = URL(string: "itms-apps://itunes.apple.com/app/id123456789?action=write-review") {
        UIApplication.shared.open(url)
    }
}
```

## Success Criteria
- [ ] Both files under 70 lines each
- [ ] Compile without errors
- [ ] Clear cache works with confirmation
- [ ] External links open correctly

## Next Phase
→ Phase 6: Main SettingsView Integration
