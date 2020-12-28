// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let jSONTasks = try? newJSONDecoder().decode(JSONTasks.self, from: jsonData)

import Foundation

// MARK: - JSONTasks
struct JSONTasks: Codable {
    let tasks: [JSONTask]
    let priorities, services, statuses, users: [JSONAny]
    let paginator: JSONPaginator

    enum CodingKeys: String, CodingKey {
        case tasks = "Tasks"
        case priorities = "Priorities"
        case services = "Services"
        case statuses = "Statuses"
        case users = "Users"
        case paginator = "Paginator"
    }
}

// MARK: - Task
struct JSONTask: Codable {
    let assets: JSONNull?
    let categories: String?
    let changed: String
    let closed: String?
    let created, creator: String
    let editorID: Int?
    let creatorIP: JSONNull?
    let creatorID: Int32
    let data: JSONNull?
    let deadline: String?
    let taskDescription: String?
    let evaluation: String?
    let evaluationID: Int?
    let executorGroup, executorGroupID: JSONNull?
    let files: String?
    let hours: JSONNull?
    let id: Int32
    let isMassIncident: Bool?
    let name: String
    let parentID, price: JSONNull?
    let priorityID: Int?
    let reactionDate: String?
    let reactionDateFact: String?
    let reactionOverdue: Bool?
    let resolutionDateFact: String?
    let resolutionOverdue: Bool?
    let serviceID: Int32
    let serviceStage, serviceStageID: JSONNull?
    let statusID: Int32
    let taskRepeatRuleID: JSONNull?
    let type: String
    let typeID: Int32?
    let executorIDS, executors, observerIDS, observers: String
    let coordinatorIDS, coordinators, fileIDS: String?

    enum CodingKeys: String, CodingKey {
        case assets = "Assets"
        case categories = "Categories"
        case changed = "Changed"
        case closed = "Closed"
        case created = "Created"
        case creator = "Creator"
        case editorID = "EditorId"
        case creatorIP = "CreatorIP"
        case creatorID = "CreatorId"
        case data = "Data"
        case deadline = "Deadline"
        case taskDescription = "Description"
        case evaluation = "Evaluation"
        case evaluationID = "EvaluationId"
        case executorGroup = "ExecutorGroup"
        case executorGroupID = "ExecutorGroupId"
        case files = "Files"
        case hours = "Hours"
        case id = "Id"
        case isMassIncident = "IsMassIncident"
        case name = "Name"
        case parentID = "ParentId"
        case price = "Price"
        case priorityID = "PriorityId"
        case reactionDate = "ReactionDate"
        case reactionDateFact = "ReactionDateFact"
        case reactionOverdue = "ReactionOverdue"
        case resolutionDateFact = "ResolutionDateFact"
        case resolutionOverdue = "ResolutionOverdue"
        case serviceID = "ServiceId"
        case serviceStage = "ServiceStage"
        case serviceStageID = "ServiceStageId"
        case statusID = "StatusId"
        case taskRepeatRuleID = "TaskRepeatRuleId"
        case type = "Type"
        case typeID = "TypeId"
        case executorIDS = "ExecutorIds"
        case executors = "Executors"
        case observerIDS = "ObserverIds"
        case observers = "Observers"
        case coordinatorIDS = "CoordinatorIds"
        case coordinators = "Coordinators"
        case fileIDS = "FileIds"
    }
}


