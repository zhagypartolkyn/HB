

import UIKit
import Firebase
import GooglePlaces
import GoogleSignIn
import IQKeyboardManager

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    // MARK: - Variables
    var window: UIWindow?
    var appCoordinator: AppCoordinator!
    
    let gcmMessageIDKey = "gcm.message_id"
    static var isToken: String?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        
        IQKeyboardManager.shared().isEnabled = true
        IQKeyboardManager.shared().isEnableAutoToolbar = false
        IQKeyboardManager.shared().shouldResignOnTouchOutside = true
        
        IQKeyboardManager.shared().enabledToolbarClasses.add(SignUpViewController.self)
        IQKeyboardManager.shared().enabledToolbarClasses.add(SignEmailViewController.self)
        IQKeyboardManager.shared().enabledToolbarClasses.add(EditProfileViewController.self)
        
        // TOKEN
        Messaging.messaging().token { (token, error) in
            if let error = error {
                print("Error fetching remote instange ID: \(error)")
            } else if let token = token {
                print("Remote instance ID token: \(token)")
                AppDelegate.isToken = token
            }
        }
        
        UNUserNotificationCenter.current().delegate = self
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions, completionHandler: {_, _ in })
        
        if let isPushEnabled = UserDefaults.standard.object(forKey: "push") {
            if isPushEnabled as! Bool {
                UIApplication.shared.registerForRemoteNotifications()
            } else {
                UIApplication.shared.unregisterForRemoteNotifications()
            }
        } else {
            UIApplication.shared.registerForRemoteNotifications()
        }
        
        // [START set_messaging_delegate]
        Messaging.messaging().delegate = self
        // [END set_messaging_delegate]
        
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        GMSPlacesClient.provideAPIKey("AIzaSyAIaIwqo8rkxZVVWS3rDQoTXOdAXP0sHKY")
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

}

extension AppDelegate {
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID 1: \(messageID)")
        }
        
        // Print full message.
        print(userInfo)
    }
    
    // [START receive_message]
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID 2: \(messageID)")
        }
        
        // Print full message.
        // print(userInfo)
        
        completionHandler(UIBackgroundFetchResult.newData)
    }
    // [END receive_message]
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Unable to register for remote notifications: \(error.localizedDescription)")
    }
    
    // This function is added here only for debugging purposes, and can be removed if swizzling is enabled.
    // If swizzling is disabled then this function must be implemented so that the APNs token can be paired to
    // the FCM registration token.
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("APNs token retrieved: \(deviceToken)")
        
        // With swizzling disabled you must set the APNs token here.
        // Messaging.messaging().apnsToken = deviceToken
    }
}

// [START ios_10_message_handling]
extension AppDelegate : UNUserNotificationCenterDelegate {
    
    // Receive displayed notifications for iOS 10 devices.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID 3: \(messageID)")
        }
        
        // Print full message.
        // print(userInfo)
        
        let isPushEnabled = UserDefaults.standard.bool(forKey: "push")
        
        // Change this to your preferred presentation option
        if isPushEnabled {
            completionHandler([[.alert, .sound]])
        } else {
            completionHandler([])
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID 4: \(messageID)")
        }
        
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        // Print full message.
        
        // If app is active
        if let type = userInfo["type"] as? String,
           let linkId = userInfo["linkId"] as? String,
           let pushType = PushType(rawValue: type) {
            
            let data = PushData(type: pushType, linkId: linkId)

            if let initialCoordinator = appCoordinator.childCoordinators[0] as? InitialCoordinator {
                if !initialCoordinator.childCoordinators.isEmpty {
                    if let tabbarCoorinator = initialCoordinator.childCoordinators[0] as? TabBarCoordinator {
                        tabbarCoorinator.openPush(data)
                    }
                }
            }
        }
        
        completionHandler()
    }
    
    func getCurrentVC() -> UIViewController? {
        if let initialCoordinator = appCoordinator.childCoordinators[0] as? InitialCoordinator {
            if !initialCoordinator.childCoordinators.isEmpty {
                if let tabbarCoorinator = initialCoordinator.childCoordinators[0] as? TabBarCoordinator {
                    return tabbarCoorinator.currentVC()
                } else { return nil }
            } else { return nil }
        } else { return nil }
    }
}
// [END ios_10_message_handling]

extension AppDelegate : MessagingDelegate {
    // [START refresh_token]
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        // print("Firebase registration token: \(String(describing: fcmToken))")
        
        let dataDict:[String: String] = ["token": fcmToken]
        NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
        // TODO: If necessary send token to application server.
        // Note: This callback is fired at each app startup and whenever a new token is generated.
    }
    // [END refresh_token]
}
