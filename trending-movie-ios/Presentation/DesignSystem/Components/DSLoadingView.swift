import SwiftUI
import UIKit

// MARK: - SwiftUI Loading Components
@available(iOS 13.0, *)
struct DSLoadingSpinner: View {
    @Environment(\.dsTheme) private var theme
    @State private var isAnimating = false

    var body: some View {
        Circle()
            .trim(from: 0, to: 0.75)
            .stroke(
                DSColors.spinnerPrimary(for: theme).swiftUIColor,
                style: StrokeStyle(lineWidth: 3, lineCap: .round)
            )
            .frame(width: DSSpacing.Height.loadingSpinner, height: DSSpacing.Height.loadingSpinner)
            .rotationEffect(.degrees(isAnimating ? 360 : 0))
            .animation(
                Animation.linear(duration: 1.0)
                    .repeatForever(autoreverses: false),
                value: isAnimating
            )
            .onAppear {
                isAnimating = true
            }
    }
}

@available(iOS 13.0, *)
struct DSFullScreenLoading: View {
    @Environment(\.dsTheme) private var theme

    var body: some View {
        ZStack {
            DSColors.primaryBackgroundSwiftUI(for: theme)
                .ignoresSafeArea()

            DSLoadingSpinner()
        }
    }
}

@available(iOS 13.0, *)
struct DSSkeletonView: View {
    @Environment(\.dsTheme) private var theme
    @State private var isAnimating = false

    let width: CGFloat
    let height: CGFloat
    let cornerRadius: CGFloat

    init(width: CGFloat = 200, height: CGFloat = 20, cornerRadius: CGFloat = DSSpacing.CornerRadius.small) {
        self.width = width
        self.height = height
        self.cornerRadius = cornerRadius
    }

    var body: some View {
        Rectangle()
            .fill(
                LinearGradient(
                    colors: [
                        DSColors.shimmerBackground(for: theme).swiftUIColor,
                        DSColors.shimmerHighlight(for: theme).swiftUIColor,
                        DSColors.shimmerBackground(for: theme).swiftUIColor
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .frame(width: width, height: height)
            .cornerRadius(cornerRadius)
            .scaleEffect(x: isAnimating ? 1.0 : 0.8, anchor: .leading)
            .animation(
                Animation.easeInOut(duration: 1.0)
                    .repeatForever(autoreverses: true),
                value: isAnimating
            )
            .onAppear {
                isAnimating = true
            }
    }
}

@available(iOS 13.0, *)
struct DSMovieCardSkeleton: View {
    var body: some View {
        HStack(spacing: DSSpacing.md) {
            // Poster skeleton
            DSSkeletonView(
                width: 60,
                height: 90,
                cornerRadius: DSSpacing.CornerRadius.medium
            )

            VStack(alignment: .leading, spacing: DSSpacing.xs) {
                // Title skeleton
                DSSkeletonView(width: 180, height: 16)

                // Release date skeleton
                DSSkeletonView(width: 120, height: 14)

                // Rating skeleton
                DSSkeletonView(width: 100, height: 14)

                Spacer()

                // Overview skeleton lines
                DSSkeletonView(width: 200, height: 12)
                DSSkeletonView(width: 180, height: 12)
                DSSkeletonView(width: 160, height: 12)
            }

            Spacer()
        }
        .padding(DSSpacing.Padding.card)
    }
}

// MARK: - UIKit Loading Components (for backward compatibility)
class DSLoadingViewController: UIViewController {
    private let spinner = UIActivityIndicatorView(style: .large)

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        view.backgroundColor = DSColors.primaryBackground(for: DSThemeManager.shared.currentTheme)

        spinner.color = DSColors.spinnerPrimary(for: DSThemeManager.shared.currentTheme)
        spinner.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(spinner)

        NSLayoutConstraint.activate([
            spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            spinner.widthAnchor.constraint(equalToConstant: DSSpacing.Height.loadingSpinner),
            spinner.heightAnchor.constraint(equalToConstant: DSSpacing.Height.loadingSpinner)
        ])

        spinner.startAnimating()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        spinner.startAnimating()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        spinner.stopAnimating()
    }
}

// MARK: - Enhanced Loading View (UIKit)
class EnhancedLoadingView {
    private static var loadingViewController: DSLoadingViewController?

    static func show(in window: UIWindow? = nil) {
        DispatchQueue.main.async {
            guard loadingViewController == nil else { return }

            let targetWindow = window ?? UIApplication.shared.windows.first { $0.isKeyWindow }
            guard let window = targetWindow else { return }

            let loadingVC = DSLoadingViewController()
            loadingVC.modalPresentationStyle = .overFullScreen
            loadingVC.modalTransitionStyle = .crossDissolve

            if let rootViewController = window.rootViewController {
                rootViewController.present(loadingVC, animated: true)
                loadingViewController = loadingVC
            }
        }
    }

    static func hide() {
        DispatchQueue.main.async {
            loadingViewController?.dismiss(animated: true) {
                loadingViewController = nil
            }
        }
    }
}

// MARK: - UIColor Extension for SwiftUI
@available(iOS 13.0, *)
extension UIColor {
    var swiftUIColor: Color {
        return Color(self)
    }
}