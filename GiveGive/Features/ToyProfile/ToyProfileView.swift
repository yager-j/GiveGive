//
//  ToyProfileView.swift
//  GiveGive
//
//  Created by Joanne Yager on 2023-10-05.
//

import SwiftUI
import CodeScanner

struct ToyProfileView: View {
    
    var toy: Toy
    @State private var isShowingScanner = false
    
    var body: some View {
        
        ZStack(alignment: .topLeading) {
            VStack(alignment: .leading) {
                QRView(toy: toy)
                
                Spacer()
                
                HStack {
                    Spacer()
                    
                    if let urlString = toy.images.first, let url = URL(string: urlString) {
                        AsyncImage(url: url) { image in
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(width: 300, height: 300)
                                .cornerRadius(10)
                        } placeholder: {
                            ProgressView()
                                .frame(width: 150, height: 150)
                        }
                    }
                    
                    Spacer()
                }
                
                Spacer()
                
                HStack {
                    Spacer()
                    
                    Button {
                        isShowingScanner = true
                    } label: {
                        Text("Swap toy")
                            .font(Font.custom("WorkSans-SemiBold", size: 20))
                            .padding()
                            .frame(height: 50)
                            .background(Color("BackgroundColor"))
                            .cornerRadius(5)
                            .padding()
                    }
                }
                
                
                /*  HStack {
                 NavigationLink {
                 MapView()
                 } label: {
                 Text("Map")
                 .padding()
                 .frame(height: 50)
                 .background(.white)
                 .cornerRadius(5)
                 .padding()
                 }
                 Spacer()
                 
                 NavigationLink {
                 //  ImageLiftView()
                 } label: {
                 Text("Image Lift Test")
                 .padding()
                 .frame(height: 50)
                 .background(.white)
                 .cornerRadius(5)
                 .padding()
                 }
                 }*/
                Spacer()
            }
        }
        
        // .ignoresSafeArea()
        .sheet(isPresented: $isShowingScanner) {
            CodeScannerView(codeTypes: [.qr], simulatedData: "id123", completion: handleScan)
        }
    }
    
    func handleScan(result: Result<ScanResult, ScanError>) {
        isShowingScanner = false
        switch result {
        case .success(let result):
            //  let details = result.string.components(separatedBy: "\n")
            // guard details.count == 2 else { return }
            let details = result.string
            guard !details.isEmpty else { return }
            
            let scannedID = details
            print("scannedID: \(scannedID)")
            
        case .failure(let error):
            print("Scanning failed: \(error.localizedDescription)")
        }
    }
}

#Preview {
    ToyProfileView(toy: Toy())
}
