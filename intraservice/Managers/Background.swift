//
//  BG.swift
//  intraservice
//
//  Created by Cayenne on 17.12.2020.
//

import BackgroundTasks

struct Background {
    
    static func startBackgroundTask() {
        
    }
    
    static func schedulerRegister() {
        
        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: "com.task.refresh",
            using: DispatchQueue.global()) { (task) in
            Background.handleAppRefreshTask(task: task as! BGAppRefreshTask)
            Logger.log(text: "bg refresh task registered")
        }
        
        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: "com.task.processing",
            using: DispatchQueue.global()) { (task) in
            Background.handleAppProcessingTask(task: task as! BGProcessingTask)
            Logger.log(text: "bg processing task registered")
        }
    }
    
    
    static func handleAppRefreshTask(task: BGAppRefreshTask) {
        
        task.expirationHandler = {
            task.setTaskCompleted(success: false)
            NetworkManager.shared.urlSession.invalidateAndCancel()
            Logger.log(text: "bg refresh timer is end")
        }
        
        Logger.log(text: "refresh task fetch ...")
        NetworkManager.shared.fetchTask(page: 1) { (_, _) in
            
        } completion: {
            task.setTaskCompleted(success: true)
            Logger.log(text: "refresh task completed")
        }

        Background.scheduleBackgroundFetchRefreshing()
    }
    
    static func handleAppProcessingTask(task: BGProcessingTask) {
        
        task.expirationHandler = {
            task.setTaskCompleted(success: false)
            NetworkManager.shared.urlSession.invalidateAndCancel()
            Logger.log(text: "bg processing timer is end")
        }
        
        Logger.log(text: "processing task fetch ...")
        NetworkManager.shared.fetchTask(page: 1) { (_, _) in
            
        } completion: {
            task.setTaskCompleted(success: true)
            Notifications.sendNotification(title: "Загрузка задач", body: "Успешно загружено")
            Logger.log(text: "processing task completed")
        }
        
        Background.scheduleBackgroundFetchProcessing()
        
//        task.expirationHandler = {
//            task.setTaskCompleted(success: false)
//            NetworkManager.shared.urlSession.invalidateAndCancel()
//            Logger.log(text: "background task stopped with error")
//        }
//
//        do {
//            try NetworkManager.shared.fetchTaskBackground(page: 1) {
//
//                Notifications.sendNotification(title: "Загрузка задач", body: "Успешно выполнено", id: 0)
//                Notifications.updateTaskList()
//
//                task.setTaskCompleted(success: true)
//                Logger.log(text: "background task sucess")
//
//            }
//        } catch {
//            task.setTaskCompleted(success: false)
//            Notifications.sendNotification(title: "Ошибка", body: "Задаие выполнилось с ошибкой", id: 0)
//            Logger.log(text: "background task error executing")
//        }
        
    }

    
    static func scheduleBackgroundFetchRefreshing() {
        
        let request = BGAppRefreshTaskRequest(identifier: "com.task.refresh")
        request.earliestBeginDate = Date(timeIntervalSinceNow: 60 * 1)
        
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print("Unable to submit task: \(error.localizedDescription)")
            Logger.log(text: "\((error as NSError).userInfo)")
        }
        
        
    }
    
    static func scheduleBackgroundFetchProcessing() {
        
        let request = BGAppRefreshTaskRequest(identifier: "com.task.processing")
        request.earliestBeginDate = Date(timeIntervalSinceNow: 60 * 5)
        
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print("Unable to submit task: \(error.localizedDescription)")
            Logger.log(text: "\((error as NSError).userInfo)")
        }
        
        
    }
    

    
}

