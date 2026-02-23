import SwiftUI

struct CastCarouselSection: View {
    let cast: [CastMember]

    private var displayCast: [CastMember] {
        Array(cast.sorted { ($0.order ?? 0) < ($1.order ?? 0) }.prefix(15))
    }

    var body: some View {
        if !cast.isEmpty {
            VStack(alignment: .leading, spacing: 16) {
                Text("Top Cast")
                    .font(DSTypography.h4SwiftUI(weight: .semibold))
                    .foregroundColor(.white)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(displayCast) { member in
                            CastPhotoCard(member: member)
                        }
                    }
                    .padding(.horizontal, 24)
                }
                .padding(.horizontal, -24)
            }
        }
    }
}

struct CastPhotoCard: View {
    let member: CastMember

    var body: some View {
        VStack(spacing: 8) {
            // Profile Image
            if let profilePath = member.profilePath {
                AsyncImage(url: URL(string: "https://image.tmdb.org/t/p/w185\(profilePath)")) { image in
                    image.resizable().aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle().fill(DSColors.surfaceSwiftUI)
                }
                .frame(width: 80, height: 80)
                .clipShape(Circle())
            } else {
                Circle()
                    .fill(DSColors.surfaceSwiftUI)
                    .frame(width: 80, height: 80)
                    .overlay(
                        Image(systemName: "person.fill")
                            .font(.system(size: 32))
                            .foregroundColor(.gray)
                    )
            }

            // Name
            Text(member.name)
                .font(DSTypography.h6SwiftUI(weight: .semibold))
                .foregroundColor(.white)
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .frame(width: 80)

            // Character
            if let character = member.character {
                Text(character)
                    .font(DSTypography.captionSwiftUI(weight: .regular))
                    .foregroundColor(DSColors.secondaryTextSwiftUI)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .frame(width: 80)
            }
        }
    }
}
