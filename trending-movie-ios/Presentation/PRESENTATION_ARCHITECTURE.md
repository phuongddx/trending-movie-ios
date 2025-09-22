# Presentation Layer Architecture Documentation

## Current File Structure Analysis

### 📂 Directory Organization

```
Presentation/
├── DesignSystem/          # Reusable design components & system
├── SwiftUI/              # SwiftUI-specific implementation
├── Utils/                # Utility classes and extensions
```

---

## 🎨 DesignSystem Layer

### **Responsibilities**: Define the visual language and reusable UI patterns

#### Current Files:
- **DSActionButton.swift** - Primary, Secondary, Text, Destructive button styles
- **DSCarouselSkeleton.swift** - Loading skeleton for carousel components
- **DSFormComponents.swift** - Input fields, text areas, form controls
- **DSLoadingView.swift** - Loading states and spinners
- **DSTabView.swift** - Tab navigation component

#### Foundation Files:
- **DSColors.swift** - Color palette and theme colors
- **DSIcons.swift** - Icon set and custom icon components
- **DSSpacing.swift** - Spacing constants and layout values
- **DSTypography.swift** - Font weights, sizes, and text styles
- **DSThemeManager.swift** - Theme switching and management

### **Missing Components** (Recommended):
- **DSCard.swift** - Standardized card component with elevation
- **DSBadge.swift** - Notification badges, status indicators
- **DSProgress.swift** - Progress bars, indicators
- **DSAlert.swift** - Alert dialogs and notifications
- **DSBottomSheet.swift** - Modal bottom sheet component
- **DSTextField.swift** - Enhanced text input component
- **DSImageView.swift** - Standardized image loading component

---

## 📱 SwiftUI Implementation Layer

### **Components** - Reusable UI building blocks

#### Movie-Specific Components:
- **MovieCard.swift** - Movie display card for lists/grids
- **MovieDetailHero.swift** - Hero section for movie details (contains multiple sub-components)
- **MoviePosterImage.swift** - Poster image with loading states
- **MovieRowView.swift** - Horizontal movie list item
- **AgeRatingBadge.swift** - Certification rating display
- **RatingDistribution.swift** - Rating histogram and stars
- **VideosSection.swift** - Video thumbnails with playback
- **PhotosGallery.swift** - Image gallery with full-screen viewer

#### General Components:
- **HeroCarousel.swift** - Main carousel component with cast members
- **SearchBar.swift** - Search input component

