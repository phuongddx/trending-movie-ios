import Foundation

struct StoredMovie: Codable {
    let id: String
    let title: String?
    let posterPath: String?
    let overview: String?
    let releaseDate: Date?
    let voteAverage: String?
    let dateAdded: Date

    func toMovie() -> Movie {
        return Movie(
            id: id,
            title: title,
            posterPath: posterPath,
            overview: overview,
            releaseDate: releaseDate,
            voteAverage: voteAverage
        )
    }
}

@MainActor
class MovieStorage: ObservableObject {
    static let shared = MovieStorage()

    @Published var watchlistMovies: [Movie] = []
    @Published var favoriteMovies: [Movie] = []

    private let watchlistKey = "WatchlistMovies"
    private let favoritesKey = "FavoriteMovies"

    private init() {
        loadWatchlist()
        loadFavorites()
    }

    // MARK: - Watchlist Operations
    func addToWatchlist(_ movie: Movie) {
        guard !isInWatchlist(movie) else { return }

        let storedMovie = StoredMovie(
            id: movie.id,
            title: movie.title,
            posterPath: movie.posterPath,
            overview: movie.overview,
            releaseDate: movie.releaseDate,
            voteAverage: movie.voteAverage,
            dateAdded: Date()
        )

        var stored = loadStoredMovies(for: watchlistKey)
        stored.append(storedMovie)
        saveStoredMovies(stored, for: watchlistKey)
        loadWatchlist()
    }

    func removeFromWatchlist(_ movie: Movie) {
        var stored = loadStoredMovies(for: watchlistKey)
        stored.removeAll { $0.id == movie.id }
        saveStoredMovies(stored, for: watchlistKey)
        loadWatchlist()
    }

    func isInWatchlist(_ movie: Movie) -> Bool {
        watchlistMovies.contains { $0.id == movie.id }
    }

    private func loadWatchlist() {
        let stored = loadStoredMovies(for: watchlistKey)
        watchlistMovies = stored
            .sorted { $0.dateAdded > $1.dateAdded }
            .map { $0.toMovie() }
    }

    // MARK: - Favorites Operations
    func addToFavorites(_ movie: Movie) {
        guard !isFavorite(movie) else { return }

        let storedMovie = StoredMovie(
            id: movie.id,
            title: movie.title,
            posterPath: movie.posterPath,
            overview: movie.overview,
            releaseDate: movie.releaseDate,
            voteAverage: movie.voteAverage,
            dateAdded: Date()
        )

        var stored = loadStoredMovies(for: favoritesKey)
        stored.append(storedMovie)
        saveStoredMovies(stored, for: favoritesKey)
        loadFavorites()
    }

    func removeFromFavorites(_ movie: Movie) {
        var stored = loadStoredMovies(for: favoritesKey)
        stored.removeAll { $0.id == movie.id }
        saveStoredMovies(stored, for: favoritesKey)
        loadFavorites()
    }

    func isFavorite(_ movie: Movie) -> Bool {
        favoriteMovies.contains { $0.id == movie.id }
    }

    private func loadFavorites() {
        let stored = loadStoredMovies(for: favoritesKey)
        favoriteMovies = stored
            .sorted { $0.dateAdded > $1.dateAdded }
            .map { $0.toMovie() }
    }

    // MARK: - UserDefaults Storage
    private func loadStoredMovies(for key: String) -> [StoredMovie] {
        guard let data = UserDefaults.standard.data(forKey: key),
              let movies = try? JSONDecoder().decode([StoredMovie].self, from: data) else {
            return []
        }
        return movies
    }

    private func saveStoredMovies(_ movies: [StoredMovie], for key: String) {
        guard let data = try? JSONEncoder().encode(movies) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }
}