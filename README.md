
# Trending Movies Today

This is an iOS application designed to showcase today's trending movies using the MovieDB API. It employs a Clean Layered Architecture and MVVM pattern to ensure a scalable and maintainable codebase.

![](https://github.com/phuongddx/trending-movie-ios/blob/master/Demo.gif)

## Features
- **Trending Movies List:** Explore the latest trending movies.
- **Detailed Movie Information:** Access comprehensive details about each movie, including synopsis, release date, and ratings.
- **Search Functionality:** Search for movies with support for offline mode using cached data.

## Requirements

- iOS 14.0+
- Xcode 15.0+
- Swift 5.5

## Installation

1. Clone the repository.
2. Open the `trending-movie-ios.xcodeproj` file in Xcode.
3. Run the application on your iOS device or simulator.

## Architecture
### Domain Layer
- **Entities:** Core data structures representing the movie-related data.
- **Use Cases:** Business logic and interaction rules.
- **Repository Interfaces:** Abstract definitions for data handling.

### Data Layer
- **Repositories Implementations:** Concrete implementations of repository interfaces.
- **API (Network):** Handles network requests to the MovieDB API.
- **Persistence DB:** Manages local data storage and caching.

### Presentation Layer (MVVM)
- **ViewModels:** Handles the presentation logic and prepares data for the views.
- **Views**: UI components and layouts.
  
## How to Use the App
1.Searching for a Movie:
- Enter the name of a movie in the search bar.
- Press the search button to initiate the search.

2.Network Operations:
- The app performs two network requests:
- Fetching movie details.
- Fetching poster images.

3.Data Storage: Every successful search query is saved persistently.


## Contributing

Feel free for submitting pull requests to me! 
