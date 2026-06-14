# Deployment Guide

## Overview
This guide provides comprehensive instructions for building, testing, and deploying the Trending Movies iOS application. The project uses modern iOS development practices with SwiftUI, Clean Architecture, and comprehensive testing.

## Prerequisites

### System Requirements
- **macOS**: Latest version (macOS Sonoma or later recommended)
- **Xcode**: 15.4 or later
- **iOS**: 14.0+ (deployment target)
- **Swift**: 5.10+
- **Package Managers**: Homebrew, Ruby (for Fastlane)

### Required Tools
```bash
# Install Xcode Command Line Tools
xcode-select --install

# Install Ruby and Fastlane
brew install ruby
gem install fastlane

# Install Swift Package Manager dependencies
swift package update
```

## Project Structure

### Workspace Organization
```
TrendingMovies.xcworkspace
├── trending-movie-ios/ (main app target)
│   ├── Domain/ (business logic)
│   ├── Data/ (network and storage)
│   ├── Presentation/ (SwiftUI views and components)
│   ├── DI/ (dependency injection)
│   ├── App/ (app lifecycle)
│   └── Common/ (shared utilities)
├── MoviesDomain/ (dormant SPM package)
├── MoviesData/ (dormant SPM package)
└── trending-movie-iosTests/ (test suite)
```

### Build Configuration
- **Workspace**: `TrendingMovies.xcworkspace`
- **Scheme**: `trending-movie-ios`
- **Platform**: iOS
- **Deployment Target**: iOS 14.0+
- **Supported Devices**: iPhone and iPad

## Building the Application

### Method 1: XcodeBuildMCP (Recommended)
```bash
# Set session defaults
mcp__XcodeBuildMCP__session_set_defaults \
  --project-path "/Users/ddphuong/Projects/next-labs/trending-movie-ios" \
  --scheme "trending-movie-ios" \
  --simulator-name "iPhone 17 Pro Max"

# Build for simulator
mcp__XcodeBuildMCP__build_sim

# Build and run
mcp__XcodeBuildMCP__build_run_sim
```

### Method 2: Xcode Command Line
```bash
# Clean build
xcodebuild clean -workspace TrendingMovies.xcworkspace -scheme trending-movie-ios

# Build for iOS Simulator
xcodebuild build -workspace TrendingMovies.xcworkspace \
  -scheme trending-movie-ios \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro Max' \
  -configuration Debug

# Archive for App Store (distribution)
xcodebuild archive -workspace TrendingMovies.xcworkspace \
  -scheme trending-movie-ios \
  -destination generic/platform=iOS \
  -configuration Release \
  -archivePath ./build/TrendingMovies.xcarchive
```

### Method 3: Fastlane (CI/CD)
```bash
# Fastlane setup
bundle install

# Build lane
bundle exec fastlane build

# Build and test
bundle exec fastlane build_test
```

## Testing

### Test Strategy
The project follows comprehensive testing practices with multiple test categories:

### Fastlane Testing (Recommended)
```bash
# Run all tests
bundle exec fastlane tests

# Run specific test class
bundle exec fastlane tests --tests "trending-movie-iosTests/Presentation/MovieDetailsViewModelTests"

# Run tests with coverage
bundle exec fastlane tests --coverage
```

### XcodeBuild Testing
```bash
# Run all unit tests
xcodebuild test -workspace TrendingMovies.xcworkspace \
  -scheme trending-movie-ios \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro Max' \
  -only-testing:trending-movie-iosTests

# Run specific test
xcodebuild test -workspace TrendingMovies.xcworkspace \
  -scheme trending-movie-ios \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro Max' \
  -only-testing:trending-movie-iosTests/Presentation/MovieDetailsViewModelTests/testMovieDetailsViewModel_initialState

# Run tests with coverage report
xcodebuild test -workspace TrendingMovies.xcworkspace \
  -scheme trending-movie-ios \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro Max' \
  -enableCodeCoverage YES
```

### Test Categories
| Category | Location | Purpose | Coverage Goal |
|----------|----------|---------|---------------|
| **Unit Tests** | `trending-movie-iosTests/` | Business logic and ViewModels | 95%+ |
| **Integration Tests** | `trending-movie-iosTests/Presentation/` | UI component integration | 80%+ |
| **Network Tests** | `trending-movie-iosTests/Infrastructure/` | API integration | 90%+ |
| **Domain Tests** | `trending-movie-iosTests/Domain/` | Core business logic | 95%+ |
| **Mock Tests** | `trending-movie-iosTests/Mocks/` | Mock implementation validation | 100% |

