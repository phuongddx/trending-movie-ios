import SwiftUI

// MARK: - Cinemax Icon System
enum CinemaxIcon: String, CaseIterable {
    // Navigation Icons
    case home = "cinemax-home"
    case search = "cinemax-search"
    case person = "cinemax-person"
    case arrowBack = "cinemax-arrow-back"
    case arrowDown = "cinemax-arrow-ios-downward"

    // Media Control Icons
    case pause = "cinemax-pause"
    case audio = "cinemax-audio"
    case fullscreen = "cinemax-fullscreen"
    case closedCaption = "cinemax-closed-caption"
    case hd = "cinemax-hd"

    // Action Icons
    case download = "cinemax-download"
    case downloadOffline = "cinemax-download-for-offline"
    case share = "cinemax-share"
    case heart = "cinemax-heart"
    case star = "cinemax-star"
    case remove = "cinemax-remove"
    case trashBin = "cinemax-trash-bin"

    // Information Icons
    case calendar = "cinemax-calendar"
    case clock = "cinemax-clock"
    case film = "cinemax-film"
    case eyeOff = "cinemax-eye-off"
    case notification = "cinemax-notification"

    // Settings & System Icons
    case settings = "cinemax-settings"
    case edit = "cinemax-edit"
    case globe = "cinemax-globe"
    case padlock = "cinemax-padlock"
    case shield = "cinemax-shield"
    case alert = "cinemax-alert"
    case question = "cinemax-question"

    // Device & Utility Icons
    case devices = "cinemax-devices"
    case premium = "cinemax-workspace-premium"
    case finish = "cinemax-finish"
    case tick = "cinemax-tick"
    case noResults = "cinemax-no-results"
    case folder = "cinemax-folder"

    // SF Symbols fallback mapping
    var systemAlternative: String? {
        switch self {
        case .home: return "house"
        case .search: return "magnifyingglass"
        case .person: return "person.circle"
        case .arrowBack: return "chevron.left"
        case .arrowDown: return "chevron.down"
        case .pause: return "pause"
        case .audio: return "speaker.wave.2"
        case .fullscreen: return "arrow.up.left.and.arrow.down.right"
        case .closedCaption: return "captions.bubble"
        case .hd: return nil // Custom required
        case .download: return "arrow.down.circle"
        case .downloadOffline: return "arrow.down.to.line"
        case .share: return "square.and.arrow.up"
        case .heart: return "heart"
        case .star: return "star"
        case .remove: return "minus.circle"
        case .trashBin: return "trash"
        case .calendar: return "calendar"
        case .clock: return "clock"
        case .film: return "film"
        case .eyeOff: return "eye.slash"
        case .notification: return "bell"
        case .settings: return "gearshape"
        case .edit: return "pencil"
        case .globe: return "globe"
        case .padlock: return "lock"
        case .shield: return "shield"
        case .alert: return "exclamationmark.triangle"
        case .question: return "questionmark.circle"
        case .devices: return "tv.and.hifispeaker"
        case .premium: return "crown"
        case .finish: return "checkmark.circle"
        case .tick: return "checkmark"
        case .noResults: return "doc.text.magnifyingglass"
        case .folder: return "folder"
        }
    }
}

// MARK: - Icon Size Enum
enum DSIconSize {
    case small, medium, large, extraLarge

    var dimension: CGFloat {
        switch self {
        case .small: return 16
        case .medium: return 24
        case .large: return 32
        case .extraLarge: return 48
        }
    }
}

// MARK: - Cinemax Icon View Component
struct CinemaxIconView: View {
    let icon: CinemaxIcon
    let size: DSIconSize
    let color: Color
    let useFallback: Bool

    init(
        _ icon: CinemaxIcon,
        size: DSIconSize = .medium,
        color: Color = DSColors.primaryTextSwiftUI,
        useFallback: Bool = true
    ) {
        self.icon = icon
        self.size = size
        self.color = color
        self.useFallback = useFallback
    }

    var body: some View {
        Group {
            if useFallback, let systemName = icon.systemAlternative {
                Image(systemName: systemName)
                    .resizable()
            } else {
                // Try to load custom icon, fallback to system if available
                if let systemName = icon.systemAlternative {
                    Image(systemName: systemName)
                        .resizable()
                } else {
                    // For icons without system alternative, create a placeholder
                    Rectangle()
                        .fill(color.opacity(0.3))
                        .overlay(
                            Text("IC")
                                .font(.caption2)
                                .foregroundColor(color)
                        )
                }
            }
        }
        .aspectRatio(contentMode: .fit)
        .frame(width: size.dimension, height: size.dimension)
        .foregroundColor(color)
    }
}

