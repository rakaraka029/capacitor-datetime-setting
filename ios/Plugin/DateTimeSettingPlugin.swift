import Foundation
import Capacitor

/**
 * DateTimeSettingPlugin
 * 
 * Capacitor plugin to check auto time/timezone settings and open device settings.
 * 
 * iOS implementation uses network time comparison with AutoDateTimeDetector
 * for reliable detection of automatic date/time settings.
 */
@objc(DateTimeSettingPlugin)
public class DateTimeSettingPlugin: CAPPlugin {
    
    override public func load() {
        super.load()
        // Initialize the AutoDateTimeDetector
        AutoDateTimeDetector.initialize()
    }
    
    deinit {
        // Clean up network monitoring when plugin is deallocated
        AutoDateTimeDetector.stopNetworkMonitoring()
    }
    
    /**
     * Check if automatic time is enabled on the device.
     * 
     * iOS implementation uses network time comparison for reliable detection.
     * Results are cached for 30 seconds to minimize network calls.
     */
    @objc func timeIsAuto(_ call: CAPPluginCall) {
        AutoDateTimeDetector.isAutoDateTimeEnabled { isEnabled in
            DispatchQueue.main.async {
                call.resolve([
                    "value": isEnabled
                ])
            }
        }
    }
    
    /**
     * Check if automatic timezone is enabled on the device.
     * 
     * iOS implementation uses the same detection as timeIsAuto since
     * auto timezone and auto date/time are typically linked on iOS.
     */
    @objc func timeZoneIsAuto(_ call: CAPPluginCall) {
        AutoDateTimeDetector.isAutoDateTimeEnabled { isEnabled in
            DispatchQueue.main.async {
                call.resolve([
                    "value": isEnabled
                ])
            }
        }
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
