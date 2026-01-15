package com.datetimesetting;

import android.content.Context;
import android.provider.Settings;

import com.getcapacitor.JSObject;
import com.getcapacitor.Plugin;
import com.getcapacitor.PluginCall;
import com.getcapacitor.PluginMethod;
import com.getcapacitor.annotation.CapacitorPlugin;

/**
 * DateTimeSettingPlugin - Android Implementation
 * 
 * Cloned from date_change_checker Flutter plugin.
 * Android implementation provides simple Settings check.
 */
@CapacitorPlugin(name = "DateTimeSetting")
public class DateTimeSettingPlugin extends Plugin {
    
    /**
     * Check if date/time has been manually changed.
     * Returns true if auto date/time is disabled.
     * 
     * This is the inverse of isAutoDateTimeEnabled check.
     * Matches date_change_checker Android implementation.
     */
    @PluginMethod
    public void isDateTimeChanged(PluginCall call) {
        try {
            Context context = getContext();
            boolean isAutoEnabled = isAutoDateTimeEnabled(context);
            
            JSObject result = new JSObject();
            // Return !isAutoEnabled to indicate if date/time might be changed
            result.put("changed", !isAutoEnabled);
            call.resolve(result);
        } catch (Exception e) {
            call.reject("Failed to detect date/time change", e);
        }
    }
    
    /**
     * Helper method to check if automatic date/time is enabled.
     * Uses Settings.Global.AUTO_TIME.
     */
    private boolean isAutoDateTimeEnabled(Context context) {
        try {
            int autoTime = Settings.Global.getInt(
                context.getContentResolver(),
                Settings.Global.AUTO_TIME
            );
            return autoTime == 1;
        } catch (Settings.SettingNotFoundException e) {
            // If setting is not found, assume it's disabled
            return false;
        }
    }
}
