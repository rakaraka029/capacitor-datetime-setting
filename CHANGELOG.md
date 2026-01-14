# Capacitor DateTime Setting Plugin

## Changelog

## [1.1.0] - 2026-01-14

### Added
- iOS auto date/time detection using NSTimeZone comparison technique
- Both `timeIsAuto()` and `timeZoneIsAuto()` now return actual values on iOS

### Changed
- Updated iOS implementation to use `NSTimeZone.autoupdatingCurrent` comparison
- Improved documentation with platform-specific implementation details

### Credits
- iOS detection technique inspired by [date_change_checker](https://github.com/error404sushant/date_change_checker) Flutter plugin

## [1.0.0] - 2026-01-14

### 1.0.0 (2026-01-14)

Initial release

**Features:**
- Check if automatic time is enabled (`timeIsAuto()`)
- Check if automatic timezone is enabled (`timeZoneIsAuto()`)
- Open device date/time settings (`openSetting()`)

**Platform Support:**
- Android: Full support for all methods
- iOS: Limited support (see README for details)
- Web: Not supported
