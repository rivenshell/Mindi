//
//  JournalEntry.swift
//  Mindi
//
//  Backend API Models
//

import Foundation

struct JournalEntry: Identifiable, Codable {
    var id: UUID
    var userId: UUID
    var title: String?
    var content: String
    var createdAt: Date
    var updatedAt: Date
    var entryDate: Date
    var tags: [Tag]?

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case title
        case content
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case entryDate = "entry_date"
        case tags
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        userId = try container.decode(UUID.self, forKey: .userId)
        title = try container.decodeIfPresent(String.self, forKey: .title)
        content = try container.decode(String.self, forKey: .content)
        tags = try container.decodeIfPresent([Tag].self, forKey: .tags)
        createdAt = try container.decodePostgresDate(forKey: .createdAt)
        updatedAt = try container.decodePostgresDate(forKey: .updatedAt)
        entryDate = try container.decodePostgresDate(forKey: .entryDate)
    }
}

/// Postgres returns `timestamptz` columns as ISO-8601 (with or without fractional
/// seconds) and `date` columns as plain `yyyy-MM-dd`, so no single strategy covers both.
extension KeyedDecodingContainer where K == JournalEntry.CodingKeys {
    func decodePostgresDate(forKey key: K) throws -> Date {
        let raw = try decode(String.self, forKey: key)
        guard let date = PostgresDateParser.date(from: raw) else {
            throw DecodingError.dataCorruptedError(
                forKey: key,
                in: self,
                debugDescription: "Unrecognized date format: \(raw)"
            )
        }
        return date
    }
}

enum PostgresDateParser {
    private static let fractional: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()

    private static let internetDateTime = ISO8601DateFormatter()

    private static let dateOnly: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    static func date(from string: String) -> Date? {
        fractional.date(from: string)
            ?? internetDateTime.date(from: string)
            ?? dateOnly.date(from: string)
            ?? fractional.date(from: normalizingFractionalSeconds(string))
    }

    /// Postgres can emit microsecond precision, which `ISO8601DateFormatter` rejects.
    private static func normalizingFractionalSeconds(_ string: String) -> String {
        guard let dotIndex = string.firstIndex(of: ".") else { return string }
        let afterDot = string.index(after: dotIndex)
        let digits = string[afterDot...].prefix { $0.isNumber }
        guard digits.count > 3 else { return string }
        let end = string.index(afterDot, offsetBy: digits.count)
        return String(string[..<afterDot]) + String(digits.prefix(3)) + String(string[end...])
    }

    static func dateOnlyString(from date: Date) -> String {
        dateOnly.string(from: date)
    }
}

struct Tag: Identifiable, Codable {
    var id: UUID
    var userId: UUID
    var name: String
    var color: String?
    var createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case name
        case color
        case createdAt = "created_at"
    }
}

struct MeditationSession: Identifiable, Codable {
    var id: UUID
    var userId: UUID
    var startedAt: Date
    var endedAt: Date?
    var durationSeconds: Int?
    var messages: [MeditationMessage]
    var sessionType: String?

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case startedAt = "started_at"
        case endedAt = "ended_at"
        case durationSeconds = "duration_seconds"
        case messages
        case sessionType = "session_type"
    }
}

struct MeditationMessage: Codable {
    var role: String
    var content: String
    var timestamp: Date
}

// MARK: - API Request/Response Models

struct NewJournalEntry: Codable {
    var userId: UUID
    var title: String?
    var content: String
    var entryDate: String // yyyy-MM-dd

    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case title
        case content
        case entryDate = "entry_date"
    }
}

struct JournalEntryUpdate: Codable {
    var title: String?
    var content: String?
}

struct CreateTagRequest: Codable {
    var name: String
    var color: String?
}

struct StartMeditationRequest: Codable {
    var sessionType: String?
    var initialMessage: String?

    enum CodingKeys: String, CodingKey {
        case sessionType = "session_type"
        case initialMessage = "initial_message"
    }
}

struct SendMeditationMessageRequest: Codable {
    var message: String
}

// MARK: - API Response Wrappers

struct APIResponse<T: Codable>: Codable {
    var success: Bool
    var data: T?
    var message: String?
}

struct APIErrorResponse: Codable {
    var success: Bool
    var error: String
    var details: String?
}
