# SwiftUI Loading Patterns & Image Optimization Research

**Date:** 2026-02-23
**Topic:** Shimmer Loading, Progressive Image Loading, Pull-to-Refresh

---

## 1. Shimmer Loading Effect in SwiftUI

### 1.1 Core Implementation

**Basic Shimmer ViewModifier:**
```swift
struct Shimmer: ViewModifier {
    @State private var isInitialState = true

    func body(content: Content) -> some View {
        content
            .mask(
                LinearGradient(
                    gradient: Gradient(colors: [
                        .black.opacity(0.4),
                        .black,
                        .black.opacity(0.4)
                    ]),
                    startPoint: isInitialState ? UnitPoint(x: -0.3, y: -0.3) : UnitPoint(x: 1, y: 1),
                    endPoint: isInitialState ? UnitPoint(x: 0, y: 0) : UnitPoint(x: 1.3, y: 1.3)
                )
            )
            .onAppear {
                withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                    isInitialState = false
                }
            }
    }
}

// Usage extension
extension View {
    func shimmer() -> some View {
        modifier(Shimmer())
    }
}
```

### 1.2 Skeleton View Components

**Reusable Skeleton Components:**
```swift
struct SkeletonRectangle: View {
    let width: CGFloat?
    let height: CGFloat
    let cornerRadius: CGFloat

    var body: some View {
        Rectangle()
            .fill(Color.gray.opacity(0.3))
            .frame(width: width, height: height)
            .cornerRadius(cornerRadius)
            .shimmer()
    }
}

struct SkeletonCircle: View {
    let size: CGFloat

    var body: some View {
        Circle()
            .fill(Color.gray.opacity(0.3))
            .frame(width: size, height: size)
            .shimmer()
    }
}

// Movie card skeleton example
struct MovieCardSkeleton: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            SkeletonRectangle(width: nil, height: 200, cornerRadius: 12)
            SkeletonRectangle(width: 150, height: 16, cornerRadius: 4)
            SkeletonRectangle(width: 100, height: 12, cornerRadius: 4)
        }
        .padding()
    }
}
```

### 1.3 Performance Considerations

| Tip | Recommendation |
|-----|----------------|
| Limit concurrent animations | No more than **3 shimmer effects** per screen |
| Reuse instances | Use singleton or view pool pattern |
| Pause timing | Set to **0.3-0.5 seconds** for list loading |
| Stop promptly | Set `shimmering = false` immediately when data loads |
| Keep views simple | Simpler content views = better animation performance |

### 1.4 Conditional Shimmer with Loading State

```swift
struct ShimmerContainer<Content: View, Placeholder: View>: View {
    let isLoading: Bool
    @ViewBuilder let content: () -> Content
    @ViewBuilder let placeholder: () -> Placeholder

    var body: some View {
        if isLoading {
            placeholder()
                .shimmer()
        } else {
            content()
        }
    }
}

// Usage
ShimmerContainer(isLoading: viewModel.isLoading) {
    AsyncImage(url: movie.posterURL) { image in
        image.resizable()
    } placeholder: {
        Color.gray
    }
} placeholder: {
    Rectangle().fill(Color.gray.opacity(0.3))
}
```

