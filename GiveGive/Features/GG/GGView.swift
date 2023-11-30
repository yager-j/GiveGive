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
    
    func saveImage(item: UIImage?) {
        guard let user else { return }
        
        Task {
            
            guard let data = item, let id = user.id else { return }
            
            let (path, name) = try await StorageManager.shared.saveImage(image: data, userId: id)
            
            print("SUCCESS")
            print("\(path)")
            print("\(name)")
            
            let newToy = Toy()
            
            let url = try await StorageManager.shared.getUrlForImage(path: path)
            newToy.images.append(url.absoluteString)
            DatabaseManager.shared.addToy(toy: newToy)
        }
    }
}

struct GGView: View {
    
    @StateObject private var viewModel = GGViewModel()
    
    @State private var showSheet = false
    @State private var showSubjects = false
    
    @State var subjectImage: UIImage? = UIImage()
    @State var subjectArray: [UIImage] = []
    
    let screenWidth = UIScreen.main.bounds.size.width
    let screenHeight = UIScreen.main.bounds.size.height
    
    @State var position = CGPoint(x: 0, y: 0)
    @State var xPos = CGFloat()
    
    @State var offset: CGSize = .zero
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                WebView(url: URL(string: "https://my.spline.design/ggverticalfulltransitioncopy-01dc2445f753ce5e70fecb61e7aca5cd/")!)
                    .ignoresSafeArea()
                
                VStack {
                    FeedButton(showSheet: $showSheet)
                        .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 32))
                    
                    BellyButton()
                }
                
             /*   if showSubjects {
                    HStack {
                        ForEach(subjectArray, id: \.self) { subject in
                            Image(uiImage: subject)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 200, height: 200)
                                .position(position)
                              //  .offset(offset)
                                .onReceive(timer) { input in
                                    withAnimation(.easeInOut(duration: 3).delay(2)) {
                                          self.position = CGPoint(x: screenWidth/2, y: screenHeight)
                                      //  self.offset = CGSize(width: screenWidth/2, height: screenHeight)
                                    }
                                }
                        }
                        
                        /*.onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                print("101 do withAnim")
                                withAnimation(.easeInOut(duration: 3).delay(2)) {
                                      self.position = CGPoint(x: screenWidth/2, y: screenHeight)
                                  //  self.offset = CGSize(width: screenWidth/2, height: screenHeight)
                                }
                                    }
                            
                        }*/
                    }
                }*/
            }
            .ignoresSafeArea()
            .onAppear {
                xPos = CGFloat.random(in: 0..<screenWidth)
                position = CGPoint(x: xPos, y: -50)
                Task {
                    do {
                        try await viewModel.signInUser()
                    } catch {
                        print(error)
                    }
                }
            }
            .onChange(of: subjectImage, { oldValue, newValue in
                
                position = CGPoint(x: screenWidth/2, y: 0)
                
                if let newValue {
                    viewModel.saveImage(item: newValue)
                }
                //  subjectArray.append(newValue)
               // showSubjects = true
                
            })
          /*  .onChange(of: showSheet, { oldValue, newValue in
                if subjectArray.count != 0 {
                    
                }
            })*/
        }
        .sheet(isPresented: $showSheet) {
            SubjectLiftingView(subjectImage: $subjectImage, subjectArray: $subjectArray)
        }
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

#Preview {
    GGView()
}