// MARK: - Design System Icons
struct DSIcons {

    // MARK: - Navigation
    static func home(size: DSIconSize = .medium, color: Color = DSColors.primaryTextSwiftUI) -> some View {
        CinemaxIconView(.home, size: size, color: color)
    }

    static func search(size: DSIconSize = .medium, color: Color = DSColors.primaryTextSwiftUI) -> some View {
        CinemaxIconView(.search, size: size, color: color)
    }

    static func profile(size: DSIconSize = .medium, color: Color = DSColors.primaryTextSwiftUI) -> some View {
        CinemaxIconView(.person, size: size, color: color)
    }

    static func back(size: DSIconSize = .medium, color: Color = DSColors.primaryTextSwiftUI) -> some View {
        CinemaxIconView(.arrowBack, size: size, color: color)
    }

    static func dropdown(size: DSIconSize = .medium, color: Color = DSColors.primaryTextSwiftUI) -> some View {
        CinemaxIconView(.arrowDown, size: size, color: color)
    }

    // MARK: - Media Controls
    static func pause(size: DSIconSize = .medium, color: Color = DSColors.primaryTextSwiftUI) -> some View {
        CinemaxIconView(.pause, size: size, color: color)
    }

    static func audio(size: DSIconSize = .medium, color: Color = DSColors.primaryTextSwiftUI) -> some View {
        CinemaxIconView(.audio, size: size, color: color)
    }

    static func fullscreen(size: DSIconSize = .medium, color: Color = DSColors.primaryTextSwiftUI) -> some View {
        CinemaxIconView(.fullscreen, size: size, color: color)
    }

    static func closedCaption(size: DSIconSize = .medium, color: Color = DSColors.primaryTextSwiftUI) -> some View {
        CinemaxIconView(.closedCaption, size: size, color: color)
    }

    // MARK: - Actions
    static func download(size: DSIconSize = .medium, color: Color = DSColors.primaryTextSwiftUI) -> some View {
        CinemaxIconView(.download, size: size, color: color)
    }

    static func favorite(size: DSIconSize = .medium, color: Color = DSColors.primaryTextSwiftUI) -> some View {
        CinemaxIconView(.heart, size: size, color: color)
    }

    static func share(size: DSIconSize = .medium, color: Color = DSColors.primaryTextSwiftUI) -> some View {
        CinemaxIconView(.share, size: size, color: color)
    }

    static func rating(size: DSIconSize = .medium, color: Color = DSColors.primaryTextSwiftUI) -> some View {
        CinemaxIconView(.star, size: size, color: color)
    }

    static func remove(size: DSIconSize = .medium, color: Color = DSColors.primaryTextSwiftUI) -> some View {
        CinemaxIconView(.remove, size: size, color: color)
    }

    // MARK: - Information
    static func duration(size: DSIconSize = .medium, color: Color = DSColors.primaryTextSwiftUI) -> some View {
        CinemaxIconView(.clock, size: size, color: color)
    }

    static func calendar(size: DSIconSize = .medium, color: Color = DSColors.primaryTextSwiftUI) -> some View {
        CinemaxIconView(.calendar, size: size, color: color)
    }

    static func film(size: DSIconSize = .medium, color: Color = DSColors.primaryTextSwiftUI) -> some View {
        CinemaxIconView(.film, size: size, color: color)
    }

    static func notification(size: DSIconSize = .medium, color: Color = DSColors.primaryTextSwiftUI) -> some View {
        CinemaxIconView(.notification, size: size, color: color)
    }

    // MARK: - System
    static func settings(size: DSIconSize = .medium, color: Color = DSColors.primaryTextSwiftUI) -> some View {
        CinemaxIconView(.settings, size: size, color: color)
    }

    static func edit(size: DSIconSize = .medium, color: Color = DSColors.primaryTextSwiftUI) -> some View {
        CinemaxIconView(.edit, size: size, color: color)
    }

    static func alert(size: DSIconSize = .medium, color: Color = DSColors.primaryTextSwiftUI) -> some View {
        CinemaxIconView(.alert, size: size, color: color)
    }

    static func success(size: DSIconSize = .medium, color: Color = DSColors.successSwiftUI) -> some View {
        CinemaxIconView(.tick, size: size, color: color)
    }

    static func premium(size: DSIconSize = .medium, color: Color = DSColors.warningSwiftUI) -> some View {
        CinemaxIconView(.premium, size: size, color: color)
    }
}