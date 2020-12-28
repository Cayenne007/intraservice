// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let jSONUsers = try? newJSONDecoder().decode(JSONUsers.self, from: jsonData)

import Foundation

// MARK: - JSONUsers
struct JSONUsers: Codable {
    let users: [JSONUser]
    let paginator: JSONPaginator

    enum CodingKeys: String, CodingKey {
        case users = "Users"
        case paginator = "Paginator"
    }
}

// MARK: - User
struct JSONUser: Codable {
    let id: Int32
    let name: String

    enum CodingKeys: String, CodingKey {
        case id = "Id"
        case name = "Name"
    }
}
