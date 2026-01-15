
#import <Foundation/Foundation.h>
#import <Capacitor/Capacitor.h>

// Define the plugin using the CAP_PLUGIN Macro, and
// each method the plugin supports using the CAP_PLUGIN_METHOD macro.
CAP_PLUGIN(DateTimeSettingPlugin, "DateTimeSetting",
           // Simple change detection
           CAP_PLUGIN_METHOD(isDateTimeChanged, CAPPluginReturnPromise);
           
           // Date/Time Change Detection
           CAP_PLUGIN_METHOD(detectDateTimeChange, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(detectComprehensiveDateTimeChange, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(detectDateOnlyChange, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(detectAndNotifyDateTimeChanges, CAPPluginReturnPromise);
           
           // Time Utilities
           CAP_PLUGIN_METHOD(getLocalTime, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(getInternetUTCTime, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(convertToLocalTime, CAPPluginReturnPromise);
           
           // Timestamp Management
           CAP_PLUGIN_METHOD(setStoredTimestamp, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(getStoredTimestamp, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(resetDetector, CAPPluginReturnPromise);
)

