//
//  GGView.swift
//  GiveGive
//
//  Created by Joanne Yager on 2023-10-30.
//

import SwiftUI
import RealityKit
import PhotosUI
import FirebaseAuth

@MainActor
final class GGViewModel: ObservableObject {
    
    var user = AuthenticationManager.shared.currentUser
    
    func signInUser() async throws {
        try await AuthenticationManager.shared.anonymousSignIn()
    }
    
    func saveImage(item: PhotosPickerItem) {
        guard let user else { return }
        
        Task {
            guard let data = try await item.loadTransferable(type: Data.self) else {
                print("Jo error - data is nil")
                return }

            let (path, name) = try await StorageManager.shared.saveImage(data: data, userId: user.id!)

            print("Jo SUCCESS")
            print("Jo \(path)")
            print("Jo \(name)")
            
            var newToy = Toy()
            
          //  try await DatabaseManager.shared.updateToyImagePath(toy: newToy, path: name)
            newToy.images.append(name)
            DatabaseManager.shared.addToy(toy: newToy)
            print("Jo addToySuccess \(newToy.images)")
        }
    }
}

struct GGView: View {
    
    @StateObject private var viewModel = GGViewModel()
    
    @State private var showSheet = false
    
    @State private var selectedItem: PhotosPickerItem? = nil
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                AnimationView()
                VStack {
                    //  FeedButton(showSheet: $showSheet)
                    //  FeedButton2(selectedItem: $selectedItem)
                    PhotosPicker(selection: $selectedItem, matching: .images, photoLibrary: .shared()) {
                        
                        Image(systemName: "fork.knife")
                            .font(.title.weight(.semibold))
                            .padding()
                            .background(Color.pink)
                            .foregroundColor(.white)
                            .clipShape(Circle())
                            .shadow(radius: 4, x: 0, y: 4)
                    }
                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 32))
                    
                    BellyButton()
                }
            }
            .onAppear {
                Task {
                    do {
                        try await viewModel.signInUser()
                    } catch {
                        print(error)
                    }
                }
            }
            .ignoresSafeArea()
            .onChange(of: selectedItem, perform: { newValue in

                if let newValue {
                    viewModel.saveImage(item: newValue)
                }
            })
        }
       /* .sheet(isPresented: $showSheet) {
            Text("NewCameraView")
                .onAppear {
                    DatabaseManager.shared.addToy(toy: Toy())
                }
        }*/
    }
}

struct AnimationView: View {
    var body: some View {
        ZStack {
            ARViewContainer()
        }
    }
}

struct ARViewContainer: UIViewRepresentable {
    
    func makeUIView(context: Context) -> ARView {
        
        let arView = ARView(frame: .zero, cameraMode: .nonAR, automaticallyConfigureSession: true)
        
        arView.environment.lighting.intensityExponent = 3
        let newAnchor = AnchorEntity(world: .zero)
        let newEnt = try! Entity.load(named: "gg")
        newAnchor.addChild(newEnt)
        arView.scene.addAnchor(newAnchor)
        
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) { }
}

struct FeedButton: View {
    
    @Binding var showSheet: Bool
    
    var body: some View {
        Button {
            showSheet = true
        } label: {
            Image(systemName: "fork.knife")
                .font(.title.weight(.semibold))
                .padding()
                .background(Color.pink)
                .foregroundColor(.white)
                .clipShape(Circle())
                .shadow(radius: 4, x: 0, y: 4)
        }
        .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 32))
    }
}

struct FeedButton2: View {
    
    @Binding var selectedItem: PhotosPickerItem?
    
    var body: some View {
        PhotosPicker(selection: $selectedItem, matching: .images, photoLibrary: .shared()) {
            
            Image(systemName: "fork.knife")
                .font(.title.weight(.semibold))
                .padding()
                .background(Color.pink)
                .foregroundColor(.white)
                .clipShape(Circle())
                .shadow(radius: 4, x: 0, y: 4)
        }
        .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 32))
    }
}


struct BellyButton: View {
    
    var body: some View {
        NavigationLink {
            ToyListView()
        } label: {
            Image(systemName: "paperplane")
                .font(.title.weight(.semibold))
                .padding()
                .background(Color.pink)
                .foregroundColor(.white)
                .clipShape(Circle())
                .shadow(radius: 4, x: 0, y: 4)
        }
        .padding(EdgeInsets(top: 16, leading: 0, bottom: 32, trailing: 32))
    }
}

#Preview {
    GGView()
}


