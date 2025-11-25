//
//  ProfileView.swift
//  Mindi
//
//  Created by Riv Sal on 11/9/25.
//

import SwiftUI
import Supabase

struct ProfileView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("SUPABSE VERIFICATION")
                    .padding(20)
                    
//                Task{
//                    do {
//                        let response = try await Supabase
//                            .from
//                    }
//                }
                
                
                
                Text("Wellness Tracking")
                    .fontWeight(.semibold)
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.system(size: 40))
                    .foregroundStyle(.purple)
            }
            .navigationTitle("Profile")
        }
    }
}

#Preview {
    ProfileView()
}
