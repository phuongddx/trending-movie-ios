# YouTubePlayerKit Integration Guide

## Overview
This guide details the implementation of YouTube trailer playback functionality using the YouTubePlayerKit library.

## Package Installation

### Step 1: Add YouTubePlayerKit Package
1. Open the project in Xcode
2. Go to **File → Add Package Dependencies**
3. Enter the repository URL: `https://github.com/SvenTiigi/YouTubePlayerKit.git`
4. Select **Up to Next Major Version** and click **Add Package**
5. Add the package to the `trending-movie-ios` target

### Step 2: Import in Required Files
Add the import statement to the following file:
```swift
// In YouTubePlayerView.swift
import YouTubePlayerKit
```

## Implementation Details

### 1. Movie Model Extensions
Added computed properties to `Movie.swift`:
- `youTubeTrailerID: String?` - Extracts YouTube video ID from TMDB video data
- `hasTrailer: Bool` - Indicates if a YouTube trailer is available

### 2. YouTubePlayerView Component
Created `YouTubePlayerView.swift` with:
- Full-screen YouTube player with custom navigation
- Loading states and error handling
- Automatic retry functionality
- Dark mode support

### 3. ViewModel Updates
Enhanced `ObservableMovieDetailsViewModel.swift`:
- Added `@Published` properties for trailer state management
- Updated `playTrailer()` method to handle YouTube video presentation
- Error handling for missing trailers

### 4. UI Integration
Updated `MovieDetailsView.swift`:
- Added sheet presentation for YouTube player
- Integrated with existing alert system

### 5. Action Button Updates
Enhanced `MovieActionButtons.swift`:
- Added `hasTrailer` parameter
- Visual feedback for trailer availability
- Disabled state when no trailer available

## Features

### ✅ Implemented
- [x] YouTube trailer playback with YouTubePlayerKit
- [x] Automatic trailer detection from TMDB video data
- [x] Loading states and error handling
- [x] Visual feedback for trailer availability
- [x] Full-screen player experience
- [x] Dark mode support
- [x] Retry functionality on errors

### 🎯 Trailer Selection Logic
1. Filters videos for `site: "YouTube"` and `type: "Trailer"`
2. Prioritizes trailers with "Official" in the name
3. Falls back to first available YouTube trailer
4. Shows "No Trailer" state if none available

### 🎨 UI/UX Features
- **Loading State**: Shows progress indicator while player loads
- **Error State**: Displays retry option for failed loads
- **Disabled State**: Grayed out button when no trailer available
- **Custom Navigation**: "Done" button to dismiss player
- **Full-Screen**: Immersive player experience

## Usage

### For Movies with Trailers:
1. User taps "Trailer" button
2. YouTube player opens in full-screen sheet
3. Trailer plays automatically
4. User can dismiss with "Done" button

### For Movies without Trailers:
1. Button shows "No Trailer" with disabled state
2. Tapping shows alert: "No trailer available for this movie"

## Error Handling

### Network Errors:
- Shows error view with retry button
- User-friendly error messages
- Graceful fallback to alert

### Missing Trailer Data:
- Button becomes disabled
- Shows "No Trailer" text
- Alert explains no trailer available

## Testing

### Test Cases:
1. **Movie with trailer**: Verify player opens and plays
2. **Movie without trailer**: Verify disabled state and alert
3. **Network error**: Verify error view and retry functionality
4. **Player loading**: Verify loading indicator appears

### Sample Test Data:
```swift
// Movie with trailer (most blockbuster movies)
let movieWithTrailer = Movie(id: "550", title: "Fight Club", ...)

// Movie without trailer (older or indie films)
let movieWithoutTrailer = Movie(id: "...", videos: [])
```

## Dependencies

### Required:
- `YouTubePlayerKit` (https://github.com/SvenTiigi/YouTubePlayerKit.git)
- iOS 14.0+ (existing project requirement)
- SwiftUI (existing)

### Package Versions:
- YouTubePlayerKit: Latest stable version
- Compatible with existing Moya, Factory, SDWebImage dependencies

## File Structure

```
Presentation/SwiftUI/Components/MovieDetails/
├── YouTubePlayerView.swift          # New - YouTube player component
├── MovieActionButtons.swift         # Modified - Added trailer availability
└── ...

Domain/
├── Movie.swift                      # Modified - Added trailer extensions
└── ...

ViewModels/
├── ObservableMovieDetailsViewModel.swift  # Modified - Added trailer state
└── ...

Views/
├── MovieDetailsView.swift           # Modified - Added player sheet
└── ...
```

## Notes

- YouTubePlayerKit handles all YouTube API integration
- No YouTube API key required for basic playback
- Respects YouTube's terms of service
- Works with existing TMDB video data structure
- Maintains app's design system consistency