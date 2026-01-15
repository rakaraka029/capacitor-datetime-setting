# Changelog

All notable changes to this project will be documented in this file.

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
