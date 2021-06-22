//
//  MeView.swift
//  HotProspects
//
//  Created by Emile Wong on 21/6/2021.
//

import SwiftUI
import CoreImage.CIFilterBuiltins

struct MeView: View {
    // MARK: - PROPERTIES
    @State private var name = ""
    @State private var emailAddress = ""
    
    let context = CIContext()
    let filter = CIFilter.qrCodeGenerator()
    
    // MARK: - FUNCTIONS
    func generateQRCode(from string: String) -> UIImage {
        let data = Data(string.utf8)
        filter.setValue(data, forKey: "inputMessage")
        
        if let outputImage = filter.outputImage {
            if let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
                return UIImage(cgImage: cgimg)
            }
        }
        
        return UIImage(systemName: "xmark.circle") ?? UIImage()
    }
    
    // MARK: - BODY
    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                
                Image(uiImage: generateQRCode(from: "\(name)\n\(emailAddress)"))
                    .interpolation(.none)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200, alignment: .center)
                
                TextField("Name", text: $name)
                    .textContentType(.name)
                    .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                    .padding(.horizontal)
                
                TextField("Email address", text: $emailAddress)
                    .textContentType(.emailAddress)
                    .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                    .padding([.horizontal, .bottom])
                
                Spacer()
            } //: VSTACK
            .navigationBarTitle("My QR code")
        } //: NAVIGATION
    }
}
// MARK: - PREVIEW
struct MeView_Previews: PreviewProvider {
    static var previews: some View {
        MeView()
    }
}
