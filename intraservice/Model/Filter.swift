//
//  Filter.swift
//  intraservice
//
//  Created by Cayenne on 06.12.2020.
//

import Foundation

class Filter: Codable {
    
    static var shared = Filter()
    
    var dateIsActive = false
    var beginDate = Date()
    var endDate = Date()
    
    var changedDateIsActive = false
    var changedBeginDate = Date()
    var changedEndDate = Date()
    
    var status: [FilterStatus: Bool] = [:]
    var statusString: String {
        status.filter(\.value).map(\.key.textRU).joined(separator: ", ")
    }
    var executors = ""
    var services: String?
    var creatorExclude = ""
    
    var searchText = ""
    var searchType = ""
    
    var newTaskNotification = false
    var pushToken = ""
    
    
    var executorsIds: [Int32] {
        StorageManager.shared.fetchUsersIds(names: executors)
    }
    
    var settingsLoaded = false
    
    private init() {
        
        let loadedSettings = AppSettingsManager.loadSettings()
        
        if let _ = loadedSettings {
            settingsLoaded = true
        }
        
        services = loadedSettings?.services ?? ""
        executors = loadedSettings?.executors ?? ""
        creatorExclude = loadedSettings?.creatorExclude ?? ""

        dateIsActive = loadedSettings?.dateIsActive ?? false
        beginDate = loadedSettings?.beginDate ?? Date()
        endDate = loadedSettings?.endDate ?? Date()

        changedDateIsActive = loadedSettings?.changedDateIsActive ?? true
        changedBeginDate = loadedSettings?.changedBeginDate ?? Date()
        changedEndDate = loadedSettings?.changedEndDate ?? Date()

        for element in FilterStatus.allCases {
            status[element] = loadedSettings?.status[element] ?? false
        }

        newTaskNotification = loadedSettings?.newTaskNotification ?? false
        pushToken = loadedSettings?.pushToken ?? ""
        
    }
    
    func status(_ value: FilterStatus) -> Bool {
        return status[value] ?? false
    }
    
    func save() {
        AppSettingsManager.saveSettings()
    }
    
    func predicateFormat(filter: String = "") -> String {
        var result = ""
        
        for element in status where element.value {
            result += (result.isEmpty ? "" : " OR ") + "statusId = \(element.key.rawValue)"
        }
        if !result.isEmpty {
            result = "(\(result))"
        }
        
        if !executors.isEmpty {
            result += (result.isEmpty ? "" : " AND ") + predicateText(filter: "executorsText CONTAINS[c]", value: executors)
        }
        
        if !creatorExclude.isEmpty {
            result += (result.isEmpty ? "" : " AND ") + predicateText(filter: "NOT creator CONTAINS[c]", value: creatorExclude, type: "AND")
        }
        
        if let services = services, !services.isEmpty {
            result += (result.isEmpty ? "" : " AND (") + predicateText(filter: "serviceId =", value: services) + ")"
        }
        
        var predicateArray: [Any]? = []
        if dateIsActive {
            result += (result.isEmpty ? "" : " AND ") + "created >= %@ AND created <= %@"
            predicateArray?.append(beginDate.startOfDay as CVarArg)
            predicateArray?.append(endDate.endOfDay as CVarArg)
        }
        if changedDateIsActive {
            result += (result.isEmpty ? "" : " AND ") + "changed >= %@ AND changed <= %@"
            predicateArray?.append(changedBeginDate.startOfDay as CVarArg)
            predicateArray?.append(changedEndDate.endOfDay as CVarArg)
        }
        
        if !searchText.isEmpty {
//            if !searchType.isEmpty {
//                result += (result.isEmpty ? "" : " AND ") + " \(searchType) CONTAINS[c] '\(searchText)'"
//            } else {

            result += (result.isEmpty ? "" : " AND ") + "( (creator CONTAINS[c] '\(searchText)' OR name CONTAINS[c] '\(searchText)' OR text CONTAINS[c] '\(searchText)' OR idString beginswith '\(searchText)') )"
//            }
        }
        
        
        if !filter.isEmpty {
            result += (result.isEmpty ? "" : " AND ") + filter
        }
        
        return result
        
    }
    
