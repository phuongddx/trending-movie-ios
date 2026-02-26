import SwiftUI

// MARK: - Settings Profile Section
/// Displays user profile header with avatar, name, email, and edit button
@available(iOS 15.0, *)
struct SettingsProfileSection: View {
    let displayName: String
    let email: String
    let onEditProfile: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            // Avatar
            ZStack {
                Circle()
                    .fill(DSColors.accentSwiftUI.opacity(0.2))
                    .frame(width: 80, height: 80)

                CinemaxIconView(.person, size: .extraLarge, color: DSColors.accentSwiftUI)
            }
            .accessibilityHidden(true)

            // User Info
            VStack(spacing: 4) {
                Text(displayName)
                    .font(DSTypography.h3SwiftUI(weight: .semibold))
                    .foregroundColor(DSColors.primaryTextSwiftUI)
                    .accessibilityIdentifier("profile_name")

                Text(email)
                    .font(DSTypography.bodySmallSwiftUI())
                    .foregroundColor(DSColors.secondaryTextSwiftUI)
                    .accessibilityIdentifier("profile_email")
            }

            // Edit Profile Button
            DSActionButton(
                title: "Edit Profile",
                style: .secondary,
                size: .small,
                icon: .edit
            ) {
                onEditProfile()
            }
            .accessibilityIdentifier("edit_profile_button")
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(DSColors.surfaceSwiftUI)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Profile: \(displayName), \(email)")
    }
}

// MARK: - Preview
@available(iOS 15.0, *)
#Preview {
    SettingsProfileSection(
        displayName: "Movie Enthusiast",
        email: "movie.fan@email.com",
        onEditProfile: {}
    )
    .padding()
    .background(DSColors.backgroundSwiftUI)
}