### Test Coverage Analysis
```bash
# Generate coverage report
xcrun xccov view --report --json DerivedData/Logs/Test/*.xcresult > coverage.json

# Generate HTML coverage report
xcrun xccov view --report --html DerivedData/Logs/Test/*.xcresult > coverage.html

# Open coverage report
open coverage.html
```

## CI/CD Pipeline

### GitHub Actions Configuration
The project includes GitHub Actions for automated CI/CD:

**File**: `.github/workflows/objective-c-xcode.yml`

**Pipeline Triggers**:
- **On Pull Request**: Automated testing and build validation
- **On Push to Master**: Full test suite and build verification
- **On Tag**: Release preparation and App Store submission

### Pipeline Steps
```yaml
name: iOS CI Pipeline

on:
  pull_request:
    branches: [ master ]
  push:
    branches: [ master ]

jobs:
  test:
    runs-on: macos-latest
    steps:
    - uses: actions/checkout@v3
    - name: Setup Xcode
      uses: maxim-lobanov/setup-xcode@v1
      with:
        xcode-version: '15.4'
    - name: Install Ruby dependencies
      run: |
        gem install bundler
        bundle install
    - name: Run tests
      run: bundle exec fastlane tests
```

### Local Development Setup
```bash
# Clone repository
git clone <repository-url>
cd trending-movie-ios

# Install dependencies
bundle install
swift package update

# Open workspace
open TrendingMovies.xcworkspace
```

## App Store Submission

### Preparation Steps
1. **Code Signing**: Configure app signing certificates and profiles
2. **App Store Connect**: Create app record and configure metadata
3. **Privacy Manifest**: Generate and configure privacy manifest
4. **Screenshots**: Prepare App Store screenshots for different device sizes
5. **App Icon**: Generate app icons for all required sizes
6. **Description**: Prepare app description and release notes

### Fastlane Deployment
```ruby
# Fastfile configuration
lane :release do
  # Build and test
  build_app(scheme: "trending-movie-ios")
  run_tests(scheme: "trending-movie-ios")
  
  # Generate screenshots
  snapshot
  
  # Upload to App Store
  upload_to_app_store(
    skip_metadata: true,
    skip_screenshots: true,
    skip_upload: false
  )
end
```

### Manual App Store Submission
1. **Archive the App**:
   ```bash
   xcodebuild archive -workspace TrendingMovies.xcworkspace \
     -scheme trending-movie-ios \
     -destination generic/platform=iOS \
     -configuration Release \
     -archivePath ./build/TrendingMovies.xcarchive
   ```

2. **Export IPA**:
   ```bash
   xcodebuild -exportArchive -archivePath ./build/TrendingMovies.xcarchive \
     -exportPath ./build/Export \
     -exportOptionsPlist ExportOptions.plist \
     -exportArchive
   ```

3. **Upload to App Store Connect**:
   - Use Xcode or Transporter app
   - Follow App Store Connect guidelines

## Environment Configuration

### Development Environment
```swift
// AppConfigurations.swift
struct AppConfiguration {
    let apiKey: String = "DEVELOPMENT_API_KEY" // TODO: Move to environment
    let baseUrl: String = "https://api.themoviedb.org/3/"
    let imagesUrl: String = "https://image.tmdb.org/t/p/"
}
```

### Production Environment
**TODO**: Create proper environment configuration
- Move API key to environment variables
- Create `.xcconfig` files for different environments
- Use build configurations for different targets

### Secrets Management
**Current Issue**: API key hardcoded in source
**Recommendation**: Use environment variables or `.xcconfig` files

```bash
# Create .xcconfig file
echo 'TMDB_API_KEY = "YOUR_API_KEY"' > Config.xcconfig

# Add to Xcode project settings
# In Build Settings -> Other Swift Flags:
# -D DEBUG
# In Build Settings -> Config File:
# $(SRCROOT)/Config.xcconfig
```

## Performance Optimization

### Build Optimization
```bash
# Clean derived data
rm -rf ~/Library/Developer/Xcode/DerivedData

# Incremental builds
xcodebuild -workspace TrendingMovies.xcworkspace \
  -scheme trending-movie-ios \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro Max' \
  -configuration Debug

# Build only changed targets
xcodebuild -workspace TrendingMovies.xcworkspace \
  -scheme trending-movie-ios \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro Max' \
  -configuration Debug \
  -quiet
```

