//
//  NetworkBackgroundManager.swift
//  intraservice
//
//  Created by user184795 on 22.12.2020.
//

import UIKit

class NetworkBackgroundManager: NSObject, URLSessionDelegate, URLSessionDownloadDelegate {
   
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        DispatchQueue.main.async {
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate,
                  let backgroundCompletionHandler =
                    appDelegate.backgroundCompletionHandler else {
                return
            }
            appDelegate.backgroundCompletionHandler = nil
            backgroundCompletionHandler()
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        guard let data = try? Data(contentsOf: location) else { return }
        JSON.decodeTasksBackground(data) {
            
            Notifications.updateTaskList()
            Logger.log(text: "tasks complete")
            NetworkManager.shared.startBackgroundTask()
            
        }
    }
    
    
}
