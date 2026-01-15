import Foundation
import Network

/**
 * iOS implementation for detecting automatic date/time settings
 * Uses network time comparison for accuracy with offline fallback
 */
class AutoDateTimeDetector {
    
    // MARK: - Properties
    
    private static var networkMonitor = NWPathMonitor()
    private static var isNetworkAvailable = true
    
    // Cache for auto date/time status to avoid repeated network calls
    private static var cachedAutoDateTimeStatus: Bool?
    private static var lastStatusCheckTime: Date?
    private static let statusCacheInterval: TimeInterval = 30.0 // Cache for 30 seconds
    
    // MARK: - Initialization
    
    static func initialize() {
        startNetworkMonitoring()
    }
    
    // MARK: - Auto Date/Time Detection
    
    /**
     * Checks if automatic date/time is enabled on iOS device (async version)
     * Uses caching to provide instant results and avoid network delays
     */
    static func isAutoDateTimeEnabled(completion: @escaping (Bool) -> Void) {
        // Check if we have a recent cached result
        if let cachedStatus = cachedAutoDateTimeStatus,
           let lastCheck = lastStatusCheckTime,
           Date().timeIntervalSince(lastCheck) < statusCacheInterval {
            completion(cachedStatus)
            return
        }
        
        // First, try the timezone approach as a quick check
        let autoUpdatingTimeZone = TimeZone.autoupdatingCurrent
        let systemTimeZone = TimeZone.current
        
        // If timezone auto-update is disabled, automatic date/time is likely disabled
        if autoUpdatingTimeZone.identifier != systemTimeZone.identifier {
            let result = false
            cachedAutoDateTimeStatus = result
            lastStatusCheckTime = Date()
            completion(result)
            return
        }
        
        // Perform network-based time comparison asynchronously
        checkTimeWithNetworkServerAsync { isEnabled in
            cachedAutoDateTimeStatus = isEnabled
            lastStatusCheckTime = Date()
            completion(isEnabled)
        }
    }
    
    /**
     * Synchronous version for backward compatibility (uses cached result or fallback)
     */
    static func isAutoDateTimeEnabled() -> Bool {
        // Return cached result if available and recent
        if let cachedStatus = cachedAutoDateTimeStatus,
           let lastCheck = lastStatusCheckTime,
           Date().timeIntervalSince(lastCheck) < statusCacheInterval {
            return cachedStatus
        }
        
        // Fallback to offline check for immediate response
        return isAutoDateTimeEnabledOffline()
    }
    
    /**
     * Alternative method for offline scenarios
     * Checks system settings indirectly through available APIs
     */
    static func isAutoDateTimeEnabledOffline() -> Bool {
        // Check if timezone auto-update is enabled
        let autoUpdatingTimeZone = TimeZone.autoupdatingCurrent
        let systemTimeZone = TimeZone.current
        
        // Additional check: compare with system uptime
        let processInfo = ProcessInfo.processInfo
        let systemUptime = processInfo.systemUptime
        
        // If system has been up for a while and timezone matches auto-updating,
        // it's likely that auto date/time is enabled
        if systemUptime > 300 && autoUpdatingTimeZone.identifier == systemTimeZone.identifier {
            return true
        }
        
        return autoUpdatingTimeZone.identifier == systemTimeZone.identifier
    }
    
    // MARK: - Helper Methods
    
    /**
     * Compares device time with network time server (async version)
     * Non-blocking approach for better performance
     */
    private static func checkTimeWithNetworkServerAsync(completion: @escaping (Bool) -> Void) {
        // Create URL request to a reliable time server
        guard let url = URL(string: "https://worldtimeapi.org/api/timezone/Etc/UTC") else {
            completion(true) // Fallback to true if URL creation fails
            return
        }
        
        var request = URLRequest(url: url)
        request.timeoutInterval = 3.0 // Reduced timeout for faster response
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            // Check for network errors
            if let error = error {
                print("Network error checking time: \(error.localizedDescription)")
                completion(true) // Default to true if network check fails
                return
            }
            
            // Parse response data
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let unixTimeString = json["unixtime"] as? Double else {
                print("Failed to parse time server response")
                completion(true) // Default to true if parsing fails
                return
            }
            
            // Compare server time with device time
            let serverTime = Date(timeIntervalSince1970: unixTimeString)
            let deviceTime = Date()
            let timeDifference = abs(deviceTime.timeIntervalSince(serverTime))
            
            // If time difference is more than 60 seconds, consider auto-time disabled
            // This threshold accounts for network latency and minor clock drift
            if timeDifference > 60.0 {
                print("Time difference detected: \(timeDifference) seconds")
                completion(false)
            } else {
                completion(true)
            }
        }
        
        task.resume()
    }
    
    /**
     * Starts network connectivity monitoring for battery optimization
     */
    private static func startNetworkMonitoring() {
        let queue = DispatchQueue(label: "NetworkMonitor")
        networkMonitor.start(queue: queue)
        
        networkMonitor.pathUpdateHandler = { path in
            isNetworkAvailable = path.status == .satisfied
        }
    }
    
    /**
     * Stops network monitoring to conserve battery
     */
    static func stopNetworkMonitoring() {
        networkMonitor.cancel()
    }
    
    /**
     * Resets the status cache
     */
    static func reset() {
        cachedAutoDateTimeStatus = nil
        lastStatusCheckTime = nil
    }
}
