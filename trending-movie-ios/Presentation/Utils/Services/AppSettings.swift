import SwiftUI
import Combine

/// App-wide user settings with persistence
final class AppSettings: ObservableObject {
    static let shared = AppSettings()

    @AppStorage("isHapticEnabled") var isHapticEnabled: Bool = true

    private init() {}
}
