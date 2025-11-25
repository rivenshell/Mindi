//
//  ContentView.swift
//  Mindi
//
//  Created by Riv Sal on 11/8/25.
//

import SwiftUI

struct ContentView: View {
    @Binding var isLoggedIn: Bool
    @State private var selectedTab = 1 // Start with Home tab (center)

    var body: some View {
        TabView(selection: $selectedTab) {
            JournalView()
                .tabItem {
                    Image(systemName: "book.fill")
                    Text("Journal")
                }
                .tag(0)
            
//            HomeView()
            CardScrollView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Today")
                }
                .tag(1)
            
            
            MonthCalendarView()
                .tabItem {
                    Image(systemName: "31.calendar")
                    Text("Streak")
                }
                .tag(2)
            
            ProfileView(isLoggedIn: $isLoggedIn)
                .tabItem {
                    Image(systemName: "triangle.fill")
                    Text("Profile")
                }
                .tag(3)

        }
    }
}

#Preview {
    ContentView(isLoggedIn: .constant(true))
}
