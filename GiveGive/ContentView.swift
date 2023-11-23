//
//  ContentView.swift
//  GiveGive
//
//  Created by Joanne Yager on 2023-10-30.
//

import SwiftUI

struct ContentView: View {
    @StateObject var dbManager = DatabaseManager()
    
    var body: some View {
        GGView()
            .environmentObject(dbManager)
    }
}

#Preview {
    ContentView()
}
