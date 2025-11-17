//
//  ContentView.swift
//  Mindi
//
//  Created by Riv Sal on 11/8/25.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 1 // Start with Home tab (center)
    
    var body: some View {
        TabView(selection: $selectedTab) {
            CalendarView()
                .tabItem {
                    Image(systemName: "calendar")
                    Text("Calendar")
                }
                .tag(0)
            
//            HomeView()
            CardScrollView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
                .tag(1)
            
            ProfileView()
                .tabItem {
                    Image(systemName: "triangle.fill")
                    Text("Profile")
                }
                .tag(2)
        }
    }
}

#Preview {
    ContentView()
}
