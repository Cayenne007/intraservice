//
//  JSONManager.swift
//  intraservice
//
//  Created by Cayenne on 04.12.2020.
//

import Foundation

struct JSON {
    
    static func decodeTasks(_ data: Data, page: Int, notify: @escaping (Int, Int) -> (), completion: @escaping () -> ()) {
        
        do {
            let jsonTasks = try JSONDecoder().decode(JSONTasks.self, from: data)
            
            notify(page, jsonTasks.paginator.pageCount)
            
            for task in jsonTasks.tasks {
                StorageManager.shared.createTask(task)
            }
            
            if jsonTasks.paginator.isLastPage(page) {
                completion()
                return
            }
            
        } catch {
            fatalError("\(error)")
        }
        
        NetworkManager.shared.fetchTask(page: page + 1, notify: notify, completion: completion)
        
        
    }
    
    static func decodeTasksBackground(_ data: Data,_ completion: @escaping () -> ()) {
        
        do {
            let jsonTasks = try JSONDecoder().decode(JSONTasks.self, from: data)
            for task in jsonTasks.tasks {
                StorageManager.shared.createTask(task, StorageManager.shared.container.newBackgroundContext())
            }
        } catch {
            fatalError("\(error)")
        }
            
        completion()
        
    }
    
    static func decodeUsers(_ data: Data, page: Int, completion: @escaping () -> ()) {
                
        do {
            let jsonUsers = try JSONDecoder().decode(JSONUsers.self, from: data)
            for user in jsonUsers.users {
                StorageManager.shared.createUser(user)
            }
                
            if jsonUsers.paginator.isLastPage(page) {
                completion()
                return
            }
            
        } catch {
            fatalError("\(error)")
        }
        
        NetworkManager.shared.fetchUsers(page: page + 1, completion)
        
    }
    
    static func decodeServices(_ data: Data, completion: @escaping ()->()) {
        
        do {
            let jsonServices = try JSONDecoder().decode(JSONServices.self, from: data)
            
            for service in jsonServices.services {
                StorageManager.shared.createService(service)
            }
        } catch {
            fatalError("\(error)")
        }
            
        completion()
        
    }
    
    static func decodeTaskStatus(_ data: Data, completion: @escaping ()->()) {
        
        do {
            let jsonTaskStatus = try JSONDecoder().decode([JSONTaskStatus].self, from: data)
        
            for status in jsonTaskStatus {
                StorageManager.shared.createTaskStatus(status)
            }
        } catch {
            fatalError("\(error)")
        }
            
        completion()
        
    }

    
    
    
    
}
    

