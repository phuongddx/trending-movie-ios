# Project Overview & Product Development Requirements

## Project Summary
Trending Movies Today is an iOS app showcasing trending movies via The Movie Database (TMDB) API. Built with SwiftUI, Clean Architecture, and MVVM pattern. Dark-theme-first design system inspired by Cinemax with features including movie browsing, search, watchlist management, and in-app trailer playback.

## Product Development Requirements

### Functional Requirements
- **Movie Discovery**: Browse trending movies with hero carousel and category filters (Popular/Now Playing/Top Rated/Upcoming)
- **Movie Details**: Comprehensive movie information with cast/crew, reviews, similar movies, and where-to-watch information
- **Search**: Real-time movie search with offline caching and search history
- **Watchlist & Favorites**: Save movies to personal watchlist with persistent storage
- **In-App YouTube Playback**: Play movie trailers within the app
- **Categories**: Support for multiple movie categories with dedicated views

### Technical Requirements
- **Platform**: iOS 14.0+ using SwiftUI
- **Language**: Swift 5.10
- **Development Tool**: Xcode 15.4+
- **Architecture**: Clean Architecture + MVVM pattern
- **Testing**: Comprehensive unit test coverage
- **Dependency Injection**: Factory pattern with single container architecture

### Performance Requirements
- **Startup Time**: < 2 seconds cold launch
- **Scroll Performance**: 60 FPS for movie list carousels and grid views
- **Network Efficiency**: Offline caching for search results and movie data
- **Memory Usage**: < 200MB peak memory consumption

### User Experience Requirements
- **Design System**: Cinemax-inspired dark theme with consistent component library
- **Navigation**: Intuitive tab-based navigation with bottom bar
- **Accessibility**: Support for Dynamic Type, VoiceOver, and high contrast modes
- **Offline Support**: Functional watchlist and basic app features without network

### Security Requirements
- **API Keys**: Secure management of TMDB API credentials (current implementation: embedded in source - **TODO: move to environment variables**
- **Data Protection**: Secure storage of user watchlist and favorites using encrypted UserDefaults
- **Network Security**: Secure HTTP communication with certificate validation

### Non-Functional Requirements
- **Code Quality**: Maintainable code with clear separation of concerns
- **Testing**: Unit tests for all business logic and ViewModels
- **Documentation**: Comprehensive documentation for architecture and API
- **Maintainability**: Modular architecture supporting easy feature additions

## Success Metrics
- **User Engagement**: Average session duration > 3 minutes
- **Performance**: 95% test coverage, 0 crashes in production
- **Code Quality**: Consistent coding standards, < 200 lines per Swift file
- **Architecture**: Clean separation between Domain, Data, and Presentation layers
- **Design System**: Consistent UI/UX across all components with dark theme support

## Current State
- **Phase**: Active development
- **Target Platform**: iOS (iPhone/iPad)
- **API Integration**: TMDB API v3
- **Dependencies**: Factory (DI), Moya (network), YouTubePlayerKit (trailer playback)
- **Bundle Size**: Optimized for fast download and minimal memory footprint

## Known Technical Debt
- **API Key Management**: Hardcoded API key in source (recommend migration to `.xcconfig`/environment variables)
- **Repository Layer**: Missing proper repository abstractions (current implementation uses direct service calls)
- **SPM Packages**: Domain and Data packages exist but not integrated (architectural inconsistency)