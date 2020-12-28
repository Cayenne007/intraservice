//
//  AppDelegate.swift
//  intraservice
//
//  Created by Cayenne on 19.11.2020.
//

import UIKit
import UserNotifications

import BackgroundTasks

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    let notificationCenter = UNUserNotificationCenter.current()
    var backgroundCompletionHandler: (()->())?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        notificationCenter.requestAuthorization(options: [.alert, .sound]) {
            granded, error in
            self.notificationCenter.delegate = self
        }
        
        return true
    }
    
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.sound, .banner, .list])
    }
    
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        guard let rootViewController = (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.window?.rootViewController else {
            return
        }
        
        guard let userInfo = response.notification.request.content.userInfo as? [String: Int32],
              let id = userInfo["id"],
              let task = StorageManager.shared.fetch(Task.self, id: id) else { return }
        

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        if let conversationVC = storyboard.instantiateViewController(withIdentifier: "taskView") as? TaskViewController,
           let tabBarController = rootViewController as? UITabBarController,
           let navController = tabBarController.selectedViewController as? UINavigationController {
            
            conversationVC.task = task
            navController.pushViewController(conversationVC, animated: true)
            
        }
        
        // tell the app that we have finished processing the user’s action / response
        completionHandler()
    }
    
    func application(_ application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: @escaping () -> Void) {
        
        backgroundCompletionHandler = completionHandler
        
    }
    
}
