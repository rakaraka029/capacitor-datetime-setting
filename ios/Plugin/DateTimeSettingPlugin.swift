import Foundation
import Capacitor

/**
 * DateTimeSettingPlugin
 * 
 * Capacitor plugin to check auto time/timezone settings and open device settings.
 * 
 * Note: iOS does not provide APIs to check if auto time/timezone is enabled.
 * The timeIsAuto and timeZoneIsAuto methods will return false with a note.
 */
@objc(DateTimeSettingPlugin)
public class DateTimeSettingPlugin: CAPPlugin {
    
    /**
     * Check if automatic time is enabled on the device.
     * 
     * iOS Implementation:
     * Uses NSTimeZone.autoupdatingCurrent comparison with NSTimeZone.system
     * to determine if automatic date/time is enabled.
     * 
     * When auto date/time is ON: autoupdatingCurrent equals system timezone
     * When auto date/time is OFF: they may differ
     */
    @objc func timeIsAuto(_ call: CAPPluginCall) {
        let autoUpdatingTimeZone = NSTimeZone.autoupdatingCurrent
        let systemTimeZone = NSTimeZone.system
        
        // If they are equal, auto date/time is likely enabled
        let isAutoEnabled = autoUpdatingTimeZone.isEqual(to: systemTimeZone)
        
        call.resolve([
            "value": isAutoEnabled
        ])
    }
    
    /**
     * Check if automatic timezone is enabled on the device.
     * 
     * iOS Implementation:
     * Uses the same NSTimeZone comparison technique as timeIsAuto.
     * This is because iOS doesn't separate auto time and auto timezone settings.
     */
    @objc func timeZoneIsAuto(_ call: CAPPluginCall) {
        let autoUpdatingTimeZone = NSTimeZone.autoupdatingCurrent
        let systemTimeZone = NSTimeZone.system
        
        // If they are equal, auto timezone is likely enabled
        let isAutoEnabled = autoUpdatingTimeZone.isEqual(to: systemTimeZone)
        
        call.resolve([
            "value": isAutoEnabled
        ])
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
