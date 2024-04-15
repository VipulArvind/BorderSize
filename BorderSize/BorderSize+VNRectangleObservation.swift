//
//  BorderSize+VNRectangleObservation.swift
//  BorderSize
//
//  Created by Vipul Arvind on 4/13/24.
//

import Foundation
import UIKit
import Vision

extension VNRectangleObservation {
    func cgRectForObservationIn(_ image: UIImage) -> CGRect {
        let boundingBox = self.boundingBox
        
        // Apply the transform to move origin from bottom to top
        let bottomToTopTransform = CGAffineTransform(scaleX: 1, y: -1).translatedBy(x: 0, y: -1)
        let boundingBox2 = boundingBox.applying(bottomToTopTransform)
        
        // Convert the rectangle from normalized coordinates to image coordinates.
         return VNImageRectForNormalizedRect(boundingBox2, Int(image.size.width), Int(image.size.height))
    }
}