    func predicate(filter: String = "") -> NSPredicate? {
        
        let result = predicateFormat(filter: filter)
        
        if result.isEmpty {
            return nil
        }
        
        if dateIsActive && changedDateIsActive {
            return NSPredicate(format: result,
                                beginDate as CVarArg,
                                endDate as CVarArg,
                                changedBeginDate as CVarArg,
                                changedEndDate as CVarArg)
        } else if dateIsActive {
            return NSPredicate(format: result,
                                beginDate as CVarArg,
                                endDate as CVarArg)
            
        } else if changedDateIsActive {
            return NSPredicate(format: result,
                                changedBeginDate as CVarArg,
                                changedEndDate as CVarArg)
            
        } else {
            return NSPredicate(format: result)
        }
        
    }
    
    func url() -> String {
        
        var filter = ""
        
        for element in status where element.value {
            filter += (filter.isEmpty ? "" : ",") + "\(element.key.rawValue)"
        }
        
        filter = "&StatusIds=\(filter)"
        
        if dateIsActive {
            filter += "&CreatedMoreThan=\(beginDate.toString())&CreatedLessThan=\(endDate.toString())"
        }
        if changedDateIsActive {
            filter += "&ChangedMoreThan=\(changedBeginDate.toString())&ChangedLessThan=\(changedEndDate.toString())"
        }
        
        if !executors.isEmpty {
            filter += "&ExecutorIds=\(StorageManager.shared.fetchUsers(name: executors))"
        }
        
//        if !searchText.isEmpty {
//            filter += "&search=\(searchText)"
//        }
        
        //filter = filter.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        
        return filter
    }
    

    private func predicateText(filter: String, value: String, type: String = "OR") -> String {
        
        var result = "("
        let array = value.array(by: ",")
        for i in 0...array.count-1 {
            if i == array.count-1 {
                result += "\(filter) '\(array[i].lowercased())'"
            } else {
                result += "\(filter) '\(array[i].lowercased())' \(type) "
            }
        }
        result += ")"
        
        return result
    }
    
    func executorsContaints(ids: String) -> Bool {
        
        if executors.isEmpty {
            return true
        }
        if ids.isEmpty {
            return false
        }
        
        let executorsArray = executorsIds
        let taskExecutors = ids.array(by: ",").map{Int32($0)!}
        for executor in taskExecutors {
            if executorsArray.contains(executor) {
                return true
            }
        }
        return false
        
    }
    
    func creatorExcludeConstaints(id: Int32) -> Bool {
        
        if creatorExclude.isEmpty {
            return false
        }
        
        let excludeArray = StorageManager.shared.fetchUsersIds(names: creatorExclude)
        
        return excludeArray.contains(id)
        
    }

    
    
}


enum FilterStatus: Int, CaseIterable, Codable {
    
    case open = 31
    case approval = 37
    case cancel = 30
    case ready = 29
    case queue = 38
    case process = 27
    case close = 28
    
    var text: String {
        switch self {
        case .open: return "statusOpen"
        case .approval: return "statusApproval"
        case .cancel: return "statusCancel"
        case .ready: return "statusReady"
        case .queue: return "statusQueue"
        case .process: return "statusApproval"
        case .close: return "statusProcess"
        }
    }
    
    var textRU: String {
        switch self {
        case .open: return "Открыта"
        case .approval: return "Запрос дополнительных данных"
        case .cancel: return "Отменена"
        case .ready: return "Выполнена"
        case .queue: return "Согласована"
        case .process: return "В процессе"
        case .close: return "Закрыта"
        }
    }
    
}
