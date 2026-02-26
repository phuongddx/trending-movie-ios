import Foundation

// MARK: - Settings Navigation Destinations
enum SettingsDestination: String, Hashable, CaseIterable {
    case streamingQuality
    case downloadQuality
    case language
    case manageDownloads
    case privacyPolicy
    case termsOfService
    case helpSupport
    case rateApp
    case editProfile

    var title: String {
        switch self {
        case .streamingQuality: return "Streaming Quality"
        case .downloadQuality: return "Download Quality"
        case .language: return "Language"
        case .manageDownloads: return "Manage Downloads"
        case .privacyPolicy: return "Privacy Policy"
        case .termsOfService: return "Terms of Service"
        case .helpSupport: return "Help & Support"
        case .rateApp: return "Rate This App"
        case .editProfile: return "Edit Profile"
        }
    }
}
