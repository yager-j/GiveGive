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
    
    @EnvironmentObject var dbManager: DatabaseManager

    var user = AuthenticationManager.shared.currentUser
    
    func signInUser() async throws {
        try await AuthenticationManager.shared.anonymousSignIn()
    }
    
    func saveImage(item: UIImage?) {
        guard let user else { return }
        
        Task {
            
            guard let data = item, let id = user.id else {
                print("Jo error - data is nil")
                return
            }
            
            let (path, name) = try await StorageManager.shared.saveImage(image: data, userId: id)
            
            print("Jo SUCCESS")
            print("Jo \(path)")
            print("Jo \(name)")
            
            let newToy = Toy()
            
            let url = try await StorageManager.shared.getUrlForImage(path: path)
            newToy.images.append(url.absoluteString)
            dbManager.addToy(toy: newToy)
            print("Jo addToySuccess \(newToy.images)")
        }
    }
}

struct GGView: View {
    
    @StateObject private var viewModel = GGViewModel()
    
    @State private var showSheet = false
        
    @State var subjectImage: UIImage? = UIImage()
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                WebView(url: URL(string: "https://my.spline.design/ggverticalfulltransition-8c0e832f19bb844220a9804add0cac98/")!)
                
                VStack {
                    FeedButton(showSheet: $showSheet)
                    
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
            .onChange(of: subjectImage, { oldValue, newValue in
                
                if let newValue {
                    viewModel.saveImage(item: newValue)
                }
            })
        }
        .sheet(isPresented: $showSheet) {
            SubjectLiftingView(subjectImage: $subjectImage)
        }
    }
}

struct WebView: UIViewRepresentable {
    let url: URL
    
    func makeUIView(context: Context) -> WKWebView {
        return WKWebView()
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        webView.load(request)
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

#Preview {
    GGView()
}


