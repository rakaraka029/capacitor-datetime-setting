# Capacitor DateTime Setting Plugin

[![npm version](https://img.shields.io/npm/v/@greatdayhr/capacitor-datetime-setting.svg)](https://www.npmjs.com/package/@greatdayhr/capacitor-datetime-setting)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)

Capacitor plugin to get information about auto time and auto timezone settings, and open device settings if needed.

## Installation

```bash
npm install @greatdayhr/capacitor-datetime-setting
npx cap sync
```

## API

### `timeIsAuto()`

Check if automatic time is enabled on the device.

**Returns:** `Promise<{ value: boolean }>`

**Platform Support:**
- ✅ Android: Returns actual setting value using `Settings.Global.AUTO_TIME`
- ✅ iOS: Uses network time comparison for reliable detection (with offline fallback)

**Example:**

```typescript
import { DateTimeSetting } from '@greatdayhr/capacitor-datetime-setting';

const result = await DateTimeSetting.timeIsAuto();
console.log('Auto time enabled:', result.value);
```

---

### `timeZoneIsAuto()`

Check if automatic timezone is enabled on the device.

**Returns:** `Promise<{ value: boolean }>`

**Platform Support:**
- ✅ Android: Returns actual setting value using `Settings.Global.AUTO_TIME_ZONE`
- ✅ iOS: Uses network time comparison for reliable detection (with offline fallback)

**Example:**

```typescript
import { DateTimeSetting } from '@greatdayhr/capacitor-datetime-setting';

const result = await DateTimeSetting.timeZoneIsAuto();
console.log('Auto timezone enabled:', result.value);
```

---

### `openSetting()`

Open the device's date and time settings screen.

**Returns:** `Promise<void>`

**Platform Support:**
- ✅ Android: Opens Date & Time settings directly
- ⚠️ iOS: Opens main Settings app (cannot open specific settings page)

**Example:**

```typescript
import { DateTimeSetting } from '@greatdayhr/capacitor-datetime-setting';

await DateTimeSetting.openSetting();
```

## Usage Example

Here's a complete example showing how to check settings and prompt user to enable auto time:

```typescript
import { DateTimeSetting } from '@greatdayhr/capacitor-datetime-setting';
import { Capacitor } from '@capacitor/core';

async function checkAutoTimeSettings() {
  try {
    const timeResult = await DateTimeSetting.timeIsAuto();
    const timezoneResult = await DateTimeSetting.timeZoneIsAuto();
    
    const platform = Capacitor.getPlatform();
    
    // Both Android and iOS can now detect auto time settings
    if (!timeResult.value || !timezoneResult.value) {
      // Show alert to user
      const shouldOpen = confirm(
        'Please enable automatic date & time and timezone for accurate time tracking.'
      );
      
      if (shouldOpen) {
        await DateTimeSetting.openSetting();
      }
    }
  } catch (error) {
    console.error('Error checking time settings:', error);
  }
}
```

## Platform-Specific Notes

### Android

The plugin uses Android's `Settings.Global` API to check the auto time and timezone settings. It supports Android API level 17 (Jelly Bean MR1) and above, with fallback to `Settings.System` for older versions.

**Permissions:** No special permissions required.

### iOS

iOS does not provide direct public APIs to check auto date/time settings. This plugin uses a **network-based detection** method for reliable results:

#### Detection Method

The plugin uses a multi-layered approach to detect auto date/time settings:

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

#### Why Network Comparison?

The simple `TimeZone.autoupdatingCurrent` check alone is **not reliable** because:
- It can return false positives when timezone is set correctly but time is manually changed
- It doesn't detect when user manually sets the exact same timezone
- Network time comparison provides definitive proof of time synchronization

#### Features

- ✅ **High Accuracy**: Detects manual time changes even if timezone is correct
- ✅ **Performance Optimized**: 30-second cache reduces network overhead
- ✅ **Offline Ready**: Falls back gracefully when network is unavailable
- ✅ **Battery Friendly**: Network monitoring prevents unnecessary requests
- ✅ **Non-Blocking**: Async operations don't freeze the UI
- ✅ **Automatic Cleanup**: Proper resource management on plugin deallocation

#### Limitations

- `openSetting()` opens the main Settings app instead of the specific Date & Time page (iOS restriction)
- First call after app launch requires network for best accuracy (cached afterward)
- Network check timeout is 3 seconds
- Assumes time difference > 60 seconds means auto-time is disabled (works for most cases)

#### Technical Implementation

**Network Time Server**: Uses WorldTimeAPI for reliable UTC time  
**Caching Strategy**: In-memory cache with 30-second TTL  
**Network Monitoring**: Uses Apple's `Network` framework  
**Threading**: Main queue dispatch for Capacitor callbacks  

**Credit:** This technique is inspired by the Flutter [date_change_checker](https://github.com/error404sushant/date_change_checker) plugin.

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

**Problem**: First call to `timeIsAuto()` takes 3+ seconds.

**Explanation**: This is expected behavior. The first call makes a network request to fetch accurate time. Subsequent calls within 30 seconds use cached results and return instantly.

**Solution**: If you need instant response, consider:
- Pre-warming the cache by calling `timeIsAuto()` during app initialization
- Showing a loading indicator during the first check
- Using the offline fallback (less accurate but instant)

### iOS: Plugin doesn't work in airplane mode

**Problem**: Plugin returns unexpected results when device is offline.

**Explanation**: The plugin falls back to timezone-based detection when offline, which is less accurate.

**Solution**: This is expected behavior. For best accuracy, ensure network connectivity. The offline fallback is a compromise for offline scenarios.

### Android: Plugin not detecting changes

**Problem**: Auto time/timezone setting changes are not detected.

**Solution**: Ensure you're testing on a physical device. Some emulators may not properly reflect system setting changes.

## Version History

See [CHANGELOG.md](CHANGELOG.md) for detailed version history.

**Latest version (1.2.0)**:
- Improved iOS detection with network time comparison
- Added caching for better performance
- Better offline support

## License

MIT

## Credits

This plugin is based on the Flutter [datetime_setting](https://github.com/fuadarradhi/datetime_setting) plugin by [fuadarradhi](https://github.com/fuadarradhi).
