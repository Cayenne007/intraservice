//
//  NetworkManager.swift
//  intraservice
//
//  Created by Cayenne on 19.11.2020.
//

import Foundation


class NetworkManager {
    
    static var shared = NetworkManager()
    
    var urlSession: URLSession = {
        let config = URLSessionConfiguration.default
        config.isDiscretionary = true
        config.sessionSendsLaunchEvents = true
        var session = URLSession(configuration: config)

        return session
    }()
    
    var backgroundUrlSession: URLSession = {
        let config = URLSessionConfiguration.background(withIdentifier: "com.task.refresh")
        config.sessionSendsLaunchEvents = true
        config.isDiscretionary = true
        config.allowsCellularAccess = true
        config.shouldUseExtendedBackgroundIdleMode = true
        config.waitsForConnectivity = true

        return URLSession(configuration: config, delegate: NetworkBackgroundManager(), delegateQueue: nil)
    }()
    
    private init() {}
    
    func fetchData(notify: @escaping (Int, Int)->(), _ completion: @escaping ()->()) {
        fetchService {
            self.fetchTaskStatus {
                self.fetchUsers(page: 1) {
                    self.fetchTask(page: 1, notify: notify) {
                        DispatchQueue.main.async {
                            completion()
                        }
                    }
                }
            }
        }
    }
    
        
    func fetchUsers(page: Int, _ completion: @escaping ()->()) {
        
        let url = "https://pivdom.intraservice.ru/api/user?fields=Id,Name&isArchive=false&pagesize=1000&page="
            + "\(page)"
        
        guard let request = getRequest(url: url) else { return }
        
        urlSession.dataTask(with: request) { data, response, error in
            
            guard error == nil, let data = data else {
                print(error!.localizedDescription)
                return
            }
                        
            JSON.decodeUsers(data, page: page, completion: completion)
            
        }.resume()
        
    }
    
    
    func fetchService(_ completion: @escaping ()->()) {
       
        let url = "https://pivdom.intraservice.ru/api/service"

        guard let request = getRequest(url: url) else { return }
        
        urlSession.dataTask(with: request) { data, response, error in
            
            guard error == nil, let data = data else {
                print(error!.localizedDescription)
                return
            }
                        
            JSON.decodeServices(data, completion: completion)
            
        }.resume()
        
    }
    
    func fetchTask(page: Int, notify: @escaping (Int,Int) -> (), completion: @escaping ()->()) {
        
        let url = "https://pivdom.intraservice.ru/api/task?fields=Id,Name,Description,Creator,CreatorId,CreatorEmail,Type,Created,Changed,DeadLine,StatusId,ServiceId,Executors,ExecutorIds,Observers,ObserverIds,Files,FileNames,FileIds&pagesize=1000&page="
            + "\(page)"
            + Filter.shared.url()
        
        
        guard let request = getRequest(url: url) else { return }
        
        urlSession.dataTask(with: request) { data, response, error in
            
            guard error == nil, let data = data else {
                print(error!.localizedDescription)
                return
            }
            
            JSON.decodeTasks(data, page: page, notify: notify, completion: completion)
                        
                        
        }.resume()
        
    }
    
    
    func fetchTaskFile(id: Int32, name: String, _ completion: @escaping (Data)->()) {
       
        let url = "https://pivdom.intraservice.ru/api/taskfile/\(id)"
        
        guard let request = getRequest(url: url) else {
            print("task file error")
            return
        }
        
        urlSession.dataTask(with: request) {data,response,error in
            
            guard error == nil, let data = data else {
                print(error!.localizedDescription)
                return
            }

            let file = StorageManager.shared.fetchCreate(TaskFile.self, id: id)
            file.id = id
            file.name = name
            file.data = data
            StorageManager.shared.saveContext()
            completion(data)


        }.resume()

    }
    
    func fetchTaskStatus(completion: @escaping ()->()) {
        
        let url = "https://pivdom.intraservice.ru/api/taskstatus"
        
        guard let request = getRequest(url: url) else {
            print("task file error")
            return
        }
        
        urlSession.dataTask(with: request) {data,response,error in
            
            guard error == nil, let data = data else {
                print(error!.localizedDescription)
                return
            }
            
            JSON.decodeTaskStatus(data, completion: completion)
            
        }.resume()
        
    }
    
