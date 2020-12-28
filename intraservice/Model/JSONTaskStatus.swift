//
//  JSONTaskStatus.swift
//  intraservice
//
//  Created by user184795 on 28.12.2020.

import Foundation

// MARK: - JSONStatusElement
struct JSONTaskStatus: Codable {
    let id: Int32
    let name, jsonStatusDescription: String
    let image16URL, image24URL: String
    let isCommentRequired, isFinal, isFixed, isInitial: Bool
    let isConcurrence, isExternal, isDeadlineAccountingPaused: Bool
    let changed: String

    enum CodingKeys: String, CodingKey {
        case id = "Id"
        case name = "Name"
        case jsonStatusDescription = "Description"
        case image16URL = "Image16Url"
        case image24URL = "Image24Url"
        case isCommentRequired = "IsCommentRequired"
        case isFinal = "IsFinal"
        case isFixed = "IsFixed"
        case isInitial = "IsInitial"
        case isConcurrence = "IsConcurrence"
        case isExternal = "IsExternal"
        case isDeadlineAccountingPaused = "IsDeadlineAccountingPaused"
        case changed = "Changed"
    }
}
