// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let jSONServices = try? newJSONDecoder().decode(JSONServices.self, from: jsonData)

import Foundation

// MARK: - JSONServices
struct JSONServices: Codable {
    let services: [JSONService]
    let paginator: JSONPaginator

    enum CodingKeys: String, CodingKey {
        case services = "Services"
        case paginator = "Paginator"
    }
}


// MARK: - Service
struct JSONService: Codable {
    let id: Int32
    let code, name, serviceDescription: String
    let isArchive, isPublic: Bool
    let parentID: JSONNull?
    let path: String

    enum CodingKeys: String, CodingKey {
        case id = "Id"
        case code = "Code"
        case name = "Name"
        case serviceDescription = "Description"
        case isArchive = "IsArchive"
        case isPublic = "IsPublic"
        case parentID = "ParentId"
        case path = "Path"
    }
}