#### **Missing Components** (Recommended):
- **MovieDetailsComponents/** - Break down MovieDetailHero into smaller components:
  - **MovieMetadata.swift** - Runtime, director, certification info
  - **MovieActions.swift** - Watchlist, favorite, share buttons
  - **MovieSynopsis.swift** - Overview text with expand/collapse
  - **CastCarousel.swift** - Extract from HeroCarousel.swift
- **FilterComponents.swift** - Genre, year, rating filters
- **SortingPicker.swift** - Sort options (popularity, rating, date)
- **ErrorView.swift** - Error states with retry functionality
- **EmptyStateView.swift** - Empty list states with illustrations

### **Views** - Full screen interfaces

#### Current Views:
- **ContentView.swift** - Root application view
- **HomeView.swift** - Main dashboard with trending movies
- **MovieDetailsView.swift** - Movie detail screen
- **MoviesListView.swift** - Movie list/grid display
- **SearchView.swift** - Search interface
- **WatchlistView.swift** - User's saved movies
- **RateMovieSheet.swift** - Rating modal interface

#### **Missing Views** (Recommended):
- **ProfileView.swift** - User profile and settings
- **SettingsView.swift** - App settings and preferences
- **GenreListView.swift** - Browse movies by genre
- **PersonDetailsView.swift** - Actor/Director details
- **ReviewsView.swift** - Movie reviews and ratings
- **TrailerPlayerView.swift** - Full-screen video player
- **OnboardingView.swift** - App introduction flow
- **AboutView.swift** - App information and credits

### **ViewModels** - Business logic and state management

#### Current ViewModels:
- **ObservableMovieDetailsViewModel.swift** - Movie details screen logic
- **ObservableMoviesListViewModel.swift** - Movie list state management
- **SearchViewModel.swift** - Search functionality
- **MoviesListItemViewModel.swift** - Individual movie item logic

#### **Missing ViewModels** (Recommended):
- **ProfileViewModel.swift** - User profile management
- **SettingsViewModel.swift** - App settings state
- **GenreViewModel.swift** - Genre filtering logic
- **PersonDetailsViewModel.swift** - Actor/Director details
- **ReviewsViewModel.swift** - Reviews and ratings
- **OnboardingViewModel.swift** - Introduction flow state
- **WatchlistViewModel.swift** - Watchlist management (if not in existing)

### **Navigation** - App navigation flow

#### Current Files:
- **TabNavigation.swift** - Bottom tab navigation
- **AppDestination.swift** - Route definitions

#### **Missing Navigation** (Recommended):
- **NavigationCoordinator.swift** - Centralized navigation coordinator
- **DeepLinkHandler.swift** - Handle deep links and URL schemes
- **NavigationModifiers.swift** - Custom navigation modifiers

---

## 🛠 Utils Layer

### **Responsibilities**: Helper utilities and extensions

#### Current Files:
- **AccessibilityIdentifier.swift** - Accessibility constants
- **Collection+Ext.swift** - Collection extensions

#### **Missing Utilities** (Recommended):
- **NetworkConstants.swift** - API endpoints and configurations
- **DateFormatters.swift** - Date formatting utilities
- **ImageCache.swift** - Image caching management
- **AnalyticsTracker.swift** - Analytics event tracking
- **KeychainHelper.swift** - Secure storage utilities
- **DeviceInfo.swift** - Device information utilities
- **AppVersionHelper.swift** - Version checking utilities
- **ValidationHelpers.swift** - Input validation utilities

#### **Extensions** (Recommended):
- **View+Extensions.swift** - SwiftUI View extensions
- **Color+Extensions.swift** - Color utilities and hex support
- **String+Extensions.swift** - String manipulation utilities
- **Date+Extensions.swift** - Date formatting and calculations
- **URL+Extensions.swift** - URL manipulation utilities

---

## 📋 Suggested Implementation Priority

### **High Priority** (Core missing functionality):
1. **MovieDetailsComponents/** - Break down large MovieDetailHero
2. **ErrorView.swift** - Better error handling UI
3. **EmptyStateView.swift** - Improved empty states
4. **NavigationCoordinator.swift** - Centralized navigation
5. **View+Extensions.swift** - Common SwiftUI utilities

### **Medium Priority** (Enhanced user experience):
1. **ProfileView.swift** + **ProfileViewModel.swift** - User profiles
2. **SettingsView.swift** + **SettingsViewModel.swift** - App settings
3. **DSCard.swift**, **DSAlert.swift** - Design system gaps
4. **PersonDetailsView.swift** - Actor/Director pages
5. **ImageCache.swift** - Performance optimization

### **Low Priority** (Nice to have):
1. **OnboardingView.swift** - First-time user experience
2. **TrailerPlayerView.swift** - Enhanced video playback
3. **ReviewsView.swift** - User reviews functionality
4. **AnalyticsTracker.swift** - Usage analytics
5. **DeepLinkHandler.swift** - URL scheme support

---

## 🏗 Architecture Principles

### **Single Responsibility**
- Each file should have one clear purpose
- Components should be focused and reusable
- ViewModels handle only business logic for their view

### **Separation of Concerns**
- DesignSystem: Visual design and reusable UI
- Components: Composed UI building blocks
- Views: Screen-level interfaces
- ViewModels: Business logic and state
- Utils: Helper functions and extensions

### **Dependency Direction**
- Views depend on ViewModels
- ViewModels depend on Domain/Use Cases
- Components depend on DesignSystem
- No circular dependencies

### **Testability**
- ViewModels should be easily unit testable
- Components should support preview testing
- UI logic separated from business logic

This architecture supports scalability, maintainability, and clear separation of responsibilities across the presentation layer.