import SwiftUI
import Combine

// MARK: - Video Quality Enum
enum VideoQuality: String, CaseIterable, Codable {
    case auto = "Auto"
    case low = "Low"
    case medium = "Medium"
    case high = "High"
}

// MARK: - Video Settings Model
struct VideoSettings: Codable {
    var autoplayTrailers: Bool
    var streamingQuality: VideoQuality
    var downloadQuality: VideoQuality

    static let `default` = VideoSettings(
        autoplayTrailers: true,
        streamingQuality: .auto,
        downloadQuality: .high
    )
}

// MARK: - Notification Settings Model
struct NotificationSettings: Codable {
    var pushEnabled: Bool
    var newReleasesEnabled: Bool
    var recommendationsEnabled: Bool

    static let `default` = NotificationSettings(
        pushEnabled: true,
        newReleasesEnabled: true,
        recommendationsEnabled: false
    )
}

// MARK: - Display Settings Model
struct DisplaySettings: Codable {
    var language: String
    var showAgeRatings: Bool
    var hapticFeedbackEnabled: Bool

    static let `default` = DisplaySettings(
        language: "English",
        showAgeRatings: true,
        hapticFeedbackEnabled: true
    )
}

// MARK: - Storage Info Model
struct StorageInfo {
    var downloadedMoviesCount: Int
    var downloadedMoviesSize: String
    var cacheSize: String

    static let `default` = StorageInfo(
        downloadedMoviesCount: 3,
        downloadedMoviesSize: "2.4 GB",
        cacheSize: "156 MB"
    )
}

// MARK: - Settings ViewModel
@MainActor
final class SettingsViewModel: ObservableObject {

    // MARK: - Published State
    @Published var videoSettings: VideoSettings
    @Published var notificationSettings: NotificationSettings
    @Published var displaySettings: DisplaySettings
    @Published var storageInfo: StorageInfo

    // MARK: - Alert State
    @Published var showClearCacheConfirmation = false
    @Published var showSignOutConfirmation = false

    // MARK: - App Info
    var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }

    var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }

    var versionString: String {
        "\(appVersion) (\(buildNumber))"
    }

    // MARK: - UserDefaults Keys
    private enum Keys {
        static let autoplayTrailers = "autoplayTrailers"
        static let videoQuality = "videoQuality"
        static let downloadQuality = "downloadQuality"
        static let selectedLanguage = "selectedLanguage"
        static let showAgeRatings = "showAgeRatings"
        static let pushNotifications = "pushNotifications"
        static let newReleasesNotif = "newReleasesNotif"
        static let recommendationsNotif = "recommendationsNotif"
        static let isHapticEnabled = "isHapticEnabled"
    }

    // MARK: - Initialization
    init() {
        // Load video settings
        videoSettings = VideoSettings(
            autoplayTrailers: UserDefaults.standard.bool(forKey: Keys.autoplayTrailers),
            streamingQuality: VideoQuality(rawValue: UserDefaults.standard.string(forKey: Keys.videoQuality) ?? "Auto") ?? .auto,
            downloadQuality: VideoQuality(rawValue: UserDefaults.standard.string(forKey: Keys.downloadQuality) ?? "High") ?? .high
        )

        // Load notification settings
        notificationSettings = NotificationSettings(
            pushEnabled: UserDefaults.standard.object(forKey: Keys.pushNotifications) as? Bool ?? true,
            newReleasesEnabled: UserDefaults.standard.object(forKey: Keys.newReleasesNotif) as? Bool ?? true,
            recommendationsEnabled: UserDefaults.standard.object(forKey: Keys.recommendationsNotif) as? Bool ?? false
        )

        // Load display settings
        displaySettings = DisplaySettings(
            language: UserDefaults.standard.string(forKey: Keys.selectedLanguage) ?? "English",
            showAgeRatings: UserDefaults.standard.object(forKey: Keys.showAgeRatings) as? Bool ?? true,
            hapticFeedbackEnabled: UserDefaults.standard.object(forKey: Keys.isHapticEnabled) as? Bool ?? true
        )

        // Initialize storage info
        storageInfo = StorageInfo.default

        // Set up persistence
        setupPersistence()
    }

    // MARK: - Persistence
    private func setupPersistence() {
        // Observe changes and persist to UserDefaults
        $videoSettings
            .sink { [weak self] settings in
                self?.saveVideoSettings(settings)
            }
            .store(in: &cancellables)

        $notificationSettings
            .sink { [weak self] settings in
                self?.saveNotificationSettings(settings)
            }
            .store(in: &cancellables)

        $displaySettings
            .sink { [weak self] settings in
                self?.saveDisplaySettings(settings)
            }
            .store(in: &cancellables)
    }

    private var cancellables = Set<AnyCancellable>()

    private func saveVideoSettings(_ settings: VideoSettings) {
        UserDefaults.standard.set(settings.autoplayTrailers, forKey: Keys.autoplayTrailers)
        UserDefaults.standard.set(settings.streamingQuality.rawValue, forKey: Keys.videoQuality)
        UserDefaults.standard.set(settings.downloadQuality.rawValue, forKey: Keys.downloadQuality)
    }

    private func saveNotificationSettings(_ settings: NotificationSettings) {
        UserDefaults.standard.set(settings.pushEnabled, forKey: Keys.pushNotifications)
        UserDefaults.standard.set(settings.newReleasesEnabled, forKey: Keys.newReleasesNotif)
        UserDefaults.standard.set(settings.recommendationsEnabled, forKey: Keys.recommendationsNotif)
    }

    private func saveDisplaySettings(_ settings: DisplaySettings) {
        UserDefaults.standard.set(settings.language, forKey: Keys.selectedLanguage)
        UserDefaults.standard.set(settings.showAgeRatings, forKey: Keys.showAgeRatings)
        UserDefaults.standard.set(settings.hapticFeedbackEnabled, forKey: Keys.isHapticEnabled)
    }

    // MARK: - Actions

    /// Clears all cached data
    func clearCache() {
        URLCache.shared.removeAllCachedResponses()
        refreshStorageInfo()
    }

    /// Signs out the current user
    func signOut() {
        // TODO: Implement with auth service
        // AuthService.shared.signOut()
    }

    /// Refreshes storage information
    func refreshStorageInfo() {
        // Calculate cache size
        let cache = URLCache.shared
        let cacheSizeMB = ByteCountFormatter.string(fromByteCount: Int64(cache.currentDiskUsage), countStyle: .file)

        storageInfo = StorageInfo(
            downloadedMoviesCount: storageInfo.downloadedMoviesCount,
            downloadedMoviesSize: storageInfo.downloadedMoviesSize,
            cacheSize: cacheSizeMB
        )
    }
}
