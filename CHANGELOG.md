# Changelog

All notable changes to this project will be documented in this file.

## [2.1.1] - 2026-01-18

### Fixed
- **iOS**: Fixed Swift compilation error caused by unterminated comment block in `DateTimeSettingPlugin.swift`
- Removed duplicate comment that was preventing iOS builds from succeeding

---

## [2.1.0] - 2026-01-18

### Added
- **iOS & Android**: `isDateTimeChangedSimple()` method - Simple NTP-based detection matching Flutter plugin behavior
  - iOS: Uses basic 30-second NTP threshold check without caching or complex fallback logic
  - Android: Uses Settings.Global.AUTO_TIME check (same as existing implementation)
  - Returns `true` if auto date/time is disabled or network fails (conservative approach)
  - Provides simpler, more predictable alternative to `isDateTimeChanged()`

### Technical Details
- Method signature: `isDateTimeChangedSimple(): Promise<{ changed: boolean }>`
- iOS: Direct NTP comparison with `worldtimeapi.org` using 30s threshold
- Android: Reuses existing Settings check for consistency
- No caching, network monitoring, or complex fallback - pure simple check
- Matches Flutter `date_change_checker` plugin behavior exactly

---

## [2.0.1] - 2026-01-15

### Added
- **iOS & Android**: `isDateTimeChanged()` method - Simple wrapper that returns inverse of `isAutoDateTimeEnabled`
  - Returns `true` if auto date/time is disabled, indicating possible manual changes
  - Matches date_change_checker source implementation
  - Available on both iOS and Android platforms

### Technical Details
- Method signature: `isDateTimeChanged(): Promise<{ changed: boolean }>`
- iOS: Calls `AutoDateTimeDetector.isAutoDateTimeEnabled` and returns `!isEnabled`
- Android: Checks `Settings.Global.AUTO_TIME` and returns inverse

---

## [2.0.0] - 2026-01-15

### BREAKING CHANGES
- **Removed methods**: `timeIsAuto()`, `timeZoneIsAuto()`, `openSetting()` - these methods were not part of the date_change_checker source plugin
- **Android**: Removed all plugin methods - use native Settings API directly (see README)
- **Platform Support**: Plugin is now iOS-only, matching the source plugin's architecture

### Added
- **iOS**: Cloned all 10 methods from [date_change_checker](https://github.com/error404sushant/date_change_checker) Flutter plugin
- **iOS**: `detectDateTimeChange()` - Simple boolean change detection
- **iOS**: `detectComprehensiveDateTimeChange()` - Detailed change analysis with type differentiation
- **iOS**: `detectDateOnlyChange()` - Date-specific change detection
- **iOS**: `detectAndNotifyDateTimeChanges()` - Detection with automatic native notifications
- **iOS**: `getLocalTime()` - Get device's current local time
- **iOS**: `getInternetUTCTime()` - Fetch accurate UTC time from WorldTimeAPI
- **iOS**: `convertToLocalTime()` - Convert local time to UTC
- **iOS**: `setStoredTimestamp()` - Store reference timestamp for future comparisons
- **iOS**: `getStoredTimestamp()` - Retrieve stored timestamp
- **iOS**: `resetDetector()` - Clear all stored data and cache
- **iOS**: `NotificationManager` class (259 lines) - Comprehensive notification system
  - Automatic permission handling
  - Different notification types (auto time disabled, date changed, time changed, both changed)
  - iOS 10+ modern notifications with legacy fallback

### Changed
- **iOS**: Upgraded `AutoDateTimeDetector` from 178 to 671 lines
  - Added comprehensive date/time change detection logic
  - Distinguishes between date-only, time-only, and combined changes
  - Network time validation with WorldTimeAPI integration
  - Smart offline fallback with timezone comparison
  - 30-second caching for performance optimization
  - Battery-optimized network monitoring
- **iOS**: Updated `DateTimeSettingPlugin` to expose all 10 new methods
- **TypeScript**: Complete interface redesign with `DateTimeChangeResult` type
- **Documentation**: Completely rewritten README with iOS-only focus

### Removed
- **Android**: All plugin methods removed (not present in source plugin)
- **iOS/TypeScript/Web**: `timeIsAuto()`, `timeZoneIsAuto()`, `openSetting()` methods
  - These methods were from the original datetime-setting plugin
  - Not present in date_change_checker source
  - Removed to maintain source fidelity

### Technical Details
- **iOS Detection Methods**: 
  - Cache-first approach (30s TTL)
  - Network validation via `https://worldtimeapi.org/api/timezone/Etc/UTC`
  - Offline fallback using timezone comparison
  - Time difference thresholds: 5s (time-only), 60s (auto-time detection), 300s (date changes)
- **iOS Notifications**:
  - Permission-based notification system
  - Different alerts for different change types
  - Non-intrusive user experience
- **Platform Strategy**:
  - iOS: Full implementation (complex network validation needed)
  - Android: Use native Settings API (simple one-liner check)
  - Web: Not supported (native device feature)

### Credits
This version is a complete Capacitor port of the Flutter [date_change_checker](https://github.com/error404sushant/date_change_checker) plugin by [error404sushant](https://github.com/error404sushant). All iOS implementation logic is directly cloned from the original source.

---

## [1.2.0] - 2026-01-14

### Changed
- **iOS**: Significantly improved auto date/time detection using network time comparison
  - Changed from simple `TimeZone.autoupdatingCurrent` check to network-based time server comparison
  - Added caching mechanism (30 seconds) to minimize network calls and improve performance
  - Better offline fallback behavior using timezone check
  - More reliable detection of manual time changes

### Added
- **iOS**: Network-based time server comparison for reliable auto date/time detection
- **iOS**: Result caching for 30 seconds to optimize performance
- **iOS**: Network monitoring for battery optimization
- **iOS**: `AutoDateTimeDetector` class for comprehensive time detection

### Technical Details
- Uses `https://worldtimeapi.org/api/timezone/Etc/UTC` for accurate time reference
- Considers auto time disabled if device time differs from server time by more than 60 seconds
- Falls back to offline detection when network is unavailable
- Async detection to avoid blocking the main thread

## [1.1.2] - 2026-01-14

### Fixed
- **iOS**: Fixed `Type 'NSTimeZone' has no member 'autoupdatingCurrent'` error
  - Changed from `NSTimeZone.autoupdatingCurrent` to `TimeZone.autoupdatingCurrent` (Swift native type)
  - Changed from `NSTimeZone.system` to `TimeZone.current`
  - Added `checkAutoDateTime()` helper method for cleaner code
  - Now properly detects auto date/time settings on iOS devices

## [1.1.1] - 2026-01-14

### Fixed
- **iOS**: Renamed podspec file to match scoped npm package naming convention
  - Changed from `CapacitorDatetimeSetting.podspec` to `GreatdayhrCapacitorDatetimeSetting.podspec`
  - Fixed CocoaPods installation error: "No podspec found for `GreatdayhrCapacitorDatetimeSetting`"

## [1.1.0] - 2026-01-14

### Changed
- Upgraded to Capacitor 7
- Updated all dependencies to latest versions
- Updated peer dependencies to `@capacitor/core@^7.0.0`

### Added
- iOS implementation for checking auto time/timezone settings
- Added proper documentation for iOS limitations

## [1.0.1] - 2026-01-13

### Added
- Initial release
- Android support for checking auto time/timezone settings
- iOS support with basic implementation
- Method to open device settings
