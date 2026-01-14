package com.datetimesetting;

import android.content.Intent;
import android.os.Build;
import android.provider.Settings;

import com.getcapacitor.JSObject;
import com.getcapacitor.Plugin;
import com.getcapacitor.PluginCall;
import com.getcapacitor.PluginMethod;
import com.getcapacitor.annotation.CapacitorPlugin;

/**
 * DateTimeSettingPlugin
 * 
 * Capacitor plugin to check auto time/timezone settings and open device settings.
 */
@CapacitorPlugin(name = "DateTimeSetting")
public class DateTimeSettingPlugin extends Plugin {

    /**
     * Check if automatic time is enabled on the device.
     * 
     * @param call The plugin call
     */
    @PluginMethod
    public void timeIsAuto(PluginCall call) {
        try {
            boolean isAuto;
            
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN_MR1) {
                isAuto = Settings.Global.getInt(
                    getContext().getContentResolver(), 
                    Settings.Global.AUTO_TIME, 
                    0
                ) == 1;
            } else {
                isAuto = Settings.System.getInt(
                    getContext().getContentResolver(), 
                    Settings.System.AUTO_TIME, 
                    0
                ) == 1;
            }
            
            JSObject result = new JSObject();
            result.put("value", isAuto);
            call.resolve(result);
        } catch (Exception e) {
            call.reject("Failed to check auto time setting", e);
        }
    }

    /**
     * Check if automatic timezone is enabled on the device.
     * 
     * @param call The plugin call
     */
    @PluginMethod
    public void timeZoneIsAuto(PluginCall call) {
        try {
            boolean isAuto;
            
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN_MR1) {
                isAuto = Settings.Global.getInt(
                    getContext().getContentResolver(), 
                    Settings.Global.AUTO_TIME_ZONE, 
                    0
                ) == 1;
            } else {
                isAuto = Settings.System.getInt(
                    getContext().getContentResolver(), 
                    Settings.System.AUTO_TIME_ZONE, 
                    0
                ) == 1;
            }
            
            JSObject result = new JSObject();
            result.put("value", isAuto);
            call.resolve(result);
        } catch (Exception e) {
            call.reject("Failed to check auto timezone setting", e);
        }
    }

    /**
     * Open the device's date and time settings screen.
     * 
     * @param call The plugin call
     */
    @PluginMethod
    public void openSetting(PluginCall call) {
        try {
            Intent intent = new Intent(Settings.ACTION_DATE_SETTINGS);
            intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
            getContext().startActivity(intent);
            call.resolve();
        } catch (Exception e) {
            call.reject("Failed to open date/time settings", e);
        }
    }
}
