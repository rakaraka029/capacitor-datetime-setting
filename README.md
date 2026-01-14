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
- ✅ Android: Returns actual setting value
- ⚠️ iOS: Always returns `false` (iOS doesn't provide API to check this)

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
- ✅ Android: Returns actual setting value
- ⚠️ iOS: Always returns `false` (iOS doesn't provide API to check this)

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
    
    if (platform === 'android') {
      if (!timeResult.value || !timezoneResult.value) {
        // Show alert to user
        const shouldOpen = confirm(
          'Please enable automatic date & time and timezone for accurate time tracking.'
        );
        
        if (shouldOpen) {
          await DateTimeSetting.openSetting();
        }
      }
    } else if (platform === 'ios') {
      // iOS doesn't provide API to check, so we can only prompt user to check manually
      const shouldOpen = confirm(
        'Please ensure automatic date & time is enabled in Settings.'
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

iOS does not provide public APIs to:
- Check if automatic date & time is enabled
- Check if automatic timezone is enabled
- Open the Date & Time settings page directly

Therefore:
- `timeIsAuto()` and `timeZoneIsAuto()` always return `false`
- `openSetting()` opens the main Settings app instead of the specific Date & Time page

This is a platform limitation, not a plugin limitation.

### Web

This plugin is not supported on web. All methods will throw "Not implemented on web" errors.

## License

MIT

## Credits

This plugin is based on the Flutter [datetime_setting](https://github.com/fuadarradhi/datetime_setting) plugin by [fuadarradhi](https://github.com/fuadarradhi).