### Memory Optimization
```swift
// Use weak references in ViewModels
class MoviesListViewModel: ObservableObject {
    weak var networkService: TMDBNetworkServiceProtocol?
    // ...
}

// Implement proper cleanup
deinit {
    cancellableBag.cancelAll()
}
```

## Troubleshooting

### Common Build Issues

1. **SPM Package Integration**:
   ```bash
   # Clean package caches
   rm -rf ~/Library/Developer/Xcode/DerivedData/SourcePackages
   swift package reset
   ```

2. **Code Signing Issues**:
   ```bash
   # Reset simulator content and settings
   xcrun simulator erase all
   xcrun simulator boot "iPhone 17 Pro Max"
   ```

3. **Test Failures**:
   ```bash
   # Run tests with verbose output
   xcodebuild test -workspace TrendingMovies.xcworkspace \
     -scheme trending-movie-ios \
     -destination 'platform=iOS Simulator,name=iPhone 17 Pro Max' \
     -only-testing:trending-movie-iosTests \
     -verbose
   ```

### Debugging Techniques

1. **LLDB Debugging**:
   ```bash
   # Attach debugger to running process
   lldb -p <process-id>
   
   # Common LLDB commands
   po moviesListViewModel
   bt
   continue
   ```

2. **Network Debugging**:
   ```swift
   // Enable network logging
   let networkService = TMDBNetworkService()
   networkService.enableDebugLogging = true
   ```

3. **Performance Analysis**:
   ```bash
   # Use Instruments
   open /Applications/Xcode.app/Contents/Applications/Instruments.app
   ```

## Monitoring and Analytics

### Application Performance Monitoring
**TODO**: Implement APM solution
- Firebase Crashlytics for crash reporting
- Analytics for user behavior tracking
- Performance monitoring

### Network Monitoring
```swift
// Add network logging
class NetworkMonitor {
    static let shared = NetworkMonitor()
    
    func logRequest(endpoint: String, duration: TimeInterval) {
        print("Network Request: \(endpoint) - \(duration)ms")
    }
}
```

## Security Considerations

### API Key Security
**Critical**: Current implementation has hardcoded API key
**Immediate Actions Required**:
1. Move API key to environment variables
2. Use `.xcconfig` files for build configurations
3. Implement proper secret management

### Data Protection
```swift
// Ensure UserDefaults data protection
let defaults = UserDefaults.standard
defaults.setObject(data, forKey: "secure_data")
```

### Network Security
```swift
// Enable App Transport Security
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <false/>
    <key>NSExceptionDomains</key>
    <dict>
        <key>api.themoviedb.org</key>
        <dict>
            <key>NSIncludesSubdomains</key>
            <true/>
            <key>NSExceptionAllowsInsecureHTTPLoads</key>
            <false/>
            <key>NSExceptionMinimumTLSVersion</key>
            <string>TLSv1.2</string>
        </dict>
    </dict>
</dict>
```

## Version Management

### Semantic Versioning
- **Major (X.0.0)**: Breaking changes
- **Minor (X.X.0)**: New features
- **Patch (X.X.X)**: Bug fixes

### Version Configuration
```swift
// Info.plist configuration
<key>CFBundleShortVersionString</key>
<string>$(MARKETING_VERSION)</string>
<key>CFBundleVersion</key>
<string>$(CURRENT_PROJECT_VERSION)</string>
```

## Deployment Checklists

### Pre-Release Checklist
- [ ] All tests passing (95%+ coverage)
- [ ] Performance benchmarks met
- [ ] App Store metadata complete
- [ ] Privacy manifest generated
- [ ] App icons and screenshots prepared
- [ ] Code signing configured
- [ ] Security issues resolved (API key)
- [ ] Documentation updated

### Pre-Submission Checklist
- [ ] App Store Connect metadata completed
- [ ] Screenshots uploaded for all device sizes
- [ ] App preview video uploaded
- [ ] Privacy policy link provided
- [ ] Support contact information updated
- [ ] Release notes prepared
- [ ] App Store review guidelines compliance verified

### Post-Release Checklist
- [ ] Monitor app performance metrics
- [ ] Track crash reports and user feedback
- [ ] Update documentation with release notes
- [ ] Plan next iteration features
- [ ] Review user reviews and feedback
- [ ] Monitor analytics and engagement metrics