//
//  MindfulTrackerState.swift
//  Mindi
//
//  Created by Riv Sal on 11/25/25.
//

import Foundation
import SwiftUI

@Observable
class MindfulTrackerState {
    var mindfulDates: Set<Date> = []

    private let calendar = Calendar.current

    init() {
        // Load saved dates from UserDefaults
        loadDates()
    }

    func isMindful(on date: Date) -> Bool {
        let normalizedDate = calendar.startOfDay(for: date)
        return mindfulDates.contains { calendar.isDate($0, inSameDayAs: normalizedDate) }
    }

    func toggleMindful(on date: Date) {
        let normalizedDate = calendar.startOfDay(for: date)

        if let existingDate = mindfulDates.first(where: { calendar.isDate($0, inSameDayAs: normalizedDate) }) {
            mindfulDates.remove(existingDate)
        } else {
            mindfulDates.insert(normalizedDate)
        }

        saveDates()
    }

    private func saveDates() {
        let timestamps = mindfulDates.map { $0.timeIntervalSince1970 }
        UserDefaults.standard.set(timestamps, forKey: "mindfulDates")
    }

    private func loadDates() {
        guard let timestamps = UserDefaults.standard.array(forKey: "mindfulDates") as? [Double] else {
            return
        }
        mindfulDates = Set(timestamps.map { Date(timeIntervalSince1970: $0) })
    }
}
