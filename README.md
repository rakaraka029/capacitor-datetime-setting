# Capacitor DateTime Setting Plugin

Capacitor plugin to get information about auto time and auto timezone settings, and open device settings if needed.

This plugin is a Capacitor port of the Flutter [datetime_setting](https://github.com/fuadarradhi/datetime_setting) plugin.

## Installation

```bash
npm install capacitor-datetime-setting
npx cap sync
```

## API

### `timeIsAuto()`

Check if automatic time is enabled on the device.

**Returns:** `Promise<{ value: boolean }>`

**Platform Support:**
- ✅ Android: Returns actual setting value using `Settings.Global.AUTO_TIME`
- ✅ iOS: Returns actual setting value using `NSTimeZone.autoupdatingCurrent` comparison

**Example:**

```typescript
import { DateTimeSetting } from 'capacitor-datetime-setting';

const result = await DateTimeSetting.timeIsAuto();
console.log('Auto time enabled:', result.value);
```

---

### `timeZoneIsAuto()`

Check if automatic timezone is enabled on the device.

**Returns:** `Promise<{ value: boolean }>`

**Platform Support:**
- ✅ Android: Returns actual setting value using `Settings.Global.AUTO_TIME_ZONE`
- ✅ iOS: Returns actual setting value using `NSTimeZone.autoupdatingCurrent` comparison

**Example:**

```typescript
import { DateTimeSetting } from 'capacitor-datetime-setting';

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
import { DateTimeSetting } from 'capacitor-datetime-setting';

await DateTimeSetting.openSetting();
```

## Usage Example

Here's a complete example showing how to check settings and prompt user to enable auto time:

```typescript
import { DateTimeSetting } from 'capacitor-datetime-setting';
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

iOS does not provide direct public APIs to check auto date/time settings, but this plugin uses a **workaround** technique:

**Detection Method:**
- Compares `NSTimeZone.autoupdatingCurrent` with `NSTimeZone.system`
- When auto date/time is **enabled**: these two timezone objects are equal
- When auto date/time is **disabled**: they may differ

**Limitations:**
- `openSetting()` opens the main Settings app instead of the specific Date & Time page (iOS restriction)
- The detection method is a workaround and may not be 100% accurate in all edge cases

**Credit:** This technique is inspired by the Flutter [date_change_checker](https://github.com/error404sushant/date_change_checker) plugin.

### Web

This plugin is not supported on web. All methods will throw "Not implemented on web" errors.

## License

MIT

## Credits

This plugin is based on the Flutter [datetime_setting](https://github.com/fuadarradhi/datetime_setting) plugin by [fuadarradhi](https://github.com/fuadarradhi).
