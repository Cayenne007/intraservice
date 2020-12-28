//
//  StorageManager.swift
//  Intraservice
//
//  Created by Cayenne on 28.11.2020.
//

import CoreData
import UIKit

class StorageManager {
    
    
    static var shared = StorageManager()
    
    var context: NSManagedObjectContext!
    var container: NSPersistentContainer!
    
    private init() {
        
        container = NSPersistentContainer(name: "Intraservice")
        let storeDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let url = storeDirectory.appendingPathComponent("Intraservice.sqlite")
        
        let description = NSPersistentStoreDescription(url: url)
        description.shouldInferMappingModelAutomatically = true
        description.shouldMigrateStoreAutomatically = true
        container.persistentStoreDescriptions = [description]
        
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        
        context = container.viewContext
        context.mergePolicy = NSMergePolicy(merge: .mergeByPropertyObjectTrumpMergePolicyType)
    
    }
    
    
    func saveContext() {
          
        do {
            if context.hasChanges {
                try context.save()
                Notifications.updateTaskList()
            }
        } catch let error as NSError {
            print(error.userInfo)            
            fatalError()
        }
    
    
    }
        
    
    
    func createUser(_ json: JSONUser) {
    
        let user = User(context: context)
                
        user.id = json.id
        user.name = json.name        
    
    }
    
    func createService(_ json: JSONService) {
        
        let service = Service(context: context)
        
        service.id = json.id
        service.name = json.name
        
    }
    
    func createTaskStatus(_ json: JSONTaskStatus) {
        
        let taskStatus = TaskStatus(context: context)
                
        taskStatus.id = json.id
        taskStatus.name = json.name
        
    }
    

    
    func createTask(_ json: JSONTask,_ context: NSManagedObjectContext? = nil) {
        
        let id = json.id
        let executorIds = json.executorIDS
        let creatorId = json.creatorID
        
        let needsToNotify = Filter.shared.executorsContaints(ids: executorIds) && !Filter.shared.creatorExcludeConstaints(id: creatorId)
        
//        if let task = StorageManager.shared.fetch(Task.self, id: id, context) {
//            updateTask(json, task, false)
//        } else {
            let task = Task(context: context ?? StorageManager.shared.context)
            task.id = id
            updateTask(json, task, needsToNotify)
//        }
        
    }

