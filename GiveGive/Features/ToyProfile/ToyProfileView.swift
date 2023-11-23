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
    
    func changeOwner(toyId: String) async {
        do {
            try await DatabaseManager.shared.updateToyOwner(toyId: toyId)
            print("22")
        } catch {
            print("Task failed")
        }
        print("26")
      //  self.objectWillChange.send()
        print("28")
    }
}

struct ToyProfileView: View {
    
    @Environment(\.dismiss) var dismiss
    @StateObject var vm: ToyProfileViewModel

  //  @State var toy: Toy
    @State private var isShowingScanner = false
    @State private var receivedToyId: String = ""
    
    @Binding var dismissView: Bool
    
   /* init(vm: ToyProfileViewModel, dismissView: Bool) {
        _vm = StateObject(wrappedValue: vm)
        dismissView = self.dismissView
    }*/
    
    var body: some View {
        
        ZStack(alignment: .topLeading) {
            VStack(alignment: .leading) {
                QRView(toy: vm.toy)
                
                Spacer()
                
                HStack {
                    Spacer()
                    
                    if let urlString = vm.toy.images.first, let url = URL(string: urlString) {
                 //   if let urlString = toy.images.first, let url = URL(string: urlString) {
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
                .onAppear {
                    print("toyprofileview 76 dismissView \(dismissView)")
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
                        // .background(Color("BackgroundColor"))
                            .cornerRadius(5)
                            .padding()
                    }
                }
                
                Spacer()
            }
        }
        .onChange(of: isShowingScanner, { oldValue, newValue in
            Task {
                if !receivedToyId.isEmpty {
                    await vm.changeOwner(toyId: receivedToyId)
                    dismiss()
                }
            }
        })
        .onChange(of: dismissView, { oldValue, newValue in
            Task {
                print("105 dismissView changed oldValue \(String(describing: oldValue)) newValue \(String(describing: newValue))")
                dismiss()
            }
        })
       /* .onChange(of: vm.toy, { oldValue, newValue in
            Task {
                print("80 toy current owner changed oldValue \(String(describing: oldValue)) newValue \(String(describing: newValue))")
                dismiss()
            }
        })*/
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
