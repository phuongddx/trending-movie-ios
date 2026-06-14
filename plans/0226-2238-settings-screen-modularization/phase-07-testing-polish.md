# Phase 7: Testing & Polish

## Overview
Verify all components work together, add tests, and polish the implementation.

**Priority:** Medium | **Effort:** Low | **Status:** Pending

## Testing Checklist

### Unit Tests (SettingsViewModelTests.swift)

```swift
@testable import trending_movie_ios
import XCTest

final class SettingsViewModelTests: XCTestCase {

    var sut: SettingsViewModel!

    override func setUp() {
        sut = SettingsViewModel()
    }

    override func tearDown() {
        sut = nil
    }

    // MARK: - Video Settings Tests

    func testAutoplayTrailers_defaultValue_isTrue() {
        XCTAssertTrue(sut.videoSettings.autoplayTrailers)
    }

    func testStreamingQuality_defaultValue_isAuto() {
        XCTAssertEqual(sut.videoSettings.streamingQuality, .auto)
    }

    // MARK: - Notification Settings Tests

    func testPushNotifications_whenDisabled_disablesSubToggles() {
        sut.notificationSettings.pushEnabled = false
        XCTAssertFalse(sut.notificationSettings.newReleasesEnabled)
    }

    // MARK: - Storage Tests

    func testClearCache_resetsCacheSize() async {
        await sut.clearCache()
        XCTAssertEqual(sut.storageInfo.cacheBytes, 0)
    }

    func testRefreshStorageInfo_updatesCacheSize() async {
        await sut.refreshStorageInfo()
        XCTAssertGreaterThanOrEqual(sut.storageInfo.cacheBytes, 0)
    }
}
```

### UI Tests (SettingsUITests.swift)

```swift
@testable import trending_movie_ios
import XCTest

final class SettingsUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUp() {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    func testSettingsTab_displaysAllSections() {
        // Navigate to Settings tab
        app.tabBars.buttons["Profile"].tap()

        // Verify sections exist
        XCTAssertTrue(app.staticTexts["Video Playback"].exists)
        XCTAssertTrue(app.staticTexts["Notifications"].exists)
        XCTAssertTrue(app.staticTexts["Display & Accessibility"].exists)
    }

    func testToggleHapticFeedback_persistsValue() {
        app.tabBars.buttons["Profile"].tap()

        let hapticToggle = app.switches["haptic_feedback_toggle"]
        hapticToggle.tap()

        // Restart app and verify persistence
        app.terminate()
        app.launch()
        app.tabBars.buttons["Profile"].tap()

        XCTAssertEqual(hapticToggle.value as? Int, 0)
    }
}
```

## Polish Items

### Accessibility
- [ ] Add accessibility identifiers to all interactive elements
- [ ] Add accessibility labels for VoiceOver
- [ ] Test with VoiceOver enabled
- [ ] Verify Dynamic Type support

```swift
// Example accessibility additions
Toggle("", isOn: $isOn)
    .accessibilityIdentifier("push_notifications_toggle")
    .accessibilityLabel("Push Notifications")
    .accessibilityHint("Double tap to toggle")
```

### Animation Polish
- [ ] Add withAnimation to state changes
- [ ] Ensure .spring() for natural feel
- [ ] Respect prefers-reduced-motion

```swift
withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
    viewModel.showClearCacheConfirmation = true
}
```

### Error Handling
- [ ] Add error states for async operations
- [ ] Show error alerts for failed operations

```swift
enum SettingsError: Error {
    case cacheClearFailed
    case signOutFailed
}

// In ViewModel
@Published var error: SettingsError?
```

### Performance
- [ ] Profile with Instruments
- [ ] Check for unnecessary re-renders
- [ ] Verify no memory leaks

## Cleanup Tasks

### Remove Old Code
- [ ] Delete original SettingsView code after verification
- [ ] Remove LegacySettingsView if iOS 14 support not needed
- [ ] Clean up unused @AppStorage references

### Update Documentation
- [ ] Update README.md if structure changed
- [ ] Add inline documentation for new components

## Final Verification

### Build Verification
```bash
xcodebuild -project trending-movie-ios.xcodeproj \
  -scheme trending-movie-ios \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro Max' \
  build test
```

### Manual Test Checklist
- [ ] All sections display correctly
- [ ] Toggles persist values
- [ ] Navigation rows respond to taps
- [ ] Clear cache confirmation works
- [ ] Sign out confirmation works
- [ ] External links open correctly
- [ ] No layout warnings in console
- [ ] No memory leaks detected

## Success Criteria
- [ ] All unit tests pass
- [ ] UI tests pass
- [ ] Build succeeds with no warnings
- [ ] Manual testing complete
- [ ] Accessibility verified

## Completion
After all criteria met, the Settings screen modularization is complete.
