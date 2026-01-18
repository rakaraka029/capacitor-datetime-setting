import Foundation
import Network
import UserNotifications

/**
 * iOS implementation for detecting automatic date/time settings and date/time changes
 */
class AutoDateTimeDetector {
    
    // MARK: - Properties
    
    private static let timeChangeThreshold: TimeInterval = 5.0 // 5 seconds
    private static let networkCheckInterval: TimeInterval = 300.0 // 5 minutes
    private static var networkMonitor = NWPathMonitor()
    private static var isNetworkAvailable = true
    
    private static var storedTimestamp: Date?
    private static var storedDateComponents: DateComponents?
    private static var lastNetworkCheckTime: Date?
    
    // MARK: - Date Change Detection Types
    
    enum DateTimeChangeType {
        case noChange
        case timeOnly
        case dateOnly
        case dateAndTime
    }
    
    struct DateTimeChangeResult {
        let changeType: DateTimeChangeType
        let timeDifference: TimeInterval
        let dateChanged: Bool
        let timeChanged: Bool
        let isAutoDateTimeEnabled: Bool
        let previousDate: Date?
        let currentDate: Date
    }
    
    // MARK: - Initialization
    static func initialize() {
        startNetworkMonitoring()
        storedTimestamp = getCurrentLocalTime()
        storedDateComponents = Calendar.current.dateComponents([.year, .month, .day], from: getCurrentLocalTime())
        
        // Request notification permission
        NotificationManager.shared.requestNotificationPermission { granted in
            print("Notification permission granted: \(granted)")
        }
    }
    
    // MARK: - Date/Time Change Detection
    
    /**
     * Retrieves the device's current local time
     * @return Current local time as Date object
     */
    static func getCurrentLocalTime() -> Date {
        return Date()
    }
    
    /**
     * Converts local time to UTC
     * @param localTime The local time to convert
     * @return UTC time as Date object
     */
    static func convertLocalTimeToUTC(_ localTime: Date) -> Date {
        let timeZone = TimeZone.current
        let utcOffset = timeZone.secondsFromGMT(for: localTime)
        return localTime.addingTimeInterval(-TimeInterval(utcOffset))
    }
    
    /**
     * Fetches accurate UTC time from internet time server
     * @param completion Completion handler with Result containing UTC time or error
     */
    static func fetchInternetUTCTime(completion: @escaping (Result<Date, Error>) -> Void) {
        guard isNetworkAvailable else {
            completion(.failure(NSError(domain: "NetworkError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Network not available"])))
            return
        }
        
