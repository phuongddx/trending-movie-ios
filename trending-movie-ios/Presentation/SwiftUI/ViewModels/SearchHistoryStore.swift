import Foundation
import Combine

/// Manages persistent search history with UserDefaults storage
final class SearchHistoryStore: ObservableObject {
    // MARK: - Published Properties
    @Published private(set) var recentSearches: [String] = []

    // MARK: - Configuration
    private enum Configuration {
        static let userDefaultsKey = "com.cinemax.searchHistory"
        static let maxItems = 5
    }

    // MARK: - Initialization
    init() {
        load()
    }

    // MARK: - Public Methods

    /// Add a search query to history
    /// - Parameter query: The search query to add
    func add(_ query: String) {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        // Remove if exists (re-add at front)
        recentSearches.removeAll { $0.localizedCaseInsensitiveCompare(trimmed) == .orderedSame }

        // Insert at front
        recentSearches.insert(trimmed, at: 0)

        // Enforce limit
        if recentSearches.count > Configuration.maxItems {
            recentSearches.removeLast()
        }

        save()
    }

    /// Remove a specific search from history
    /// - Parameter query: The query to remove
    func remove(_ query: String) {
        recentSearches.removeAll { $0 == query }
        save()
    }

    /// Clear all search history
    func clear() {
        recentSearches.removeAll()
        save()
    }

    // MARK: - Private Methods

    private func save() {
        UserDefaults.standard.set(recentSearches, forKey: Configuration.userDefaultsKey)
    }

    private func load() {
        recentSearches = UserDefaults.standard.stringArray(forKey: Configuration.userDefaultsKey) ?? []
    }
}
