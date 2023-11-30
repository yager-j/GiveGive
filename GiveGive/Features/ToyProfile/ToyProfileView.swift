//
//  ToyProfileView.swift
//  GiveGive
//
//  Created by Joanne Yager on 2023-10-05.
//

import SwiftUI
import CodeScanner

@MainActor
final class ToyProfileViewModel: ObservableObject {
    
    @Published var toy: Toy
    
    init(toy: Toy) {
        self.toy = toy
    }
}

struct ToyProfileView: View {
    
    @Environment(\.dismiss) var dismiss
    @StateObject var vm: ToyProfileViewModel

    @State private var isShowingScanner = false
    @State private var receivedToyId: String = ""
    
    @Binding var dismissView: Bool
    
    @EnvironmentObject var dbManager: DatabaseManager
    
    var body: some View {
        
        ZStack(alignment: .topLeading) {
            VStack(alignment: .leading) {
                QRView(toy: vm.toy)
                
                Spacer()
                ZStack {
                    HStack {
                        Spacer()
                        
                        if let urlString = vm.toy.images.first, let url = URL(string: urlString) {
                            AsyncImage(url: url) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 300, height: 300)
                                    .cornerRadius(10)
                            } placeholder: {
                                ProgressView()
                                    .frame(width: 150, height: 150)
                            }
                        }
                        
                        Spacer()
                    }

                    VStack {
                        Spacer()
                        
                        HStack {
                            Spacer()
                            
                            Button {
                                isShowingScanner = true
                            } label: {
                                Text("SWAP!")
                                    .font(Font.custom("WorkSans-SemiBold", size: 20))
                                    .foregroundStyle(Color.black)
                                    .padding()
                                    .frame(height: 50)
                                    .background(Color("BackgroundColor"))
                                    .cornerRadius(5)
                                    .padding()
                            }
                            .padding()
                        }
                    }
                }
                .background(Color(Color.gray.opacity(0.2)))
                .cornerRadius(15.0)
                
            }
        }
        .onChange(of: isShowingScanner, { oldValue, newValue in
            Task {
                if !receivedToyId.isEmpty {
                    try await dbManager.updateToyOwner(toyId: receivedToyId)
                    dismiss()
                }
            }
        })
        .onChange(of: dbManager.currentToyList, { oldValue, newValue in
            Task {
                dismiss()
            }
        })
        .sheet(isPresented: $isShowingScanner) {
            CodeScannerView(codeTypes: [.qr], simulatedData: "id123", completion: handleScan)
        }
    }
    
    func handleScan(result: Result<ScanResult, ScanError>) {
        isShowingScanner = false
        
        switch result {
        case .success(let result):
            print("result \(result)")
            let details = result.string
                .replacingOccurrences(of: "Optional(\"", with: "")
                .replacingOccurrences(of: "\")", with: "")
            print("details \(details)")
            guard !details.isEmpty else { return }
            
            let scannedID = details
            receivedToyId = scannedID
            
        case .failure(let error):
            print("Scanning failed: \(error.localizedDescription)")
        }
    }
}
