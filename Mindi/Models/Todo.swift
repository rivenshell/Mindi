//
//  Todo.swift
//  Mindi
//
//  Created by Claude Code
//

import Foundation

struct Todo: Identifiable, Codable {
    var id: UUID
    var title: String
    var body: String?
    var isCompleted: Bool
    var createdAt: Date
    var userId: UUID?

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case body
        case isCompleted = "is_completed"
        case createdAt = "created_at"
        case userId = "user_id"
    }
}
