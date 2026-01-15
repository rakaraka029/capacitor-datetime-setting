package com.datetimesetting;

import com.getcapacitor.Plugin;
import com.getcapacitor.annotation.CapacitorPlugin;

/**
 * DateTimeSettingPlugin - Android Implementation
 * 
 * Note: All date/time detection methods are iOS-only.
 * Android does not implement the comprehensive features from date_change_checker
 * because the source plugin itself only has basic Settings checks on Android.
 * 
 * For Android auto time detection, use native Settings API directly:
 * Settings.Global.getInt(context.getContentResolver(), Settings.Global.AUTO_TIME, 0) == 1
 */
@CapacitorPlugin(name = "DateTimeSetting")
public class DateTimeSettingPlugin extends Plugin {
    // All methods are iOS-only
    // Android implementation intentionally left minimal as per date_change_checker source
}
