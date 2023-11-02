//
//  GGView.swift
//  GiveGive
//
//  Created by Joanne Yager on 2023-10-30.
//

import SwiftUI
import RealityKit

struct GGView: View {
    
    @State private var showSheet = false

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            AnimationView()
            FeedButton(showSheet: $showSheet)
        }
        .ignoresSafeArea()
        .sheet(isPresented: $showSheet) {
            Text("NewCameraView")
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
        .padding(EdgeInsets(top: 0, leading: 0, bottom: 32, trailing: 32))
    }
}

#Preview {
    GGView()
}


