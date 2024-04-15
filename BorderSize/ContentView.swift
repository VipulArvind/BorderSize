//
//  ContentView.swift
//  BorderSize
//
//  Created by Vipul Arvind on 4/13/24.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var imageProcessorVM: ImageProcessorVM
    @State var imageOnSCreen: Image = Image("ImageInp1")
    @State var selectedImageIndex = 0
    
    var body: some View {
        VStack (alignment:.leading, spacing: 20) {
            Text("Select an Image")
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(Font.largeTitle.bold())
                .kerning(2.8)
                .foregroundStyle(.yellow)
                        
            HStack (){
                Image("ImageInp1")
                    .resizable()
                    .frame(width: 75, height: 100)
                    .border(borderColorForImageAt(0),width:4)
                    .onTapGesture {
                        newImageSelected("ImageInp1", index: 0)
                    }
                
                Spacer()
                
                Image("ImageInp2")
                    .resizable()
                    .frame(width: 75, height: 100)
                    .border(borderColorForImageAt(1),width:4)
                    .onTapGesture {
                        newImageSelected("ImageInp2", index: 1)
                    }
                
                Spacer()
                
                Image("ImageInp3")
                    .resizable()
                    .frame(width: 75, height: 100)
                    .border(borderColorForImageAt(2),width:4)
                    .onTapGesture {
                        newImageSelected("ImageInp3", index: 2)
                    }
            }
            
            Color.red
                .frame(height: 1)
                .shadow(color: .gray, radius: 4, x: 0, y: 0)
            
            Text(areaString())
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(Font.body.bold())
                .kerning(2.8)
                .foregroundStyle(.red)
            
            Color.red
                .frame(height: 1)
                .shadow(color: .gray, radius: 4, x: 0, y: 0)
            
            imageOnSCreen
                .resizable()
            
            HStack (spacing: 10){
                Button("Input Image") {
                    self.inputImageButtonTapped()
                }
                Spacer()
                
                Button("Post Vision") {
                    self.postVisionButtonTapped()
                }
                
                Spacer()
                
                Button("Final Area") {
                    self.finalAreaButtonTapped()
                }
            }
            
            .onAppear() {
                newImageSelected("ImageInp1", index: 0)
            }
        }
        .padding()
    }
    
    func borderColorForImageAt(_ index: Int) -> Color {
        if index == selectedImageIndex {
            return .mint.opacity(1.0)
        }
        return .purple.opacity(0.0)
    }
    
    func areaString() -> String {
        let imageDrawnArea = String(format: "%.2f%%", imageProcessorVM.imageDrawnArea * 100)
        let blankArea = String(format: "%.2f%%", imageProcessorVM.blankArea * 100)
        
        return "Image: " + imageDrawnArea + " Border: " + blankArea
    }
    
    func newImageSelected(_ imageName: String, index:Int) {
        selectedImageIndex = index
        imageOnSCreen = Image(imageName)
        imageProcessorVM.processImage(imageName)
    }
    
    func inputImageButtonTapped() {
        if let anImage = imageProcessorVM.originalImage {
            imageOnSCreen = Image(uiImage: anImage).renderingMode(.original)
        }
    }
    
    func postVisionButtonTapped() {
        if let anImage = imageProcessorVM.postVisionImage {
            imageOnSCreen = Image(uiImage: anImage).renderingMode(.original)
        }
    }
    
    func finalAreaButtonTapped() {
        if let anImage = imageProcessorVM.finalImageWithArea {
            imageOnSCreen = Image(uiImage: anImage).renderingMode(.original)
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(ImageProcessorVM())
}