**Recommended Libraries:**
- [SwiftUI-Shimmer](https://github.com/markiv/SwiftUI-Shimmer) - Native SwiftUI modifier
- [Facebook Shimmer](https://github.com/facebook/Shimmer) - Original (UIKit)

---

## 2. Progressive Image Loading in SwiftUI

### 2.1 AsyncImage Limitations (iOS 15+)

Native `AsyncImage` has limited caching and no progressive loading. For production apps, use specialized libraries.

**Basic AsyncImage:**
```swift
AsyncImage(url: URL(string: "https://example.com/image.jpg")) { phase in
    switch phase {
    case .empty:
        ProgressView()
    case .success(let image):
        image.resizable()
    case .failure:
        Image(systemName: "photo")
    @unknown default:
        EmptyView()
    }
}
```

### 2.2 Kingfisher (Recommended for iOS)

**Installation:**
```swift
// Package.swift
dependencies: [
    .package(url: "https://github.com/onevcat/Kingfisher.git", from: "8.0.0")
]
```

**SwiftUI KFImage Usage:**
```swift
import Kingfisher

struct MoviePosterView: View {
    let url: URL?

    var body: some View {
        KFImage(url)
            .placeholder { ProgressView() }
            .setProcessor(DownsamplingImageProcessor(size: CGSize(width: 300, height: 450)))
            .fade(duration: 0.25)
            .cacheMemoryOnly()
            .onProgress { receivedSize, totalSize in
                let progress = Double(receivedSize) / Double(totalSize)
                print("Download progress: \(Int(progress * 100))%")
            }
            .onSuccess { result in
                print("Loaded from cache: \(result.cacheType)")
            }
            .onFailure { error in
                print("Failed: \(error.localizedDescription)")
            }
            .resizable()
            .aspectRatio(contentMode: .fill)
    }
}
```

**Advanced Options:**
```swift
let processor = DownsamplingImageProcessor(size: targetSize)
             |> RoundCornerImageProcessor(cornerRadius: 20)

KFImage.url(url)
    .placeholder(placeholderImage)
    .setProcessor(processor)
    .loadDiskFileSynchronously()
    .cacheMemoryOnly()
    .fade(duration: 0.25)
    .lowDataModeSource(.network(lowResolutionURL))
    .onProgress { receivedSize, totalSize in }
    .onSuccess { result in }
    .onFailure { error in }
```

### 2.3 SDWebImageSwiftUI (Alternative)

**Installation:**
```swift
dependencies: [
    .package(url: "https://github.com/SDWebImage/SDWebImageSwiftUI.git", from: "3.0.0")
]
```

**WebImage Usage:**
```swift
import SDWebImageSwiftUI

struct ProgressiveImageView: View {
    @State private var progress: Double = 0

    var body: some View {
        VStack {
            WebImage(url: URL(string: "https://example.com/large-image.jpg"))
                .resizable()
                .onProgress { receivedSize, expectedSize in
                    progress = Double(receivedSize) / Double(expectedSize)
                }
                .indicator { isAnimating, progressValue in
                    ProgressView(value: progressValue.wrappedValue)
                        .progressViewStyle(.circular)
                        .opacity(isAnimating.wrappedValue ? 1 : 0)
                }
                .transition(.fade(duration: 0.5))
                .scaledToFit()
                .frame(height: 400)

            Text("Progress: \(Int(progress * 100))%")
        }
    }
}
```

**AnimatedImage for GIF/APNG:**
```swift
AnimatedImage(
    url: URL(string: "https://example.com/animation.webp"),
    options: [.progressiveLoad]
) {
    ProgressView()
}
.resizable()
.indicator(.progress)
.transition(SDWebImageTransition.fade)
.customLoopCount(5)
.playbackRate(2.0)
```

### 2.4 Custom Two-Tier Cache Implementation

```swift
class ImageCache {
    static let shared = ImageCache()
    private let memoryCache = NSCache<NSString, NSData>()

    init() {
        memoryCache.countLimit = 100
        memoryCache.totalCostLimit = 100 * 1024 * 1024  // 100MB

        NotificationCenter.default.addObserver(
            forName: UIApplication.didReceiveMemoryWarningNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.memoryCache.removeAllObjects()
        }
    }

    func get(_ key: String) -> Data? {
        memoryCache.object(forKey: key as NSString) as Data?
    }

    func set(_ key: String, data: Data) {
        memoryCache.setObject(data as NSData, forKey: key as NSString, cost: data.count)
    }
}
```

### 2.5 Library Comparison

| Feature | AsyncImage | Kingfisher | SDWebImageSwiftUI |
|---------|------------|------------|-------------------|
| Memory Cache | No | Yes | Yes |
| Disk Cache | No | Yes | Yes |
| Progressive Load | No | Yes | Yes |
| Prefetching | No | Yes | Yes |
| GIF Support | No | Yes | Yes |
| Image Processing | No | Yes | Yes |
| SwiftUI Native | Yes | Yes | Yes |
| iOS 14 Support | No | Yes | Yes |

**Recommendation:** Use **Kingfisher** for this project (already Swift 6 & Swift Concurrency ready).

---

## 3. Pull-to-Refresh in SwiftUI

### 3.1 Native .refreshable Modifier (iOS 15+)

**Basic MVVM Pattern:**
```swift
class MovieListViewModel: ObservableObject {
    @Published var movies: [Movie] = []
    @Published var isLoading = false
    @Published var error: Error?

    @MainActor
    func refresh() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let data = try await fetchMovies()
            movies = data
        } catch {
            self.error = error
        }
    }
}

struct MovieListView: View {
    @StateObject private var viewModel = MovieListViewModel()

    var body: some View {
        NavigationStack {
            List(viewModel.movies) { movie in
                MovieRow(movie: movie)
            }
            .refreshable {
                await viewModel.refresh()
            }
            .task {
                if viewModel.movies.isEmpty {
                    await viewModel.refresh()
                }
            }
        }
    }
}
```

### 3.2 ScrollView with Refreshable

```swift
struct ScrollViewRefreshDemo: View {
    @StateObject private var viewModel = ContentViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(viewModel.items) { item in
                        ItemCard(item: item)
                    }
                }
                .padding()
            }
            .refreshable {
                await viewModel.refresh()
            }
            .navigationTitle("Items")
        }
    }
}
```

### 3.3 iOS 14 Compatibility (Custom Refresh Control)

For iOS 14 support, use `UIViewRepresentable`:

```swift
struct RefreshControl: UIViewRepresentable {
    var onRefresh: () -> Void

    func makeUIView(context: Context) -> UIRefreshControl {
        let control = UIRefreshControl()
        control.addTarget(context.coordinator, action: #selector(Coordinator.handleRefresh), for: .valueChanged)
        return control
    }

    func updateUIView(_ uiView: UIRefreshControl, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(onRefresh: onRefresh)
    }

    class Coordinator {
        let onRefresh: () -> Void

        init(onRefresh: @escaping () -> Void) {
            self.onRefresh = onRefresh
        }

        @objc func handleRefresh() {
            onRefresh()
        }
    }
}

// Usage in iOS 14 List
struct LegacyRefreshList: View {
    @StateObject private var viewModel = ContentViewModel()

    var body: some View {
        List {
            ForEach(viewModel.items) { item in
                ItemRow(item: item)
            }
            .listRowBackground(
                RefreshControl {
                    viewModel.refresh()
                }
            )
        }
    }
}
```

### 3.4 Custom Refresh Indicator

```swift
struct CustomRefreshable<Content: View>: View {
    @Binding var isRefreshing: Bool
    var action: () async -> Void
    @ViewBuilder let content: () -> Content

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                if isRefreshing {
                    ProgressView()
                        .padding()
                }
                content()
            }
        }
        .simultaneousGesture(
            DragGesture(minimumDistance: 50)
                .onEnded { _ in
                    if !isRefreshing {
                        Task {
                            isRefreshing = true
                            await action()
                            isRefreshing = false
                        }
                    }
                }
        )
    }
}
```

### 3.5 Integration with Combine

```swift
class MovieListViewModel: ObservableObject {
    @Published var movies: [Movie] = []
    @Published var isLoading = false

    private var cancellables = Set<AnyCancellable>()
    private let movieService: MovieServiceProtocol

    init(movieService: MovieServiceProtocol) {
        self.movieService = movieService
    }

    @MainActor
    func refresh() async {
        isLoading = true

        // Using async/await with Combine bridge
        await withCheckedContinuation { continuation in
            movieService.fetchTrendingMovies()
                .receive(on: DispatchQueue.main)
                .sink(
                    receiveCompletion: { [weak self] _ in
                        self?.isLoading = false
                        continuation.resume()
                    },
                    receiveValue: { [weak self] movies in
                        self?.movies = movies
                    }
                )
                .store(in: &cancellables)
        }
    }
}
```

---

## 4. Integration Recommendations for This Project

### 4.1 Current Project Context
- iOS 14.0+ minimum target
- Uses Combine with Moya for networking
- Factory pattern for DI
- Clean Architecture with separate Domain/Data layers

### 4.2 Recommended Implementation

**1. Shimmer Loading:**
- Implement custom `Shimmer` ViewModifier (no external dependency)
- Create skeleton components matching existing card layouts

**2. Image Loading:**
- Add **Kingfisher** via SPM (best SwiftUI support, Swift 6 ready)
- Create `RemoteImageView` wrapper for consistent usage
- Implement placeholder/error states matching design system

**3. Pull-to-Refresh:**
- Use `.refreshable` with `@available` check for iOS 15+
- Provide `UIViewRepresentable` fallback for iOS 14
- Integrate with existing ViewModel pattern

### 4.3 Sample Integration Code

```swift
// RemoteImageView.swift
import Kingfisher
import SwiftUI

struct RemoteImageView: View {
    let url: URL?
    let width: CGFloat?
    let height: CGFloat

    var body: some View {
        KFImage(url)
            .placeholder {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .shimmer()
            }
            .setProcessor(DownsamplingImageProcessor(size: CGSize(width: width ?? 300, height: height ?? 450)))
            .fade(duration: 0.25)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: width, height: height)
            .clipped()
    }
}

// MovieListView with all features
struct MovieListView: View {
    @StateObject private var viewModel: MovieListViewModel

    var body: some View {
        Group {
            if viewModel.isLoading && viewModel.movies.isEmpty {
                ForEach(0..<5) { _ in MovieCardSkeleton() }
            } else {
                movieList
            }
        }
    }

    @ViewBuilder
    private var movieList: some View {
        if #available(iOS 15.0, *) {
            List(viewModel.movies) { movie in
                MovieRow(movie: movie)
            }
            .refreshable {
                await viewModel.refresh()
            }
        } else {
            iOS14RefreshableList(
                isRefreshing: $viewModel.isRefreshing,
                action: { viewModel.refresh() }
            ) {
                ForEach(viewModel.movies) { movie in
                    MovieRow(movie: movie)
                }
            }
        }
    }
}
```

---

## 5. Unresolved Questions

1. **Kingfisher SPM Integration:** Does the project already use SPM, or should it be added via Xcode?
2. **Cache Size Limits:** What are the optimal memory/disk cache sizes for movie poster images?
3. **Prefetching Strategy:** Should prefetch be implemented for upcoming cells in movie lists?
4. **iOS 14 Support Timeline:** Is iOS 14 support still required, or can we drop to iOS 15+?
5. **Design System Alignment:** What are the exact corner radius and sizing values for skeleton components?

---

## Sources

- [SwiftUI-Shimmer (GitHub)](https://github.com/markiv/SwiftUI-Shimmer)
- [Kingfisher (GitHub)](https://github.com/onevcat/Kingfisher)
- [SDWebImageSwiftUI (GitHub)](https://github.com/SDWebImage/SDWebImageSwiftUI)
- [Apple SwiftUI Documentation - refreshable](https://developer.apple.com/documentation/swiftui/view/refreshable(action:))
- [Kingfisher Wiki - SwiftUI Support](https://github.com/onevcat/Kingfisher/wiki/SwiftUI-Support)
