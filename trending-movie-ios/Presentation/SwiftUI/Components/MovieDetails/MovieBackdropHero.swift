import SwiftUI

struct MovieBackdropHero: View {
    let movie: Movie
    let height: CGFloat

    init(movie: Movie, height: CGFloat = 552) {
        self.movie = movie
        self.height = height
    }

    var body: some View {
        ZStack {
            // Backdrop Image
            Group {
                if let posterPath = movie.posterPath, !posterPath.isEmpty {
                    AsyncImage(url: URL(string: "https://image.tmdb.org/t/p/w780\(posterPath)")) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Rectangle()
                            .fill(DSColors.surfaceSwiftUI)
                    }
                } else {
                    Rectangle()
                        .fill(DSColors.surfaceSwiftUI)
                }
            }
            .frame(width: UIScreen.main.bounds.width, height: height)
            .clipped()

            // Gradient Overlay
            LinearGradient(
                gradient: Gradient(stops: [
                    .init(color: Color(hex: "#1F1D2B").opacity(0.57), location: 0),
                    .init(color: Color(hex: "#1F1D2B"), location: 1.0)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(width: UIScreen.main.bounds.width, height: height)

            // Movie Poster (smaller, positioned like in Figma)
            VStack {
                Spacer()

                HStack {
                    Spacer()

                    if let posterPath = movie.posterPath, !posterPath.isEmpty {
                        AsyncImage(url: URL(string: "https://image.tmdb.org/t/p/w342\(posterPath)")) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            Rectangle()
                                .fill(DSColors.surfaceSwiftUI)
                        }
                    } else {
                        Rectangle()
                            .fill(DSColors.surfaceSwiftUI)
                    }

                    Spacer()
                }
                .frame(width: 205, height: 287)
                .cornerRadius(12)
                .padding(.bottom, 60)
            }
        }
        .frame(width: UIScreen.main.bounds.width, height: height)
    }
}

struct MovieBackdropHero_Previews: PreviewProvider {
    static var previews: some View {
        let mockMovie = Movie(
            id: "1",
            title: "Sample Movie",
            posterPath: "/sample-poster.jpg",
            overview: "Sample overview",
            releaseDate: Date(),
            voteAverage: "8.5"
        )

        MovieBackdropHero(movie: mockMovie)
            .ignoresSafeArea()
    }
}
