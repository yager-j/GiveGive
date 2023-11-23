//
//  ToyListView.swift
//  GiveGive
//
//  Created by Joanne Yager on 2023-11-06.
//

import SwiftUI
import Firebase
import FirebaseFirestoreSwift

struct ToyListView: View {
    
    @EnvironmentObject var dbManager: DatabaseManager
   // @State var currentToyList: [Toy] = []
    @State var isDismissed: Bool = false
    
    var body: some View {
        ToyGridView(isDismissed: $isDismissed)
            .onAppear {
                dbManager.listenToFirestore()
            }
    }
    
}

struct ToyGridView: View {
    
    @EnvironmentObject var dbManager: DatabaseManager

   // var currentToyList: [Toy]
    @Binding var isDismissed: Bool
    
    var body: some View {
        
        ScrollView{
            LazyVGrid(columns: Array(repeating: .init(.flexible()), count: UIDevice.current.userInterfaceIdiom == .pad ? 4 : 2), spacing: 10) {
                ForEach(dbManager.currentToyList) { item in
                    
                    ToyThumbnailView(toy: item, isDismissed: $isDismissed)
                    .padding(5)
                }
            }
        }
        .padding()
        .onAppear {
            print("gridv 75 isDismissed \(isDismissed)")
           // print("currentToyList gridv \(currentToyList)")
        }
    }
}

struct ToyThumbnailView: View {
    
    var toy: Toy
    @State private var url: URL? = nil
    @Binding var isDismissed: Bool
    
    var body: some View {
        NavigationLink {
            ToyProfileView(vm: ToyProfileViewModel(toy: toy), dismissView: $isDismissed)
        } label: {
            ZStack {
                Rectangle()
                    .fill(.black)
                    .cornerRadius(10)
                    .aspectRatio(contentMode: .fit)
                
                if let urlString = toy.images.first, let url = URL(string: urlString) {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 150, height: 150)
                            .cornerRadius(10)
                    } placeholder: {
                        ProgressView()
                            .frame(width: 150, height: 150)
                    }
                }
                
                /* Text(String(toy.id ?? "no id"))
                 .foregroundColor(.white)
                 .font(.title)*/
            }
            .onAppear {
                print("toythumb 115 isDismissed \(isDismissed)")
            }
        }
    }
}

// TODO: Make ViewModel for ToyListView with listenToFirestore in it
