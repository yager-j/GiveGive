//
//  GGView.swift
//  GiveGive
//
//  Created by Joanne Yager on 2023-10-30.
//

import SwiftUI
import RealityKit

@MainActor
final class GGViewModel: ObservableObject {
    
    func signInUser() async throws {
        try await AuthenticationManager.shared.anonymousSignIn()
    }
}

struct GGView: View {
    
    @StateObject private var viewModel = GGViewModel()
    
    @State private var showSheet = false
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                AnimationView()
                VStack {
                    FeedButton(showSheet: $showSheet)
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
        }
        .sheet(isPresented: $showSheet) {
            Text("NewCameraView")
                .onAppear {
                    DatabaseManager.shared.addToy(toy: Toy())
                }
        }
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


