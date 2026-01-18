# Capacitor DateTime Setting Plugin

[![npm version](https://img.shields.io/npm/v/@greatdayhr/capacitor-datetime-setting.svg)](https://www.npmjs.com/package/@greatdayhr/capacitor-datetime-setting)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)

Capacitor plugin for comprehensive date/time management on iOS. Cloned from [date_change_checker](https://github.com/error404sushant/date_change_checker) Flutter plugin.

**Features:**
- Detect manual date/time changes with network validation
- Comprehensive change analysis (date-only, time-only, or both)
- Automatic user notifications for detected changes
- Fetch accurate internet time from time servers
- Timestamp management for change tracking
- Network-optimized with caching and offline fallback

**Platform Support:**
- ✅ **iOS**: Full implementation (12 methods)
- ✅ **Android**: 2 methods (`isDateTimeChanged`, `isDateTimeChangedSimple`)
- ❌ **Web**: Not supported

## Installation

```bash
npm install @greatdayhr/capacitor-datetime-setting
npx cap sync ios
```

## API

### Simple Change Detection

#### `isDateTimeChanged()`

Check if date/time has been manually changed. Returns `true` if auto date/time is disabled (inverse of auto time enabled).

This is a simple wrapper from date_change_checker source that provides a quick boolean check.

**Returns:** `Promise<{ changed: boolean }>`

**Platform Support:** 
- ✅ iOS
- ✅ Android

**Example:**

```typescript
import { DateTimeSetting } from '@greatdayhr/capacitor-datetime-setting';

const result = await DateTimeSetting.isDateTimeChanged();
if (result.changed) {
  console.log('Auto date/time is disabled - might be manually changed');
}
```

---

#### `isDateTimeChangedSimple()`

Simple NTP-based check if date/time has been manually changed. Uses basic 30-second threshold comparison without caching.

This method matches Flutter plugin behavior exactly and provides a simpler, more predictable alternative to `isDateTimeChanged()`.

**Platform behavior:**
- **iOS**: Compares device time with NTP server (30s threshold)
- **Android**: Checks Settings.Global.AUTO_TIME
- Returns `true` if auto time is disabled or network fails (conservative)

**Returns:** `Promise<{ changed: boolean }>`

**Platform Support:** 
- ✅ iOS
- ✅ Android

**Example:**

```typescript
import { DateTimeSetting } from '@greatdayhr/capacitor-datetime-setting';

const result = await DateTimeSetting.isDateTimeChangedSimple();
if (result.changed) {
  console.log('Auto date/time is disabled');
  // This result matches Flutter plugin behavior exactly
}
```

**When to use:**
- ✅ When you need consistent behavior with Flutter `date_change_checker`
- ✅ When you prefer simple, predictable NTP check without caching
- ✅ When you want conservative detection (fails closed on network errors)

**When to use `isDateTimeChanged()` instead:**
- ✅ When you need faster responses (uses 30s cache)
- ✅ When you need offline fallback with timezone checks
- ✅ When you want battery-optimized network monitoring

---

### Date/Time Change Detection

#### `detectDateTimeChange()`

Detects if the device's date/time has been manually changed. Uses network time comparison for accuracy when available, falls back to local time comparison offline.

**Returns:** `Promise<{ changed: boolean }>`

**Platform Support:** iOS only

**Example:**

```typescript
import { DateTimeSetting } from '@greatdayhr/capacitor-datetime-setting';

const result = await DateTimeSetting.detectDateTimeChange();
if (result.changed) {
  console.log('Date/time has been manually changed!');
}
```

---

#### `detectComprehensiveDateTimeChange()`

Comprehensive date and time change detection with detailed analysis. Distinguishes between date-only, time-only, and combined changes.

**Returns:** `Promise<DateTimeChangeResult>`

```typescript
interface DateTimeChangeResult {
  changeType: 'noChange' | 'timeOnly' | 'dateOnly' | 'dateAndTime';
  timeDifference: number;
  dateChanged: boolean;
  timeChanged: boolean;
  isAutoDateTimeEnabled: boolean;
  previousDate?: number;
  currentDate: number;
}
```

**Platform Support:** iOS only

**Example:**

```typescript
import { DateTimeSetting } from '@greatdayhr/capacitor-datetime-setting';

const result = await DateTimeSetting.detectComprehensiveDateTimeChange();
console.log('Change type:', result.changeType);
console.log('Date changed:', result.dateChanged);
console.log('Time changed:', result.timeChanged);
console.log('Time difference:', result.timeDifference, 'seconds');
console.log('Auto time enabled:', result.isAutoDateTimeEnabled);
```

---

#### `detectDateOnlyChange()`

Detects specifically if only the date has been changed while time remains similar. Useful for detecting manual date changes when auto date/time is disabled.

**Returns:** `Promise<{ changed: boolean }>`

**Platform Support:** iOS only

**Example:**

```typescript
import { DateTimeSetting } from '@greatdayhr/capacitor-datetime-setting';

const result = await DateTimeSetting.detectDateOnlyChange();
if (result.changed) {
  console.log('Only the date was changed!');
}
```

---

#### `detectAndNotifyDateTimeChanges()`

Comprehensive date and time change detection with automatic user notifications. Shows native iOS notifications when changes are detected.

**Returns:** `Promise<DateTimeChangeResult>`

**Platform Support:** iOS only

**Example:**

```typescript
import { DateTimeSetting } from '@greatdayhr/capacitor-datetime-setting';

const result = await DateTimeSetting.detectAndNotifyDateTimeChanges();
// User automatically sees notification if changes detected
console.log('Change type:', result.changeType);
```

---

### Time Utilities

#### `getLocalTime()`

Get the device's current local time as Unix timestamp.

**Returns:** `Promise<{ timestamp: number }>`

**Platform Support:** iOS only

**Example:**

```typescript
import { DateTimeSetting } from '@greatdayhr/capacitor-datetime-setting';

const result = await DateTimeSetting.getLocalTime();
const date = new Date(result.timestamp * 1000);
console.log('Current local time:', date);
```

---

#### `getInternetUTCTime()`

Fetch accurate UTC time from internet time server (WorldTimeAPI).

**Returns:** `Promise<{ timestamp: number }>`

**Platform Support:** iOS only

**Example:**

```typescript
import { DateTimeSetting } from '@greatdayhr/capacitor-datetime-setting';

try {
  const result = await DateTimeSetting.getInternetUTCTime();
  const date = new Date(result.timestamp * 1000);
  console.log('Internet UTC time:', date);
} catch (error) {
  console.error('Failed to fetch internet time:', error);
}
```

---

#### `convertToLocalTime(options)`

Convert local time to UTC.

**Parameters:**
- `options.timestamp` (number): Unix timestamp to convert

**Returns:** `Promise<{ timestamp: number }>`

**Platform Support:** iOS only

**Example:**

```typescript
import { DateTimeSetting } from '@greatdayhr/capacitor-datetime-setting';

const localTimestamp = Date.now() / 1000;
const result = await DateTimeSetting.convertToLocalTime({ 
  timestamp: localTimestamp 
});
console.log('UTC timestamp:', result.timestamp);
```

---

### Timestamp Management

#### `setStoredTimestamp(options)`

Set the stored timestamp for future change detection comparisons.

**Parameters:**
- `options.timestamp` (number): Unix timestamp to store

**Returns:** `Promise<void>`

**Platform Support:** iOS only

**Example:**

```typescript
import { DateTimeSetting } from '@greatdayhr/capacitor-datetime-setting';

const currentTimestamp = Date.now() / 1000;
await DateTimeSetting.setStoredTimestamp({ 
  timestamp: currentTimestamp 
});
```

---

#### `getStoredTimestamp()`

Get the currently stored timestamp used for change detection.

**Returns:** `Promise<{ timestamp: number | null }>`

**Platform Support:** iOS only

**Example:**

```typescript
import { DateTimeSetting } from '@greatdayhr/capacitor-datetime-setting';

const result = await DateTimeSetting.getStoredTimestamp();
if (result.timestamp) {
  const date = new Date(result.timestamp * 1000);
  console.log('Stored timestamp:', date);
} else {
  console.log('No timestamp stored');
}
```

---

#### `resetDetector()`

Reset the detector, clearing all stored data and cache.

**Returns:** `Promise<void>`

**Platform Support:** iOS only

**Example:**

```typescript
import { DateTimeSetting } from '@greatdayhr/capacitor-datetime-setting';

await DateTimeSetting.resetDetector();
console.log('Detector has been reset');
```

---

## Usage Example

Here's a complete example showing how to detect and respond to date/time changes:

```typescript
import { DateTimeSetting } from '@greatdayhr/capacitor-datetime-setting';
import { Capacitor } from '@capacitor/core';

async function monitorDateTimeChanges() {
  // Only works on iOS
  if (Capacitor.getPlatform() !== 'ios') {
    console.log('Date/time detection only available on iOS');
    return;
  }

  try {
    // Initialize with current timestamp
    const now = Date.now() / 1000;
    await DateTimeSetting.setStoredTimestamp({ timestamp: now });
    
    // Detect changes with notifications
    const result = await DateTimeSetting.detectAndNotifyDateTimeChanges();
    
    if (result.changeType !== 'noChange') {
      console.log('Change detected!');
      console.log('Type:', result.changeType);
      console.log('Auto time enabled:', result.isAutoDateTimeEnabled);
      
      // Handle the change
      if (!result.isAutoDateTimeEnabled) {
        alert('Please enable automatic date & time in Settings');
      }
    }
  } catch (error) {
    console.error('Error detecting time changes:', error);
  }
}

// Call this periodically or on app resume
monitorDateTimeChanges();
```

## Platform-Specific Notes

### iOS

The plugin uses a comprehensive multi-layered approach for reliable date/time detection:

#### Detection Method

1. **Cache Check** (Instant)
   - Returns cached result if available and less than 30 seconds old
   - Avoids unnecessary network calls for better performance

2. **Quick Timezone Check** (Preliminary)
   - Compares `TimeZone.autoupdatingCurrent` with `TimeZone.current`
   - If they differ, auto date/time is definitely disabled
   - Provides fast response for obvious cases

3. **Network Time Comparison** (Primary)
   - Fetches accurate UTC time from `https://worldtimeapi.org/api/timezone/Etc/UTC`
   - Compares device time with server time
   - **Threshold**: Time difference > 60 seconds indicates disabled auto date/time
   - **Timeout**: 3 seconds for network request
   - **Async**: Non-blocking operation with completion handler

4. **Offline Fallback** (When Network Unavailable)
   - Uses timezone comparison method
   - Considers system uptime for better accuracy
   - Ensures plugin works without network connection

#### Features

- ✅ **High Accuracy**: Detects manual time changes even if timezone is correct
- ✅ **Performance Optimized**: 30-second cache reduces network overhead
- ✅ **Offline Ready**: Falls back gracefully when network is unavailable
- ✅ **Battery Friendly**: Network monitoring prevents unnecessary requests
- ✅ **Non-Blocking**: Async operations don't freeze the UI
- ✅ **Automatic Cleanup**: Proper resource management on plugin deallocation
- ✅ **User Notifications**: Automatic native notifications for detected changes

#### Limitations

- First call after app launch requires network for best accuracy (cached afterward)
- Network check timeout is 3 seconds
- Assumes time difference > 60 seconds means auto-time is disabled
- Notifications require user permission

### Android

**Not implemented.** The source plugin (date_change_checker) only has basic Settings checks on Android, which can be easily done with native code:

```java
// Check if auto time is enabled
boolean isAutoTime = Settings.Global.getInt(
    context.getContentResolver(), 
    Settings.Global.AUTO_TIME, 
    0
) == 1;

// Check if auto timezone is enabled
boolean isAutoTimeZone = Settings.Global.getInt(
    context.getContentResolver(), 
    Settings.Global.AUTO_TIME_ZONE, 
    0
) == 1;
```

Android doesn't need the complex network validation that iOS requires because it has direct Settings API access.

### Web

This plugin is not supported on web. All methods will throw "Not implemented on web" errors.

## Troubleshooting

### iOS: Detection always returns true/false

**Problem**: The plugin always returns the same result regardless of actual settings.

**Solutions**:
1. **Check network connectivity**: The plugin needs internet access for accurate detection
2. **Wait for cache to expire**: If testing, wait 30+ seconds between tests
3. **Check time difference**: Ensure your manual time is >60 seconds different from actual time
4. **Verify WorldTimeAPI is accessible**: The plugin uses `https://worldtimeapi.org`

### iOS: Slow first response

**Problem**: First call to detection methods takes 3+ seconds.

**Explanation**: This is expected behavior. The first call makes a network request to fetch accurate time. Subsequent calls within 30 seconds use cached results and return instantly.

**Solution**: Pre-warm the cache by calling a detection method during app initialization with a loading indicator.

### iOS: Plugin doesn't work in airplane mode

**Problem**: Plugin returns unexpected results when device is offline.

**Explanation**: The plugin falls back to timezone-based detection when offline, which is less accurate.

**Solution**: This is expected behavior. For best accuracy, ensure network connectivity. The offline fallback is a compromise for offline scenarios.

### iOS: Notifications not showing

**Problem**: No notifications appear when changes are detected.

**Solutions**:
1. Ensure notification permissions are granted
2. Check device notification settings
3. The plugin requests permission on first load - user might have denied it

## Version History

See [CHANGELOG.md](CHANGELOG.md) for detailed version history.

**Latest version (2.1.0)**:
- ✨ Added `isDateTimeChangedSimple()` method for iOS and Android
- 🎯 Simple NTP-based detection matching Flutter plugin behavior
- 📱 iOS: 30-second threshold check without caching
- 📱 Android: Settings.Global.AUTO_TIME check
- 🔧 Total: 12 methods (iOS), 2 methods (Android)

**Previous version (2.0.1)**:
- ✨ Added `isDateTimeChanged()` method for iOS and Android
- 🔧 Simple wrapper returning inverse of `isAutoDateTimeEnabled`
- 📱 Android now has 1 implemented method
- 🎯 Total: 11 methods (iOS), 1 method (Android)

**Previous version (2.0.0)**:
- ✨ Cloned all iOS functionality from date_change_checker Flutter plugin
- ✨ Added comprehensive date/time change detection methods (4 methods)
- ✨ Added automatic user notifications for date/time changes (iOS)
- ✨ Added time utility methods (3 methods)
- ✨ Added timestamp management for change tracking (3 methods)
- ✨ Added `NotificationManager` for iOS notifications (259 lines)
- 🔧 Enhanced `AutoDateTimeDetector` with comprehensive 671-line implementation
- 📝 Complete TypeScript definitions for all methods
- 🎯 iOS-only implementation (matches source plugin's platform support)
- ❌ Removed Android/Web implementations (source plugin has minimal Android support)

## License

MIT

## Credits

This plugin is a Capacitor port of the Flutter [date_change_checker](https://github.com/error404sushant/date_change_checker) plugin. All iOS implementation logic is cloned from the original source.
