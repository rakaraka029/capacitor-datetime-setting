import Foundation
import Capacitor

/**
 * DateTimeSettingPlugin
 * 
 * Capacitor plugin for comprehensive date/time change detection and management.
 * Cloned from date_change_checker Flutter plugin.
 * 
 * iOS implementation uses network time comparison with AutoDateTimeDetector
 * for reliable detection of automatic date/time settings and changes.
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
     * Check if date/time has been manually changed.
     * Returns true if auto date/time is disabled (inverse of auto time enabled).
     * 
     * This is a simple wrapper from date_change_checker source.
     * 
     * @since 2.0.1
     */
    @objc func isDateTimeChanged(_ call: CAPPluginCall) {
        AutoDateTimeDetector.isAutoDateTimeEnabled { isEnabled in
            DispatchQueue.main.async {
                // Return !isEnabled to indicate if date/time has been changed
                call.resolve([
                    "changed": !isEnabled
                ])
            }
        }
    }
    
    /**
     * Simple NTP-based check if date/time has been manually changed.
     * Uses basic 30-second threshold comparison without caching.
     * 
     * This method matches Flutter plugin behavior exactly:
     * - iOS: Compares device time with NTP server (30s threshold)
     * - Returns true if auto time is disabled or network fails
     * 
     * @since 2.1.0
     */
    @objc func isDateTimeChangedSimple(_ call: CAPPluginCall) {
        AutoDateTimeDetector.isAutoDateTimeEnabledSimple { isEnabled in
            DispatchQueue.main.async {
                // Return !isEnabled to indicate if date/time has been changed
                call.resolve([
                    "changed": !isEnabled
                ])
            }
        }
    }
    
    // MARK: - Date/Time Change Detection
    
    /**
     * Detects if the device's date/time has been manually changed
     */
    @objc func detectDateTimeChange(_ call: CAPPluginCall) {
        AutoDateTimeDetector.detectDateTimeChange { changeDetected in
            DispatchQueue.main.async {
                call.resolve([
                    "changed": changeDetected
                ])
            }
        }
    }
    
    /**
     * Comprehensive date and time change detection with detailed analysis
     */
    @objc func detectComprehensiveDateTimeChange(_ call: CAPPluginCall) {
        AutoDateTimeDetector.detectComprehensiveDateTimeChange { result in
            DispatchQueue.main.async {
                let changeTypeString: String
                switch result.changeType {
                case .noChange:
                    changeTypeString = "noChange"
                case .timeOnly:
                    changeTypeString = "timeOnly"
                case .dateOnly:
                    changeTypeString = "dateOnly"
                case .dateAndTime:
                    changeTypeString = "dateAndTime"
                }
                
                var resultDict: [String: Any] = [
                    "changeType": changeTypeString,
                    "timeDifference": result.timeDifference,
                    "dateChanged": result.dateChanged,
                    "timeChanged": result.timeChanged,
                    "isAutoDateTimeEnabled": result.isAutoDateTimeEnabled,
                    "currentDate": result.currentDate.timeIntervalSince1970
                ]
                
                if let previousDate = result.previousDate {
                    resultDict["previousDate"] = previousDate.timeIntervalSince1970
                }
                
                call.resolve(resultDict)
            }
        }
    }
    
    /**
     * Detects specifically if only the date has been changed
     */
    @objc func detectDateOnlyChange(_ call: CAPPluginCall) {
        AutoDateTimeDetector.detectDateOnlyChange { changeDetected in
            DispatchQueue.main.async {
                call.resolve([
                    "changed": changeDetected
                ])
            }
        }
    }
    
    /**
     * Comprehensive date and time change detection with automatic notifications
     */
    @objc func detectAndNotifyDateTimeChanges(_ call: CAPPluginCall) {
        AutoDateTimeDetector.detectAndNotifyDateTimeChanges { result in
            DispatchQueue.main.async {
                let changeTypeString: String
                switch result.changeType {
                case .noChange:
                    changeTypeString = "noChange"
                case .timeOnly:
                    changeTypeString = "timeOnly"
                case .dateOnly:
                    changeTypeString = "dateOnly"
                case .dateAndTime:
                    changeTypeString = "dateAndTime"
                }
                
                var resultDict: [String: Any] = [
                    "changeType": changeTypeString,
                    "timeDifference": result.timeDifference,
                    "dateChanged": result.dateChanged,
                    "timeChanged": result.timeChanged,
                    "isAutoDateTimeEnabled": result.isAutoDateTimeEnabled,
                    "currentDate": result.currentDate.timeIntervalSince1970
                ]
                
                if let previousDate = result.previousDate {
                    resultDict["previousDate"] = previousDate.timeIntervalSince1970
                }
                
                call.resolve(resultDict)
            }
        }
    }
    
    // MARK: - Time Utilities
    
    /**
     * Get the device's current local time
     */
    @objc func getLocalTime(_ call: CAPPluginCall) {
        let currentTime = AutoDateTimeDetector.getCurrentLocalTime()
        let timestamp = currentTime.timeIntervalSince1970
        call.resolve([
            "timestamp": timestamp
        ])
    }
    
    /**
     * Fetch accurate UTC time from internet time server
     */
    @objc func getInternetUTCTime(_ call: CAPPluginCall) {
        AutoDateTimeDetector.fetchInternetUTCTime { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let utcTime):
                    let timestamp = utcTime.timeIntervalSince1970
                    call.resolve([
                        "timestamp": timestamp
                    ])
                case .failure(let error):
                    call.reject("Failed to fetch internet time", nil, error)
                }
            }
        }
    }
    
    /**
     * Convert local time to UTC
     */
    @objc func convertToLocalTime(_ call: CAPPluginCall) {
        guard let timestamp = call.getDouble("timestamp") else {
            call.reject("Missing timestamp parameter")
            return
        }
        
        let localTime = Date(timeIntervalSince1970: timestamp)
        let utcTime = AutoDateTimeDetector.convertLocalTimeToUTC(localTime)
        let utcTimestamp = utcTime.timeIntervalSince1970
        
        call.resolve([
            "timestamp": utcTimestamp
        ])
    }
    
    // MARK: - Timestamp Management
    
    /**
     * Set the stored timestamp for future change detection
     */
    @objc func setStoredTimestamp(_ call: CAPPluginCall) {
        guard let timestamp = call.getDouble("timestamp") else {
            call.reject("Missing timestamp parameter")
            return
        }
        
        let date = Date(timeIntervalSince1970: timestamp)
        AutoDateTimeDetector.setStoredTimestamp(date)
        call.resolve()
    }
    
    /**
     * Get the currently stored timestamp
     */
    @objc func getStoredTimestamp(_ call: CAPPluginCall) {
        if let storedTime = AutoDateTimeDetector.getStoredTimestamp() {
            let timestamp = storedTime.timeIntervalSince1970
            call.resolve([
                "timestamp": timestamp
            ])
        } else {
            call.resolve([
                "timestamp": NSNull()
            ])
        }
    }
    
    /**
     * Reset the detector (clears all stored data and cache)
     */
    @objc func resetDetector(_ call: CAPPluginCall) {
        AutoDateTimeDetector.reset()
        call.resolve()
    }
}
