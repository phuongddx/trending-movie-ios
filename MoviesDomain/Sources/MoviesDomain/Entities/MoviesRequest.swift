import Foundation

public struct MoviesRequest: Equatable {
    public let page: Int
    public let query: String?
    public let timeWindow: String?

    public init(page: Int, query: String? = nil, timeWindow: String? = nil) {
        self.page = page
        self.query = query
        self.timeWindow = timeWindow
    }
}