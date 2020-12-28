//
//  DataSource.swift
//  intraservice
//
//  Created by Vladlen Sukhov on 26.12.2020.
//

import CoreData

class DataSource {
    
    static var shared = DataSource()
    
    var tasks: NSFetchedResultsController = NSFetchedResultsController<Task>()
    
    var sections: [NSFetchedResultsSectionInfo] {
        guard let sections = tasks.sections else { return []}
        return Filter.shared.searchType.isEmpty ? sections : sections.sorted{$0.numberOfObjects > $1.numberOfObjects}
    }

    var rows: [Task] {
        tasks.fetchedObjects ?? []
    }
    
    
    private init() {}
    
    func task(indexPath: IndexPath) -> Task? {
        let section = sections[indexPath.section]
        
        guard let task = section.objects?[indexPath.row] else { return nil }
        return task as? Task
    }
    
    func sectionName(section: Int) -> String {
        guard !Filter.shared.searchType.isEmpty else { return "" }
        
        let section = sections[section]
        
        if section.name.isEmpty {
            if Filter.shared.searchType == "executorsText" {
                return "Без исполнителя (\(section.numberOfObjects))"
            } else {
                return ""
            }
        } else {
            return "\(section.name) (\(section.numberOfObjects))"
        }
    }
    
    func reloadData(_ competion: @escaping ()->()) {
        
        
        let fetchRequest = NSFetchRequest<Task>(entityName: "Task")
        
        let firstSortDescriptor = "created"
        
        let dateSortDescriptor = NSSortDescriptor(key: firstSortDescriptor, ascending: false)
        
        if Filter.shared.searchType.isEmpty {
            fetchRequest.sortDescriptors = [dateSortDescriptor]
        } else {
            let sortDescriptor = NSSortDescriptor(key: Filter.shared.searchType, ascending: true)
            fetchRequest.sortDescriptors = [sortDescriptor, dateSortDescriptor]
        }
        
        if let predicate = Filter.shared.predicate() {
            fetchRequest.predicate = predicate
        }
        
        tasks = NSFetchedResultsController(fetchRequest: fetchRequest,
                                           managedObjectContext: StorageManager.shared.context,
                                           sectionNameKeyPath: Filter.shared.searchType.isEmpty ? nil : Filter.shared.searchType,
                                           cacheName: nil)
        
        DispatchQueue.global().async {
            do {
                try self.tasks.performFetch()
            } catch let error as NSError {
                print(error.userInfo)
            }
           
            DispatchQueue.main.async {
                competion()
            }
            
        }
        
    }
    
}
