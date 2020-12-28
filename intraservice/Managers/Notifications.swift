//
//  Notifications.swift
//  intraservice
//
//  Created by Cayenne on 13.12.2020.
//

import UIKit
import UserNotifications

struct Notifications {
        
    static func sendNotification(title: String, body: String, id: Int32? = nil) {
        
        if !Filter.shared.newTaskNotification {
            return
        }
        
        let notificationContent = UNMutableNotificationContent()
        
        notificationContent.title = title
        notificationContent.subtitle = ""
        notificationContent.body = body
        notificationContent.sound = UNNotificationSound.default
        
        if let id = id {
            notificationContent.userInfo = ["id": id]
        }
        
        //let attachment = try! UNNotificationAttachment(identifier: "eye", url: <#T##URL#>, options: <#T##[AnyHashable : Any]?#>)
            
        
        
        // Add Trigger
        //let notificationTrigger = UNTimeIntervalNotificationTrigger(timeInterval: 10.0, repeats: false)
        
        // Create Notification Request
        let notificationRequest = UNNotificationRequest(identifier: UUID().uuidString, content: notificationContent, trigger: nil)
        
        DispatchQueue.main.async {
        
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.notificationCenter.add(notificationRequest) { (error) in
                if let error = error {
                    print("Unable to Add Notification Request (\(error), \(error.localizedDescription))")
                }
            }
        }
    }
    
    static func updateTaskList() {
        
        NotificationCenter.default.post(name: .refresh,
                                        object: self,
                                        userInfo: ["result": true])
        
    }
    
}



extension Notification.Name {
    static let refresh = Notification.Name("com.task.refresh")
}
