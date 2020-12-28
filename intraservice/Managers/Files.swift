//
//  FileManager.swift
//  intraservice
//
//  Created by Cayenne on 07.12.2020.
//

import Foundation

struct Files {
    
    static var documents: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    
    static var authorizationFile: URL {
        Files.documents.appendingPathComponent("authorization.json")
    }
    
    static func newTempFile(name: String) -> URL {
        FileManager.default.temporaryDirectory.appendingPathComponent(name)
    }
    
    static func isExists(url: URL) -> Bool {
        FileManager.default.fileExists(atPath: url.description)
    }
    
    static func loadFiles(_ task: Task, _ completion: @escaping ([TaskFile])->()) {
        
        guard let ids = task.fileIds, !ids.isEmpty else { return }
        
        if let files = StorageManager.shared.fetch(TaskFile.self, ids: ids),
           files.count > 0 {
            completion(files)
        } else {
            guard let names = task.fileNames?.array(by: ",") else { return }
            let files = ids.array(by: ",")
            
            for i in 0...files.count - 1 {
                let file = files[i]
                let id = Int32(file)!
                let name = names[i]
                NetworkManager.shared.fetchTaskFile(id: id, name: name) { _ in
                    if let files = StorageManager.shared.fetch(TaskFile.self, ids: task.fileIds!) {
                        completion(files)
                    }
                }
            }
        }
        
    }
    
}