        guard let url = URL(string: "https://worldtimeapi.org/api/timezone/Etc/UTC") else {
            completion(.failure(NSError(domain: "URLError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        var request = URLRequest(url: url)
        request.timeoutInterval = 10.0
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let unixTimeString = json["unixtime"] as? Double else {
                completion(.failure(NSError(domain: "ParseError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to parse server response"])))
                return
            }
            
            let utcTime = Date(timeIntervalSince1970: unixTimeString)
            completion(.success(utcTime))
        }
        
        task.resume()
    }
    
    /**
     * Detects if the device's date/time has been manually changed
     * Uses network time comparison for accuracy when available
     * Falls back to local time comparison for offline scenarios
     *
     * @param completion Callback with detection result
     */
    static func detectDateTimeChange(completion: @escaping (Bool) -> Void) {
        let currentLocalTime = getCurrentLocalTime()
        
        guard let storedTime = storedTimestamp else {
            // First time check - store current time and return false
            storedTimestamp = currentLocalTime
            storedDateComponents = Calendar.current.dateComponents([.year, .month, .day], from: currentLocalTime)
            completion(false)
            return
        }
        
        // Check if we should perform network-based detection
        if shouldPerformNetworkTimeCheck() {
            fetchInternetUTCTime { result in
                switch result {
                case .success(let internetTime):
                    lastNetworkCheckTime = Date()
                    
                    // Compare with stored time considering network time as reference
                    let expectedLocalTime = internetTime.addingTimeInterval(TimeInterval(TimeZone.current.secondsFromGMT()))
                    let timeDifference = abs(currentLocalTime.timeIntervalSince(expectedLocalTime))
                    
                    let changeDetected = timeDifference > timeChangeThreshold
                    
                    if changeDetected {
                        print("Network-based time change detected: \(timeDifference) seconds difference")
                        storedTimestamp = currentLocalTime
                        storedDateComponents = Calendar.current.dateComponents([.year, .month, .day], from: currentLocalTime)
                    }
                    
                    completion(changeDetected)
                    
                case .failure(let error):
                    print("Failed to fetch internet time: \(error.localizedDescription)")
                    // Fallback to local time comparison
                    let changeDetected = detectLocalTimeChange(currentTime: currentLocalTime, storedTime: storedTime)
                    completion(changeDetected)
                }
            }
        } else {
            // Use local time comparison to minimize network usage
            let changeDetected = detectLocalTimeChange(currentTime: currentLocalTime, storedTime: storedTime)
            completion(changeDetected)
        }
    }
    
    /**
     * Comprehensive date and time change detection with detailed analysis
     * Distinguishes between date-only, time-only, and combined changes
     *
     * @param completion Callback with detailed change result
     */
    static func detectComprehensiveDateTimeChange(completion: @escaping (DateTimeChangeResult) -> Void) {
        let currentLocalTime = getCurrentLocalTime()
        let currentDateComponents = Calendar.current.dateComponents([.year, .month, .day], from: currentLocalTime)
        
        guard let storedTime = storedTimestamp,
              let storedComponents = storedDateComponents else {
            // First time check - store current time and date components
            storedTimestamp = currentLocalTime
            storedDateComponents = currentDateComponents
            
            let result = DateTimeChangeResult(
                changeType: .noChange,
                timeDifference: 0,
                dateChanged: false,
                timeChanged: false,
                isAutoDateTimeEnabled: isAutoDateTimeEnabled(),
                previousDate: nil,
                currentDate: currentLocalTime
            )
            completion(result)
            return
        }
        
        // Check if we should perform network-based detection
        if shouldPerformNetworkTimeCheck() {
            fetchInternetUTCTime { result in
                switch result {
                case .success(let internetTime):
                    lastNetworkCheckTime = Date()
                    analyzeChangesWithNetworkTime(currentTime: currentLocalTime,
                                                storedTime: storedTime,
                                                currentDateComponents: currentDateComponents,
                                                previousDateComponents: storedComponents,
                                                internetTime: internetTime,
                                                completion: completion)
                    
                case .failure(let error):
                    print("Failed to fetch internet time: \(error.localizedDescription)")
                    // Fallback to local analysis
                    analyzeChangesLocally(currentTime: currentLocalTime,
                                        storedTime: storedTime,
                                        currentDateComponents: currentDateComponents,
                                        previousDateComponents: storedComponents,
                                        completion: completion)
                }
            }
        } else {
            // Use local analysis to minimize network usage
            analyzeChangesLocally(currentTime: currentLocalTime,
                                storedTime: storedTime,
                                currentDateComponents: currentDateComponents,
                                previousDateComponents: storedComponents,
                                completion: completion)
        }
    }
    
    /**
     * Detects specifically if only the date has been changed while time remains similar
     * This is useful for detecting manual date changes when auto date/time is disabled
     *
     * @param completion Callback with date-only change detection result
     */
    static func detectDateOnlyChange(completion: @escaping (Bool) -> Void) {
        detectComprehensiveDateTimeChange { result in
            completion(result.changeType == .dateOnly)
        }
    }
    
    /**
     * Analyzes changes using network time as reference
     */
    private static func analyzeChangesWithNetworkTime(currentTime: Date,
                                                     storedTime: Date,
                                                     currentDateComponents: DateComponents,
                                                     previousDateComponents: DateComponents,
                                                     internetTime: Date,
                                                     completion: @escaping (DateTimeChangeResult) -> Void) {
        
        let expectedLocalTime = internetTime.addingTimeInterval(TimeInterval(TimeZone.current.secondsFromGMT()))
        let timeDifference = currentTime.timeIntervalSince(expectedLocalTime)
        
        // Check if date components have changed
        let dateChanged = (currentDateComponents.year != previousDateComponents.year ||
                          currentDateComponents.month != previousDateComponents.month ||
                          currentDateComponents.day != previousDateComponents.day)
        
        // Check if time has changed significantly (beyond normal progression)
        let timeChanged = abs(timeDifference) > timeChangeThreshold
        
        // Determine change type
        let changeType: DateTimeChangeType
        if dateChanged && timeChanged {
            changeType = .dateAndTime
        } else if dateChanged && !timeChanged {
            changeType = .dateOnly
        } else if !dateChanged && timeChanged {
            changeType = .timeOnly
        } else {
            changeType = .noChange
        }
        
        // Update stored values if changes detected
        if changeType != .noChange {
            storedTimestamp = currentTime
            storedDateComponents = currentDateComponents
            print("Network-based change detected - Type: \(changeType), Time diff: \(timeDifference)s")
        }
        
        let result = DateTimeChangeResult(
            changeType: changeType,
            timeDifference: timeDifference,
            dateChanged: dateChanged,
            timeChanged: timeChanged,
            isAutoDateTimeEnabled: isAutoDateTimeEnabled(),
            previousDate: storedTime,
            currentDate: currentTime
        )
        
        completion(result)
    }
    
    /**
     * Shows appropriate notifications based on detected changes
     */
    private static func showNotificationForChangeResult(_ result: DateTimeChangeResult) {
        // Only show notifications if changes are detected
        guard result.changeType != .noChange else { return }
        
        // Show specific notification based on change type
        switch result.changeType {
        case .dateOnly:
            NotificationManager.shared.showDateOnlyChangeNotification()
        case .timeOnly:
            NotificationManager.shared.showTimeOnlyChangeNotification()
        case .dateAndTime:
            NotificationManager.shared.showDateTimeChangeNotification()
        case .noChange:
            break
        }
        
        // Additionally show auto date/time disabled notification if applicable
        if !result.isAutoDateTimeEnabled {
            // Delay this notification slightly to avoid overwhelming the user
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                NotificationManager.shared.showAutoDateTimeDisabledNotification()
            }
        }
    }
    
