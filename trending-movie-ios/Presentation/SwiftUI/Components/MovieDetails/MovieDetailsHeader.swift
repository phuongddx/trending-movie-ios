import SwiftUI

struct MovieDetailsHeader: View {
    let title: String
    let isInWatchlist: Bool
    let onBackTap: () -> Void
    let onWishlistTap: () -> Void

    var body: some View {
        HStack {
            BlurButton(
                icon: "chevron.left",
                size: 32,
                iconColor: .white,
                backgroundColor: DSColors.surfaceSwiftUI.opacity(0.8)
            ) {
                onBackTap()
            }

            Spacer()

            Text(title)
                .font(DSTypography.h4SwiftUI(weight: .semibold))
                .foregroundColor(.white)
                .lineLimit(1)
                .truncationMode(.tail)

            Spacer()

            BlurButton(
                icon: isInWatchlist ? "heart.fill" : "heart",
                size: 32,
                iconColor: isInWatchlist ? Color(hex: "#FB4141") : .white,
                backgroundColor: DSColors.surfaceSwiftUI.opacity(0.8)
            ) {
                onWishlistTap()
            }
        }
        .padding(.horizontal, 24)
        .frame(height: 44)
    }
}

struct MovieDetailsHeader_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            MovieDetailsHeader(
                title: "Riverdale",
                isInWatchlist: false,
                onBackTap: {},
                onWishlistTap: {}
            )
        }
    }
}