import SwiftUI

struct StoryLineSection: View {
    let movie: Movie
    @State private var isExpanded = false

    private var description: String {
        movie.overview ?? "Originally a story from Archie Comics which started in 1941, Riverdale centres around a group of high school students who are shocked by the death of classmate, Jason Blossom. Together they unravel the secrets of Riverdale and who..."
    }

    private var shouldShowMore: Bool {
        description.count > 200
    }

    private var displayText: String {
        if isExpanded || !shouldShowMore {
            return description
        } else {
            let endIndex = description.index(description.startIndex, offsetBy: min(200, description.count))
            return String(description[..<endIndex]) + "..."
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Story Line")
                .font(DSTypography.h4SwiftUI(weight: .semibold))
                .foregroundColor(.white)

            VStack(alignment: .leading, spacing: 8) {
                Text(displayText)
                    .font(DSTypography.h5SwiftUI(weight: .regular))
                    .foregroundColor(DSColors.secondaryTextSwiftUI)
                    .lineLimit(isExpanded ? nil : 6)
                    .multilineTextAlignment(.leading)
                    .animation(.easeInOut(duration: 0.3), value: isExpanded)

                if shouldShowMore {
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            isExpanded.toggle()
                        }
                    }) {
                        Text(isExpanded ? "Less" : "More")
                            .font(DSTypography.h5SwiftUI(weight: .medium))
                            .foregroundColor(Color(hex: "#12CDD9"))
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 24)
    }
}

struct StoryLineSection_Previews: PreviewProvider {
    static var previews: some View {
        let mockMovie = Movie(
            id: "1",
            title: "Sample Movie",
            posterPath: nil,
            overview: "Originally a story from Archie Comics which started in 1941, Riverdale centres around a group of high school students who are shocked by the death of classmate, Jason Blossom. Together they unravel the secrets of Riverdale and who committed this crime. As they get deeper into the investigation, they discover that nothing is as it seems and everyone has something to hide in this seemingly perfect small town.",
            releaseDate: Date(),
            voteAverage: "8.5"
        )

        ZStack {
            DSColors.backgroundSwiftUI.ignoresSafeArea()

            StoryLineSection(movie: mockMovie)
        }
    }
}