    /**
     * Comprehensive date and time change detection with automatic notifications
     * This method combines detection with user notification for better UX
     */
    static func detectAndNotifyDateTimeChanges(completion: @escaping (DateTimeChangeResult) -> Void) {
        detectComprehensiveDateTimeChange { result in
            // Show notifications if changes detected
            showNotificationForChangeResult(result)
            
            // Return the result to the caller
            completion(result)
        }
    }
    
    /**
     * Analyzes changes using local time comparison (fallback method)
     */
    private static func analyzeChangesLocally(currentTime: Date,
                                            storedTime: Date,
                                            currentDateComponents: DateComponents,
                                            previousDateComponents: DateComponents,
                                            completion: @escaping (DateTimeChangeResult) -> Void) {
        
        let timeDifference = currentTime.timeIntervalSince(storedTime)
        
        // Check if date components have changed
        let dateChanged = (currentDateComponents.year != previousDateComponents.year ||
                          currentDateComponents.month != previousDateComponents.month ||
                          currentDateComponents.day != previousDateComponents.day)
        
        // For local analysis, we need to be more careful about time changes
        // Consider the expected time progression since last check
        let expectedTimeDifference = Date().timeIntervalSince(storedTime)
        let unexpectedTimeDifference = abs(timeDifference - expectedTimeDifference)
        let timeChanged = unexpectedTimeDifference > timeChangeThreshold
        
        // Determine change type
        let changeType: DateTimeChangeType
        if dateChanged && timeChanged {
            changeType = .dateAndTime
        } else if dateChanged && !timeChanged {
            changeType = .dateOnly
        } else if !dateChanged && timeChanged {
            changeType = .timeOnly
        } else {
            changeType = .noChange
        }
        
        // Update stored values if changes detected
        if changeType != .noChange {
            storedTimestamp = currentTime
            storedDateComponents = currentDateComponents
            print("Local change detected - Type: \(changeType), Time diff: \(timeDifference)s")
        }
        
        let result = DateTimeChangeResult(
            changeType: changeType,
            timeDifference: timeDifference,
            dateChanged: dateChanged,
            timeChanged: timeChanged,
            isAutoDateTimeEnabled: isAutoDateTimeEnabled(),
            previousDate: storedTime,
            currentDate: currentTime
        )
        
        completion(result)
    }
    
