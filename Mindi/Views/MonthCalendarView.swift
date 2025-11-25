import SwiftUI

struct MonthCalendarView: View {
    @State private var currentMonth: Date = Date()
    @State private var mindfulState = MindfulTrackerState()
    
    private let calendar = Calendar.current
    private let weekDaySymbols = Calendar.current.shortWeekdaySymbols
    
    // Natural, grounded color palette inspired by botanical skincare
    private let backgroundColor = Color(red: 0.98, green: 0.97, blue: 0.95) // Warm cream
    private let primaryText = Color(red: 0.2, green: 0.18, blue: 0.16) // Deep brown
    private let secondaryText = Color(red: 0.45, green: 0.42, blue: 0.38) // Muted taupe
    private let mindfulGreen = Color(red: 0.52, green: 0.63, blue: 0.55) // Soft sage green
    private let mindfulAccent = Color(red: 0.38, green: 0.48, blue: 0.42) // Deep sage
    private let cellBackground = Color(red: 0.95, green: 0.94, blue: 0.92) // Light beige
    
    var body: some View {
        VStack(spacing: 20) {
            // Month header with refined navigation
            HStack(spacing: 20) {
                Button {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        currentMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth) ?? currentMonth
                    }
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(secondaryText)
                        .frame(width: 32, height: 32)
                        .background(cellBackground)
                        .clipShape(Circle())
                }
                
                Spacer()
                
                Text(monthTitle(for: currentMonth))
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(primaryText)
                    .tracking(0.5)
                
                Spacer()
                
                Button {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        currentMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth) ?? currentMonth
                    }
                } label: {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(secondaryText)
                        .frame(width: 32, height: 32)
                        .background(cellBackground)
                        .clipShape(Circle())
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 8)
            
            // Weekday labels
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                ForEach(weekDaySymbols, id: \.self) { symbol in
                    Text(symbol.uppercased())
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundColor(secondaryText)
                        .tracking(0.8)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 4)
            
            // Days grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 7), spacing: 8) {
                ForEach(daysForMonth(currentMonth), id: \.self) { date in
                    if let date = date {
                        let mindful = mindfulState.isMindful(on: date)
                        let day = calendar.component(.day, from: date)
                        let isToday = calendar.isDateInToday(date)
                        
                        Button {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                mindfulState.toggleMindful(on: date)
                            }
                        } label: {
                            VStack(spacing: 4) {
                                Text("\(day)")
                                    .font(.system(size: 15, weight: mindful ? .semibold : .regular, design: .rounded))
                                    .foregroundColor(mindful ? .white : primaryText)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 44)
                                    .background(
                                        ZStack {
                                            // Base background
                                            if mindful {
                                                RoundedRectangle(cornerRadius: 12)
                                                    .fill(
                                                        LinearGradient(
                                                            colors: [mindfulGreen, mindfulAccent],
                                                            startPoint: .topLeading,
                                                            endPoint: .bottomTrailing
                                                        )
                                                    )
                                                    .shadow(color: mindfulGreen.opacity(0.3), radius: 4, x: 0, y: 2)
                                            } else {
                                                RoundedRectangle(cornerRadius: 12)
                                                    .fill(cellBackground)
                                            }
                                            
                                            // Today indicator
                                            if isToday && !mindful {
                                                RoundedRectangle(cornerRadius: 12)
                                                    .strokeBorder(mindfulAccent, lineWidth: 1.5)
                                            }
                                        }
                                    )
                                
                                // Subtle dot indicator for mindful days
                                if mindful {
                                    Circle()
                                        .fill(.white.opacity(0.7))
                                        .frame(width: 4, height: 4)
                                } else {
                                    Circle()
                                        .fill(.clear)
                                        .frame(width: 4, height: 4)
                                }
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                    } else {
                        // Empty cell for padding
                        Color.clear
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
                    }
                }
            }
            .padding(.horizontal, 24)
            
            // Streak display with refined styling
            VStack(spacing: 8) {
                let streak = currentStreak()
                
                HStack(spacing: 12) {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 16))
                        .foregroundColor(streak > 0 ? mindfulAccent : secondaryText.opacity(0.5))
                    
                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text("\(streak)")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(primaryText)
                        
                        Text("day\(streak == 1 ? "" : "s")")
                            .font(.system(size: 15, weight: .medium, design: .rounded))
                            .foregroundColor(secondaryText)
                    }
                }
                .padding(.vertical, 16)
                .padding(.horizontal, 24)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(cellBackground)
                )
                
                if streak > 0 {
                    Text("Keep your mindful momentum going")
                        .font(.system(size: 13, weight: .regular, design: .rounded))
                        .foregroundColor(secondaryText)
                        .tracking(0.3)
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 8)
            
            Spacer()
        }
        .background(backgroundColor.ignoresSafeArea())
    }
    
    private func monthTitle(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "LLLL yyyy"
        return formatter.string(from: date)
    }
    
    /// Returns an array of optional Dates, with leading `nil`s to pad the first week.
    private func daysForMonth(_ date: Date) -> [Date?] {
        guard
            let monthInterval = calendar.dateInterval(of: .month, for: date),
            let firstDay = monthInterval.start as Date?,
            let range = calendar.range(of: .day, in: .month, for: date)
        else { return [] }
        
        // weekday index of first day (1 = Sunday by default, adjust if needed)
        let firstWeekday = calendar.component(.weekday, from: firstDay)
        var days: [Date?] = Array(repeating: nil, count: firstWeekday - 1)
        
        for day in range {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstDay) {
                days.append(date)
            }
        }
        
        return days
    }
    
    private func currentStreak() -> Int {
        let dates = mindfulState.mindfulDates
            .map { calendar.startOfDay(for: $0) }
            .sorted()
        
        guard let last = dates.last else { return 0 }
        
        var streak = 0
        var current = last
        
        while dates.contains(current) {
            streak += 1
            guard let previous = calendar.date(byAdding: .day, value: -1, to: current) else { break }
            current = previous
        }
        
        return streak
    }
}

#Preview {
    MonthCalendarView()
}
