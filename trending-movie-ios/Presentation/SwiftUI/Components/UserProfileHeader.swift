import SwiftUI

struct UserProfileHeader: View {
    let userName: String
    let avatarImage: String?
    let onWishlistTap: () -> Void

    @State private var profileImage: UIImage?

    var body: some View {
        HStack(spacing: 16) {
            HStack(spacing: 16) {
                avatarView

                VStack(alignment: .leading, spacing: 4) {
                    Text("Hello, \(userName)")
                        .font(DSTypography.h4SwiftUI(weight: .semibold))
                        .foregroundColor(DSColors.primaryTextSwiftUI)

                    Text("Let's stream your favorite movie")
                        .font(DSTypography.h6SwiftUI(weight: .medium))
                        .foregroundColor(DSColors.secondaryTextSwiftUI)
                }
            }

            Spacer()

            wishlistButton
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 8)
    }

    private var avatarView: some View {
        Group {
            if let profileImage = profileImage {
                Image(uiImage: profileImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else if let imageName = avatarImage, !imageName.isEmpty {
                Image(imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                Circle()
                    .fill(Color(hex: "#E8E8E6"))
                    .overlay(
                        Image(systemName: "person.fill")
                            .foregroundColor(DSColors.secondaryTextSwiftUI)
                    )
            }
        }
        .frame(width: 40, height: 40)
        .clipShape(Circle())
    }

    private var wishlistButton: some View {
        Button(action: onWishlistTap) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(DSColors.surfaceSwiftUI.opacity(0.8))
                    .background(
                        VisualEffectBlur(blurStyle: .systemThinMaterialDark)
                            .cornerRadius(12)
                    )

                Image(systemName: "heart.fill")
                    .font(.system(size: 16))
                    .foregroundColor(Color(hex: "#FB4141"))
            }
            .frame(width: 32, height: 32)
        }
    }
}

