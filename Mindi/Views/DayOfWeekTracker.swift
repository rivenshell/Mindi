//
//  DayOfWeekTracker.swift
//  Mindi
//
//  Created by Riv Sal on 11/9/25.
//

import SwiftUI

struct DayOfWeekTracker: View {
    // Get current day of week (1 = Sunday, 2 = Monday, ..., 7 = Saturday)
    private var currentDayOfWeek: Int {
        Calendar.current.component(.weekday, from: Date())
    }

    // Helper function to determine if a day should be highlighted
    private func shouldHighlight(index: Int) -> Bool {
        // Map array index to weekday: S(0)=Sun(1), S(1)=Sat(7), M(2)=Mon(2), T(3)=Tue(3), W(4)=Wed(4), T(5)=Thu(5), F(6)=Fri(6)
        let weekdayMapping = [1, 7, 2, 3, 4, 5, 6] // S S M T W T F -> Sun Sat Mon Tue Wed Thu Fri
        return weekdayMapping[index] == currentDayOfWeek
    }

    var body: some View {
        HStack(spacing: 4) {
            // S S M T W T F represents the days
            ForEach(0..<7) { index in
                let days = ["S ", "S ", "M ", "T ", "W ", "T ", "F "]
                Text(days[index])
                    .font(.system(size: 14.0))
                    .fontWeight(shouldHighlight(index: index) ? .bold : .regular)
                    .underline(shouldHighlight(index: index))
            }
        }
    }
}

#Preview {
    DayOfWeekTracker()
}