    // Cache for auto date/time status to avoid repeated network calls
    private static var cachedAutoDateTimeStatus: Bool?
    private static var lastStatusCheckTime: Date?
    private static let statusCacheInterval: TimeInterval = 30.0 // Cache for 30 seconds
    
    /**
     * Simple NTP-based check if automatic date/time is enabled (matches Flutter plugin behavior)
     * 
     * This method provides a simplified detection approach without caching or complex fallback logic.
     * It directly compares device time with NTP server time using a 30-second threshold.
     * 
     * Platform behavior:
     * - Fetches device time (UTC)
     * - Fetches NTP time from worldtimeapi.org
     * - Compares time difference
     * - Returns true if difference ≤ 30 seconds (auto time ON)
     * - Returns false if difference > 30 seconds or network fails (auto time OFF)
     * 
     * @param completion Callback with detection result
     */
    static func isAutoDateTimeEnabledSimple(completion: @escaping (Bool) -> Void) {
        // Get device time in UTC
        let deviceTimeUtc = Date()
        
        // Create URL request to NTP time server
        guard let url = URL(string: "https://worldtimeapi.org/api/timezone/Etc/UTC") else {
            // Conservative approach: return false if URL creation fails
            completion(false)
            return
        }
        
        var request = URLRequest(url: url)
        request.timeoutInterval = 5.0 // 5 second timeout
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            // Check for network errors
            if let error = error {
                print("Simple NTP check - Network error: \(error.localizedDescription)")
                // Conservative approach: return false on network failure (matching Flutter)
                completion(false)
                return
            }
            
            // Parse response data
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let unixTimeString = json["unixtime"] as? Double else {
                print("Simple NTP check - Failed to parse server response")
                // Conservative approach: return false on parse failure
                completion(false)
                return
            }
            
            // Get NTP time
            let ntpTimeUtc = Date(timeIntervalSince1970: unixTimeString)
            
            // Calculate time difference in seconds
            let timeDifferenceSeconds = abs(deviceTimeUtc.timeIntervalSince(ntpTimeUtc))
            
            // Simple threshold check: 30 seconds (matching Flutter plugin)
            let isAutoEnabled = timeDifferenceSeconds <= 30.0
            
            print("Simple NTP check - Time difference: \(timeDifferenceSeconds)s, Auto enabled: \(isAutoEnabled)")
            completion(isAutoEnabled)
        }
        