    private func updateTask(_ json: JSONTask, _ task: Task,_ notify: Bool) {
        
        task.idString   = String(json.id)
        task.name       = json.name
        task.text       = json.taskDescription ?? ""
        task.creator    = json.creator
        task.type       = json.type
        task.created    = json.created.toDate()
        task.changed    = json.changed.toDate()
        task.statusId   = json.statusID
        task.serviceId  = json.serviceID
        //task.creatorEmail   = json.crea
        task.notificated = true
        
        task.executorsText = json.executors
        task.executorIds = json.executorIDS
        task.observersText = json.observers
        task.observerIds = json.observerIDS
        
        task.fileNames = json.files
        task.fileIds = json.fileIDS
        
        if notify {
            Notifications.sendNotification(title: "Заявка №\(task.id) \(task.creator!)", body: task.name!, id: task.id)
        }
        
    }
    
    
    
    
    func count(_ predicate: NSPredicate? = nil) -> Int {
        
        let request = NSFetchRequest<Task>(entityName: "Task")
        request.propertiesToFetch = ["id"]
        request.returnsDistinctResults = true
        if let predicate = predicate {
            request.predicate = predicate
        }
        do {
            let result = try StorageManager.shared.context.count(for: request)
            return result
            
        } catch {
            return 0
        }

    }
    
    
    func isExists<T: NSManagedObject>(_ entite: T.Type, id: Int32) -> Bool {

        let fetchRequest = NSFetchRequest<T>(entityName: NSStringFromClass(T.self))
        
        fetchRequest.fetchLimit =  1
        fetchRequest.predicate = NSPredicate(format: "id == %i" ,id)
        

        do {
            let count = try context.count(for: fetchRequest)
            if count > 0 {
                return true
            }else {
                return false
            }
        }catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
            return false
        }
    }
    
    
    func fetch<T: NSManagedObject>(_ entite: T.Type, ids: String) -> [T]? {

        let fetchRequest = NSFetchRequest<T>(entityName: NSStringFromClass(T.self))
        
        if ids.isEmpty {
            
        } else {
            let array = ids.arrayInt32(by: ",")
            fetchRequest.predicate = NSPredicate(format: "id IN %@" , array)
        }
        
        do {
            return try context.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
            return nil
        }
        
    }
    
    func fetch<T: NSManagedObject>(_ entite: T.Type, predicate: NSPredicate? = nil) -> [T] {

        let fetchRequest = NSFetchRequest<T>(entityName: NSStringFromClass(T.self))
        
        if let predicate = predicate {
            fetchRequest.predicate = predicate
        }
        
        do {
            return try context.fetch(fetchRequest) 
        }catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
            return []
    }
        
    }
    
    func fetch<T: NSManagedObject>(_ entite: T.Type, id: Int32,_ currentContext: NSManagedObjectContext? = nil) -> T? {

        let fetchRequest = NSFetchRequest<T>(entityName: NSStringFromClass(T.self))
        //let predicate = NSPredicate(format: "id = @i", id)
        let predicate = NSPredicate(format: "id == %i", id)
        
        fetchRequest.predicate = predicate//NSPredicate(format: "id = @i", id)
        
        
        
        do {
            let result = try (currentContext ?? context).fetch(fetchRequest)
        return result.count == 0 ? nil : result.first
        }catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
            return nil
        }
        
    }
    
    
    func fetchCreate<T: NSManagedObject>(_ entite: T.Type, id: Int32) -> T {

        let fetchRequest = NSFetchRequest<T>(entityName: NSStringFromClass(T.self))
        
        fetchRequest.predicate = NSPredicate(format: "id = %i" , id)
        
        do {
            if let result = try context.fetch(fetchRequest).first {
                return result
            } else {
                return T(context: context)
            }
        }catch let error as NSError {
            fatalError("Could not fetch. \(error), \(error.userInfo)")            
        }
        
    }
    
    func fetchUsers(name: String) -> String {

        let names = name.array(by: ",")
        var result = ""
        
        for name in names {
        
            let fetchRequest = NSFetchRequest<User>(entityName: "User")
            
            fetchRequest.predicate = NSPredicate(format: "name CONTAINS[c] '\(name.lowercased())'")
            
            do {
                let results = try context.fetch(fetchRequest)
                for element in results {
                    result += (result.isEmpty ? "" : ",") + "\(element.id)"
                }
            } catch let error as NSError {
                print("Could not fetch. \(error), \(error.userInfo)")
                continue
            }
            
        }
             
        return result
        
    }
    
    func fetchUsersIds(names: String) -> [Int32] {

        let array = names.array(by: ",")
        var result: [Int32] = []
        
        for element in array {
        
            let fetchRequest = NSFetchRequest<User>(entityName: "User")
            
            fetchRequest.predicate = NSPredicate(format: "name CONTAINS[c] '\(element.lowercased())'")
            
            do {
                try context.fetch(fetchRequest).forEach{result.append($0.id)}

            } catch let error as NSError {
                print("Could not fetch. \(error), \(error.userInfo)")
                continue
            }
            
        }
             
        return result
        
    }


    func fetchAllStatus() -> [TaskStatus] {
        let request = NSFetchRequest<TaskStatus>(entityName: "TaskStatus")
        return (try? context.fetch(request)) ?? []
    }
    
    
    func fetchProperty<T>(type: T.Type, data: NSManagedObject, name: String, property: String) -> T? {
        context.refresh(data, mergeChanges: true)
        if let result = data.value(forKey: name) as? [TaskStatus],
           let obj = result.first {
            return obj.value(forKey: property) as? T
        } else {
            return nil
        }
    }
    
    func statusDescriptions() -> [Int32: String] {
        var data: [Int32: String] = [:]
        
        let fetch = NSFetchRequest<TaskStatus>(entityName: "TaskStatus")
        do {
            let objects = try context.fetch(fetch)
            for obj in objects {
                data[obj.id] = obj.name
            }
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        return data
    }
    
    
    func fetchTasksToNotificate(_ completion: (Task) -> () ) {
        
        guard Filter.shared.newTaskNotification else { return }
        
        let predicate = Filter.shared.predicate(filter: "notificated = false")
        
        let request = NSFetchRequest<Task>(entityName: "Task")
        request.predicate = predicate
        
        guard let objects = try? context.fetch(request) else { return }
                
        for object in objects {
            Notifications.sendNotification(title: "Заявка №\(object.id) \(object.creator!)", body: object.name!, id: object.id)
            object.notificated = true
        }
        
        if objects.count > 0 {
            do {
                try context.save()
            } catch let error as NSError {
                print(error.userInfo)
            }
        }
        
    }
    
}

