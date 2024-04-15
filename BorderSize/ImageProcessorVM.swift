//
//  ImageProcessorVM.swift
//  BorderSize
//
//  Created by Vipul Arvind on 4/13/24.
//

import Foundation
import UIKit

@MainActor
final class ImageProcessorVM: ObservableObject {
    static let shared = ImageProcessorVM()
    
    @Published var originalImage: UIImage?
    @Published var postVisionImage: UIImage?
    @Published var finalImageWithArea: UIImage?
    @Published var imageDrawnArea: Double
    @Published var blankArea: Double
    
    init() {
        self.imageDrawnArea = 0.0
        self.blankArea = 0.0
    }
    
    func processImage(_ imageName: String) {        
        guard let image = UIImage(named: imageName) else {
            self.originalImage = nil
            self.postVisionImage = nil
            self.finalImageWithArea = nil
            self.imageDrawnArea = 0.0
            self.blankArea = 0.0
            
            return
        }
        
        self.originalImage = image
        
        ImageProcessor.processImage(image) { [weak self] result in
            guard let self = self else {
                return
            }
            
            switch result {
            case .success(let imageProcessorResponse):
                DispatchQueue.main.async { [weak self] in
                    self?.postVisionImage = imageProcessorResponse.postVisionImage
                    self?.finalImageWithArea = imageProcessorResponse.finalImageWithArea
                    self?.imageDrawnArea = imageProcessorResponse.imageDrawnArea
                    self?.blankArea = imageProcessorResponse.blankArea
                }
                
                break
            
            case .failure:
                self.postVisionImage = nil
                self.finalImageWithArea = nil
                self.imageDrawnArea = 0.0
                self.blankArea = 0.0
                
                break
            }
        }
    }
}