    func getReport(_ completion: @escaping (URL?,String?)->()) {
        
        let url = AuthorizationManager.standart.reportsUrl
        let loginData = AuthorizationManager.standart.reportsLoginPass.data(using: String.Encoding.utf8)!
        let base64LoginString = loginData.base64EncodedString() //преобразование строки в base64
        
        let authorisation = "Basic \(base64LoginString)"
        

        let tasks = StorageManager.shared.fetch(Task.self, predicate: Filter.shared.predicate())

        let filterExecutors = Filter.shared.executors.trimmingCharacters(in: .whitespaces).array(by: ",")
        var array: [[String: String]] = []
        
        tasks.forEach { (task) in
            
            let executors = task.executorsText!.array(by: ",").map({$0.trimmingCharacters(in: .whitespaces)})
            
            if executors.count == 1, let executor = executors.first {
                array.append(createJSONTask(task, executor: executor.isEmpty ? "<Без исполнителя>" : executor))
            } else {
            
                for executor in executors {
                                    
                    for fEx in filterExecutors {
                        if executor.contains(fEx) {
                            array.append(createJSONTask(task, executor: executor))
                            break
                        }
                    }
                    
                }
            }
        }
        
        
        
        
        var resultDict: [String: Any] = [:]
        resultDict["period"] = Filter.shared.changedBeginDate.toString("dd.MM.yyyy")
            + " - "
            + Filter.shared.changedEndDate.toString("dd.MM.yyyy")
        
        resultDict["status"] = Filter.shared.statusString
        resultDict["executors"] = Filter.shared.executors.isEmpty ? "<Не выбрано>" : Filter.shared.executors
        resultDict["creatorExclude"] = Filter.shared.creatorExclude.isEmpty ? "<Не выбрано>" : Filter.shared.creatorExclude
        resultDict["data"] = array
        resultDict["count"] = StorageManager.shared.count(Filter.shared.predicate(filter: ""))
        
        let data = try? JSONSerialization.data(withJSONObject: resultDict, options: .fragmentsAllowed)
        
        var request = URLRequest(url: url)
        request.httpMethod = "put"
        request.setValue(authorisation, forHTTPHeaderField: "Authorization")
        request.setValue("getReport1C", forHTTPHeaderField: "Operation")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = data
        
        
                
        urlSession.dataTask(with: request) {data,response,error in

            guard error == nil, let data = data else {
                print(error!.localizedDescription)                
                return
            }
            
            if let error = String(data: data, encoding: .utf8) {
                completion(nil, error)
                return
            }
            
            let fileUrl = Files.documents.appendingPathComponent("report.xlsx")
            try? data.write(to: fileUrl)
                
            completion(fileUrl, nil)
            
        }.resume()
    }

    
    private func createJSONTask(_ task: Task, executor: String) -> [String: String] {
        let status = StorageManager.shared.fetchProperty(type: String.self, data: task, name: "status", property: "name")
        let json: [String: String] = ["id": "\(task.id)",
                                          "dateCreated": "\(task.created!)",
                                          "dateChanged": "\(task.changed!)",
                                          "status": "\(status!)",
                                          "creator": task.creator!,
                                          "executors": executor,
                                          "name": task.name!,
                                          "text": task.text!]
        return json
    }
    
    
    private func getRequest(url urlString: String,_ method: String = "Get",_ body: [String: Any]? = nil) -> URLRequest? {
        
        guard let url = URL(string: urlString) else {
            print("incorrect url: \(urlString)")
            return nil
        }
        
        var request = URLRequest(url: url)
        let base64 = AuthorizationManager.standart.loginPass.data(using: .utf8)!.base64EncodedString()
        request.setValue("Basic "+base64 , forHTTPHeaderField: "Authorization")
        
        request.httpMethod = method
        
        if let body = body {
            request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: .fragmentsAllowed)
        }
        
        return request
    }
    

    func startBackgroundTask(testMode: Bool = false) {
        
        fetchTaskBackround(testMode: testMode)
        
    }
    
    func fetchTaskBackround(testMode: Bool = false) {
        
        let url = "https://pivdom.intraservice.ru/api/task?fields=Id,Name,Description,Creator,CreatorId,CreatorEmail,Type,Created,Changed,DeadLine,StatusId,ServiceId,Executors,ExecutorIds,Observers,ObserverIds,Files,FileNames,FileIds&pagesize=1000&page="
            + "\(1)"
            + Filter.shared.url()
        
        
        guard let request = getRequest(url: url) else { return }
        
        let backgroundTask = backgroundUrlSession.downloadTask(with: request)
        
        if testMode {
            backgroundTask.earliestBeginDate = Date()
        } else {
            backgroundTask.earliestBeginDate = Date().addingTimeInterval(3 * 60)
        }
        
        backgroundTask.countOfBytesClientExpectsToSend = 200
        backgroundTask.countOfBytesClientExpectsToReceive = 500 * 1024
        backgroundTask.resume()
        
    }

    func stopBackgroundTasks() {
        backgroundUrlSession.getAllTasks { tasks in
            for task in tasks {
                task.cancel()
            }
        }

    }

    
}
