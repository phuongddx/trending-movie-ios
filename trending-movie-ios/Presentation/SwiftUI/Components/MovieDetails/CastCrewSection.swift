import SwiftUI

struct CastCrewSection: View {
    let movie: Movie

    private var director: String {
        movie.director ?? "Jon Watts"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Cast and Crew")
                .font(DSTypography.h4SwiftUI(weight: .semibold))
                .foregroundColor(.white)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    CrewMemberCard(
                        name: director,
                        role: "Directors",
                        avatarImage: nil
                    )

                    CrewMemberCard(
                        name: "Chris McKenna",
                        role: "Writers",
                        avatarImage: nil
                    )

                    CrewMemberCard(
                        name: "Erik Sommers",
                        role: "Writers",
                        avatarImage: nil
                    )
                }
                .padding(.horizontal, 24)
            }
        }
    }
}

struct CrewMemberCard: View {
    let name: String
    let role: String
    let avatarImage: String?

    var body: some View {
        HStack(spacing: 12) {
            // Avatar
            Circle()
                .fill(Color(hex: "#E8E8E6"))
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: "person.fill")
                        .foregroundColor(.gray)
                        .font(.system(size: 20))
                )

            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(role)
                    .font(DSTypography.h7SwiftUI(weight: .medium))
                    .foregroundColor(DSColors.secondaryTextSwiftUI)

                Text(name)
                    .font(DSTypography.h5SwiftUI(weight: .semibold))
                    .foregroundColor(.white)
                    .lineLimit(2)
            }
            .frame(maxWidth: 110, alignment: .leading)
        }
        .frame(width: 162)
    }
}

struct CastCrewSection_Previews: PreviewProvider {
    static var previews: some View {
        let mockMovie = Movie(
            id: "1",
            title: "Sample Movie",
            posterPath: nil,
            overview: "Sample overview",
            releaseDate: Date(),
            voteAverage: "8.5",
            director: "Jon Watts"
        )

        ZStack {
            DSColors.backgroundSwiftUI.ignoresSafeArea()

            CastCrewSection(movie: mockMovie)
        }
    }
}