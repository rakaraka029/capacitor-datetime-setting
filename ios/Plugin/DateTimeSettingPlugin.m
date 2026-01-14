#import <Foundation/Foundation.h>
#import <Capacitor/Capacitor.h>

// Define the plugin using the CAP_PLUGIN Macro, and
// each method the plugin supports using the CAP_PLUGIN_METHOD macro.
CAP_PLUGIN(DateTimeSettingPlugin, "DateTimeSetting",
           CAP_PLUGIN_METHOD(timeIsAuto, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(timeZoneIsAuto, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(openSetting, CAPPluginReturnPromise);
)
