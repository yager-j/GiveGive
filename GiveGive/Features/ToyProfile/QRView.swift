//
//  QRView.swift
//  Astro
//
//  Created by Joanne Yager on 2023-10-05.
//

import SwiftUI
import CoreImage.CIFilterBuiltins

struct QRView: View {
    
    @State var toy: Toy
    
    let context = CIContext()
    let filter = CIFilter.qrCodeGenerator()
    
    var body: some View {
        HStack {
            if let id = toy.id {
                Image(uiImage: generateQRCode(from: id))
                    .interpolation(.none)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .cornerRadius(5)
                
            }
            
            Spacer()
        }
        .padding()
        .background(Color("BackgroundColor").opacity(0.7))
        .cornerRadius(15.0)
    }
    
    func generateQRCode(from string: String) -> UIImage {
        filter.message = Data(string.utf8)
        
        if let outputImage = filter.outputImage {
            if let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
                return UIImage(cgImage: cgimg)
            }
        }
        
        return UIImage(systemName: "xmark.circle") ?? UIImage()
    }
}

#Preview {
    QRView(toy: Toy())
}