        task.resume()
    }
    
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
     * Compares device time with network time server (legacy synchronous version)
     * Uses a synchronous approach with timeout for reliability
     */
    private static func checkTimeWithNetworkServer() -> Bool {
        let semaphore = DispatchSemaphore(value: 0)
        var isAutoTimeEnabled = true // Default to true if network check fails
        
        // Create URL request to a reliable time server
        guard let url = URL(string: "https://worldtimeapi.org/api/timezone/Etc/UTC") else {
            return true // Fallback to true if URL creation fails
        }
        
        var request = URLRequest(url: url)
        request.timeoutInterval = 5.0 // 5 second timeout
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            defer { semaphore.signal() }
            
            // Check for network errors
            if let error = error {
                print("Network error checking time: \(error.localizedDescription)")
                return // Keep default value (true)
            }
            
            // Parse response data
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let unixTimeString = json["unixtime"] as? Double else {
                print("Failed to parse time server response")
                return // Keep default value (true)
            }
            
            // Compare server time with device time
            let serverTime = Date(timeIntervalSince1970: unixTimeString)
            let deviceTime = Date()
            let timeDifference = abs(deviceTime.timeIntervalSince(serverTime))
            
            // If time difference is more than 60 seconds, consider auto-time disabled
            // This threshold accounts for network latency and minor clock drift
            if timeDifference > 60.0 {
                isAutoTimeEnabled = false
                print("Time difference detected: \(timeDifference) seconds")
            }
        }
        
        task.resume()
        
        // Wait for network request to complete (with timeout)
        let timeoutResult = semaphore.wait(timeout: .now() + 6.0)
        
        if timeoutResult == .timedOut {
            print("Network time check timed out")
            task.cancel()
        }
        
        return isAutoTimeEnabled
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
     * Determines if a network time check should be performed based on battery optimization
     * @return true if network check should be performed, false otherwise
     */
    private static func shouldPerformNetworkTimeCheck() -> Bool {
        guard isNetworkAvailable else { return false }
        
        // Check if enough time has passed since last network check
        if let lastCheck = lastNetworkCheckTime {
            let timeSinceLastCheck = Date().timeIntervalSince(lastCheck)
            return timeSinceLastCheck >= networkCheckInterval
        }
        
        return true // First time check
    }
    
    /**
     * Detects time changes using local comparison (fallback method)
     * @param currentTime Current local time
     * @param storedTime Previously stored time
     * @return true if significant time change detected, false otherwise
     */
    private static func detectLocalTimeChange(currentTime: Date, storedTime: Date) -> Bool {
        let expectedTimeDifference = currentTime.timeIntervalSince(storedTime)
        
        // If the time difference is significantly different from expected (considering app lifecycle),
        // it might indicate a manual time change
        let processInfo = ProcessInfo.processInfo
        let systemUptime = processInfo.systemUptime
        
        // Simple heuristic: if time jumped more than expected based on system uptime
        if abs(expectedTimeDifference) > timeChangeThreshold {
            print("Local time change detected: \(expectedTimeDifference) seconds difference")
            storedTimestamp = currentTime
            return true
        }
        
        return false
    }
    
    /**
     * Updates the stored timestamp for future reference
     * @param newTimestamp New timestamp to store
     */
    static func updateStoredTimestamp(_ newTimestamp: Date) {
        storedTimestamp = newTimestamp
    }
    
    /**
     * Sets the stored timestamp and date components
     * @param newTimestamp New timestamp to store
     */
    static func setStoredTimestamp(_ newTimestamp: Date) {
        storedTimestamp = newTimestamp
        storedDateComponents = Calendar.current.dateComponents([.year, .month, .day], from: newTimestamp)
    }
    
    /**
     * Gets the currently stored timestamp
     * @return Stored timestamp or nil if not set
     */
    static func getStoredTimestamp() -> Date? {
        return storedTimestamp
    }
    
    /**
     * Resets the stored timestamp, date components, network check time, and status cache
     */
    static func reset() {
        storedTimestamp = nil
        storedDateComponents = nil
        lastNetworkCheckTime = nil
        cachedAutoDateTimeStatus = nil
        lastStatusCheckTime = nil
    }
    
    /**
     * Stops network monitoring to conserve battery
     */
    static func stopNetworkMonitoring() {
        networkMonitor.cancel()
    }
}
