import SwiftUI

struct ErrorView: View {
    let error: Error
    let retryAction: (() -> Void)?

    init(error: Error, retryAction: (() -> Void)? = nil) {
        self.error = error
        self.retryAction = retryAction
    }

    var body: some View {
        VStack(spacing: DSSpacing.lg) {
            // Error icon
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 64))
                .foregroundColor(DSColors.accentSwiftUI)

            // Error title
            Text("Something went wrong")
                .font(DSTypography.h3SwiftUI(weight: .semibold))
                .foregroundColor(DSColors.primaryTextSwiftUI)
                .multilineTextAlignment(.center)

            // Error message
            Text(errorMessage)
                .font(DSTypography.bodyMediumSwiftUI())
                .foregroundColor(DSColors.secondaryTextSwiftUI)
                .multilineTextAlignment(.center)
                .padding(.horizontal, DSSpacing.lg)

            // Retry button
            if let retryAction = retryAction {
                DSActionButton(
                    title: "Try Again",
                    style: .primary
                ) {
                    retryAction()
                }
                .padding(.top, DSSpacing.md)
            }
        }
        .padding(DSSpacing.xl)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(DSColors.backgroundSwiftUI)
    }

    private var errorMessage: String {
        if let localizedError = error as? LocalizedError {
            return localizedError.errorDescription ?? "An unexpected error occurred"
        } else {
            return error.localizedDescription
        }
    }
}

// MARK: - Convenience initializers for common error types

extension ErrorView {
    static func networkError(retryAction: @escaping () -> Void) -> ErrorView {
        ErrorView(
            error: NetworkError.connectionFailed,
            retryAction: retryAction
        )
    }

    static func notFoundError() -> ErrorView {
        ErrorView(error: NetworkError.notFound)
    }

    static func serverError(retryAction: @escaping () -> Void) -> ErrorView {
        ErrorView(
            error: NetworkError.serverError,
            retryAction: retryAction
        )
    }
}

// MARK: - Common error types

enum NetworkError: LocalizedError {
    case connectionFailed
    case notFound
    case serverError
    case timeout

    var errorDescription: String? {
        switch self {
        case .connectionFailed:
            return "Please check your internet connection and try again."
        case .notFound:
            return "The requested content could not be found."
        case .serverError:
            return "Our servers are experiencing issues. Please try again later."
        case .timeout:
            return "The request timed out. Please try again."
        }
    }
}

// MARK: - Previews

struct ErrorView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // With retry action
            ErrorView(
                error: NetworkError.connectionFailed,
                retryAction: {
                    print("Retry tapped")
                }
            )
            .previewDisplayName("With Retry")

            // Without retry action
            ErrorView(error: NetworkError.notFound)
                .previewDisplayName("Without Retry")

            // Server error
            ErrorView.serverError {
                print("Server retry")
            }
            .previewDisplayName("Server Error")
        }
    }
}