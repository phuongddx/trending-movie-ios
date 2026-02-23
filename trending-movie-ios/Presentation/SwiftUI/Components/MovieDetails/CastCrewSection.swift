import SwiftUI

struct CastCrewSection: View {
    let movie: Movie

    // Filter directors from crew
    private var directors: [CrewMember] {
        guard let crew = movie.credits?.crew else { return [] }
        return crew.filter { $0.job.lowercased() == "director" }
    }

    // Filter writers from crew
    private var writers: [CrewMember] {
        guard let crew = movie.credits?.crew else { return [] }
        return crew.filter { $0.department.lowercased() == "writing" }
    }

    // Fallback director from movie.director if no credits
    private var fallbackDirector: String {
        movie.director ?? "Unknown"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Cast and Crew")
                .font(DSTypography.h4SwiftUI(weight: .semibold))
                .foregroundColor(.white)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    // Directors
                    if !directors.isEmpty {
                        ForEach(directors.prefix(2)) { director in
                            CrewMemberCard(
                                name: director.name,
                                role: "Director",
                                avatarImage: director.profilePath
                            )
                        }
                    } else {
                        // Fallback if no credits loaded
                        CrewMemberCard(
                            name: fallbackDirector,
                            role: "Director",
                            avatarImage: nil
                        )
                    }

                    // Writers
                    if !writers.isEmpty {
                        ForEach(writers.prefix(3)) { writer in
                            CrewMemberCard(
                                name: writer.name,
                                role: writer.job,
                                avatarImage: writer.profilePath
                            )
                        }
                    }
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
            if let profilePath = avatarImage {
                AsyncImage(url: URL(string: "https://image.tmdb.org/t/p/w185\(profilePath)")) { image in
                    image.resizable().aspectRatio(contentMode: .fill)
                } placeholder: {
                    Circle().fill(Color(hex: "#E8E8E6"))
                }
                .frame(width: 40, height: 40)
                .clipShape(Circle())
            } else {
                Circle()
                    .fill(Color(hex: "#E8E8E6"))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Image(systemName: "person.fill")
                            .foregroundColor(.gray)
                            .font(.system(size: 20))
                    )
            }

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
