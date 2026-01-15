import Foundation
import UserNotifications
import UIKit

/**
 * NotificationManager handles displaying notifications for date/time change detection
 * Supports iOS 10+ with UserNotifications framework and fallback for older versions
 */
class NotificationManager: NSObject {
    
    static let shared = NotificationManager()
    
    private override init() {
        super.init()
    }
    
    /**
     * Requests notification permission from the user
     * Should be called during app initialization
     */
    func requestNotificationPermission(completion: @escaping (Bool) -> Void) {
        if #available(iOS 10.0, *) {
            let center = UNUserNotificationCenter.current()
            center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                DispatchQueue.main.async {
                    if let error = error {
                        print("Notification permission error: \(error.localizedDescription)")
                        completion(false)
                    } else {
                        completion(granted)
                    }
                }
            }
        } else {
            // Fallback for iOS 9 and earlier
            let settings = UIUserNotificationSettings(types: [.alert, .sound, .badge], categories: nil)
            UIApplication.shared.registerUserNotificationSettings(settings)
            completion(true)
        }
    }
    
    /**
     * Displays a notification when automatic date/time is disabled
     */
    func showAutoDateTimeDisabledNotification() {
        let title = "Automatic Date & Time Disabled"
        let body = "Your device's automatic date and time setting appears to be disabled. Please enable it in Settings > General > Date & Time for accurate time synchronization."
        
        showNotification(title: title, body: body, identifier: "auto_datetime_disabled")
    }
    
    /**
     * Displays a notification when date-only change is detected
     */
    func showDateOnlyChangeNotification() {
        let title = "Date Change Detected"
        let body = "The date has been manually changed while the time remained unchanged. This may indicate that automatic date and time is disabled."
        
        showNotification(title: title, body: body, identifier: "date_only_change")
    }
    
    /**
     * Displays a notification when time-only change is detected
     */
    func showTimeOnlyChangeNotification() {
        let title = "Time Change Detected"
        let body = "The time has been manually changed. This may indicate that automatic date and time is disabled."
        
        showNotification(title: title, body: body, identifier: "time_only_change")
    }
    
    /**
     * Displays a notification when both date and time changes are detected
     */
    func showDateTimeChangeNotification() {
        let title = "Date & Time Change Detected"
        let body = "Both date and time have been manually changed. Please ensure automatic date and time is enabled for accurate synchronization."
        
        showNotification(title: title, body: body, identifier: "datetime_change")
    }
    
    /**
     * Displays a custom notification with specified parameters
     */
    func showCustomNotification(title: String, body: String, identifier: String? = nil) {
        let notificationId = identifier ?? "custom_notification_\(Date().timeIntervalSince1970)"
        showNotification(title: title, body: body, identifier: notificationId)
    }
    
    /**
     * Core notification display method that handles iOS version compatibility
     */
    private func showNotification(title: String, body: String, identifier: String) {
        if #available(iOS 10.0, *) {
            showModernNotification(title: title, body: body, identifier: identifier)
        } else {
            showLegacyNotification(title: title, body: body)
        }
    }
    
    /**
     * Shows notification using UserNotifications framework (iOS 10+)
     */
    @available(iOS 10.0, *)
    private func showModernNotification(title: String, body: String, identifier: String) {
        let center = UNUserNotificationCenter.current()
        
        // Check if notifications are authorized
        center.getNotificationSettings { settings in
            guard settings.authorizationStatus == .authorized else {
                print("Notifications not authorized")
                return
            }
            
            // Create notification content
            let content = UNMutableNotificationContent()
            content.title = title
            content.body = body
            content.sound = .default
            content.badge = NSNumber(value: UIApplication.shared.applicationIconBadgeNumber + 1)
            
            // Create trigger (immediate delivery)
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
            
            // Create request
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
            
            // Schedule notification
            center.add(request) { error in
                if let error = error {
                    print("Failed to schedule notification: \(error.localizedDescription)")
                } else {
                    print("Notification scheduled successfully: \(title)")
                }
            }
        }
    }
    
    /**
     * Shows notification using legacy UILocalNotification (iOS 9 and earlier)
     */
    private func showLegacyNotification(title: String, body: String) {
        DispatchQueue.main.async {
            if #available(iOS 8.0, *) {
                let notification = UILocalNotification()
                notification.alertTitle = title
                notification.alertBody = body
                notification.soundName = UILocalNotificationDefaultSoundName
                notification.applicationIconBadgeNumber = UIApplication.shared.applicationIconBadgeNumber + 1
                notification.fireDate = Date(timeIntervalSinceNow: 0.1)
                
                UIApplication.shared.scheduleLocalNotification(notification)
                print("Legacy notification scheduled: \(title)")
            } else {
                // For iOS 7 and earlier, show an alert
                let alert = UIAlertView(title: title, message: body, delegate: nil, cancelButtonTitle: "OK")
                alert.show()
                print("Alert shown for iOS 7: \(title)")
            }
        }
    }
    
    /**
     * Cancels all pending notifications
     */
    func cancelAllNotifications() {
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
            UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        } else {
            UIApplication.shared.cancelAllLocalNotifications()
        }
        
        // Reset badge count
        DispatchQueue.main.async {
            UIApplication.shared.applicationIconBadgeNumber = 0
        }
    }
    
    /**
     * Cancels notifications with specific identifier
     */
    func cancelNotification(withIdentifier identifier: String) {
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
            UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [identifier])
        } else {
            // For legacy notifications, we need to cancel all and reschedule others
            // This is a limitation of the older notification system
            let scheduledNotifications = UIApplication.shared.scheduledLocalNotifications ?? []
            for notification in scheduledNotifications {
                if notification.userInfo?["identifier"] as? String == identifier {
                    UIApplication.shared.cancelLocalNotification(notification)
                }
            }
        }
    }
    
    /**
     * Checks current notification authorization status
     */
    func checkNotificationPermission(completion: @escaping (Bool) -> Void) {
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().getNotificationSettings { settings in
                DispatchQueue.main.async {
                    completion(settings.authorizationStatus == .authorized)
                }
            }
        } else {
            // For older iOS versions, check if notification types are enabled
            let settings = UIApplication.shared.currentUserNotificationSettings
            completion(settings?.types != [])
        }
    }
}

// MARK: - UNUserNotificationCenterDelegate

@available(iOS 10.0, *)
extension NotificationManager: UNUserNotificationCenterDelegate {
    
    /**
     * Handle notification when app is in foreground
     */
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                              willPresent notification: UNNotification,
                              withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Show notification even when app is in foreground
        if #available(iOS 14.0, *) {
            completionHandler([.banner, .sound, .badge])
        } else {
            completionHandler([.alert, .sound, .badge])
        }
    }
    
    /**
     * Handle notification tap
     */
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                              didReceive response: UNNotificationResponse,
                              withCompletionHandler completionHandler: @escaping () -> Void) {
        let identifier = response.notification.request.identifier
        print("Notification tapped: \(identifier)")
        
        // Handle specific notification actions here if needed
        switch identifier {
        case "auto_datetime_disabled":
            // Could open settings or show more information
            break
        case "date_only_change", "time_only_change", "datetime_change":
            // Could show detailed change information
            break
        default:
            break
        }
        
        completionHandler()
    }
}