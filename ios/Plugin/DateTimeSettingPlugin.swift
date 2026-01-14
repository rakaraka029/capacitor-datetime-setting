import Foundation
import Capacitor

/**
 * DateTimeSettingPlugin
 * 
 * Capacitor plugin to check auto time/timezone settings and open device settings.
 * 
 * iOS implementation uses TimeZone.autoupdatingCurrent to determine
 * if the device is set to automatically update its time zone and date/time settings.
 */
@objc(DateTimeSettingPlugin)
public class DateTimeSettingPlugin: CAPPlugin {
    
    /**
     * Check if automatic time is enabled on the device.
     * 
     * iOS implementation uses TimeZone.autoupdatingCurrent to determine
     * if the device is set to automatically update its time zone and date/time settings.
     */
    @objc func timeIsAuto(_ call: CAPPluginCall) {
        let isAuto = checkAutoDateTime()
        call.resolve([
            "value": isAuto
        ])
    }
    
    /**
     * Check if automatic timezone is enabled on the device.
     * 
     * iOS implementation uses TimeZone.autoupdatingCurrent to determine
     * if the device is set to automatically update its time zone.
     */
    @objc func timeZoneIsAuto(_ call: CAPPluginCall) {
        let isAuto = checkAutoDateTime()
        call.resolve([
            "value": isAuto
        ])
    }
    
    /**
     * Helper method to check if auto date/time is enabled.
     * 
     * Compares the autoupdating timezone with the system timezone.
     * If they are equal, auto date/time is enabled.
     */
    private func checkAutoDateTime() -> Bool {
        let autoUpdatingTimeZone = TimeZone.autoupdatingCurrent
        let systemTimeZone = TimeZone.current
        return autoUpdatingTimeZone == systemTimeZone
    }
    
    /**
     * Open the device's Settings app.
     * 
     * On iOS, this opens the main Settings app as there's no direct way
     * to open the Date & Time settings page.
     */
    @objc func openSetting(_ call: CAPPluginCall) {
        DispatchQueue.main.async {
            if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                if UIApplication.shared.canOpenURL(settingsUrl) {
                    UIApplication.shared.open(settingsUrl, options: [:]) { success in
                        if success {
                            call.resolve()
                        } else {
                            call.reject("Failed to open settings")
                        }
                    }
                } else {
                    call.reject("Cannot open settings URL")
                }
            } else {
                call.reject("Invalid settings URL")
            }
        }
    }
}
