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
import WebKit

@MainActor
final class GGViewModel: ObservableObject {
    
    var user = AuthenticationManager.shared.currentUser
    
    func signInUser() async throws {
        try await AuthenticationManager.shared.anonymousSignIn()
    }
}

struct GGView: View {
    
    @StateObject private var viewModel = GGViewModel()
    
    @State private var showSheet = false
    @State private var showSubjects = false
    @State private var fallingToyArray: [FallingToy] = []
    
    @State var subjectArray: [UIImage] = []
    
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                ZStack(alignment: .bottomTrailing) {
                    WebView(url: URL(string: "https://my.spline.design/ggverticalfulltransitioncopy-01dc2445f753ce5e70fecb61e7aca5cd/")!)
                        .ignoresSafeArea()
                    
                    if showSubjects {
                        HStack {
                            ForEach(fallingToyArray) { fallingToy in
                                Image(uiImage: fallingToy.image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 200, height: 200)
                                    .position(fallingToy.position)
                            }
                        }
                    }
                    
                    VStack {
                        FeedButton(showSheet: $showSheet)
                            .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 32))
                        
                        BellyButton()
                    }
                }
                .ignoresSafeArea()
                .onAppear {

                    Task {
                        do {
                            try await viewModel.signInUser()
                        } catch {
                            print(error)
                        }
                    }
                }
                .sheet(isPresented: $showSheet, onDismiss: {
                    didDismiss(geometry: geometry)
                }, content: {
                    SubjectLiftingView(subjectArray: $subjectArray)
                })
                .onChange(of: showSheet) { oldValue, newValue in
                    showSubjects = !showSheet
                    if !showSubjects {
                        fallingToyArray.removeAll()
                    }
                }
            }
        }
    }
    
    func didDismiss(geometry: GeometryProxy) {
        fallingToyArray.removeAll()
        for index in 0..<subjectArray.count {
            let xPos = CGFloat.random(in: 0..<geometry.size.width)
            let position = CGPoint(x: xPos, y: -150)
            let fallingToy = FallingToy(image: subjectArray[index], position: position)
            fallingToyArray.append(fallingToy)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let screenCenter = geometry.size.width/2
            for index in 0..<fallingToyArray.count {
                withAnimation(.easeIn(duration: 1)) {
                    fallingToyArray[index].position = CGPoint(x: screenCenter, y: geometry.size.height)
                }
            }
        }
    }
}

struct FallingToy: Identifiable {
    let id = UUID()
    let image: UIImage
    var position: CGPoint
    
    mutating func updatePosition(_ position: CGPoint) {
        self.position = position
    }
}

struct WebView: UIViewRepresentable {
    let url: URL
    
    func makeUIView(context: Context) -> FullScreenWKWebView {
        return FullScreenWKWebView()
    }
    
    func updateUIView(_ webView: FullScreenWKWebView, context: Context) {
        let request = URLRequest(url: url)
        webView.load(request)
    }
}

class FullScreenWKWebView: WKWebView {
    override var safeAreaInsets: UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
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
    }
}

struct BellyButton: View {
    
    var body: some View {
        NavigationLink {
            ToyListView()
        } label: {
            Image(systemName: "square.grid.3x3.fill")
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
