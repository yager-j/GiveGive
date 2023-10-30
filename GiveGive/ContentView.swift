//
//  ContentView.swift
//  GiveGive
//
//  Created by Joanne Yager on 2023-10-30.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello!")
                .font(Font.custom("WorkSans-ExtraBold", size: 40))
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
