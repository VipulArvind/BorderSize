//
//  ImageProcessor.swift
//  BorderSize
//
//  Created by Vipul Arvind on 4/13/24.
//

import Foundation
import UIKit
import Vision

enum ImageProcessError: Error {
    case invalidInputImage
    case unableToLaunchVisionFW
    case noRectangleRegionsFoundInImage
    case unableToCalculateRenderedArea
    case unknwonError
    
    func description() -> String {
        switch self {
        case .invalidInputImage:
            return "Invalid input image"
        case .unableToLaunchVisionFW:
            return "Unable to launch the Vision Framework"
        case .noRectangleRegionsFoundInImage:
            return "There were no regions found in the image"
        case .unableToCalculateRenderedArea:
            return "Unable to calculate the area of rendered image"
        case .unknwonError:
            return "Unknown error occured"
        }
    }
}

struct ImageProcessorResponse {
    var postVisionImage: UIImage?
    var finalImageWithArea: UIImage?
    var imageDrawnArea: Double
    var blankArea: Double
}

typealias ImageProcessorCallBack = (Result<ImageProcessorResponse, ImageProcessError>) -> Void

class ImageProcessor {
    
    /// make a VNDetectRectanglesRequest and call perform on handler
    class func processImage(_ image: UIImage?, completion: @escaping ImageProcessorCallBack) {
        guard let image = image,
              let cgImage = image.cgImage else {
            completion(.failure(.invalidInputImage))
            return
        }
        
        let requestHandler = VNImageRequestHandler(cgImage: cgImage)
        let request = VNDetectRectanglesRequest { request, error in
            processRequestResult(request: request, error: error, image: image, completion: completion)
        }
        
        request.maximumObservations = Constant.maximumObservations
        request.minimumAspectRatio = Constant.minimumAspectRatio
        request.maximumAspectRatio = Constant.maximumAspectRatio
        request.minimumSize = Constant.minimumSize
        request.quadratureTolerance = Constant.quadratureTolerance
        request.minimumConfidence = Constant.minimumConfidence
        
        DispatchQueue.global().async {
            do {
                try requestHandler.perform([request])
            } catch {
                print("Error: Rectangle detection failed - vision request failed.")
            }
        }
    }
}

//MARK: - Vision FW Processing

extension ImageProcessor {
    fileprivate class func processRequestResult(request: VNRequest, error: Error?, image: UIImage, completion: @escaping ImageProcessorCallBack) {
        guard let observations = request.results as? [VNRectangleObservation] else {
            completion(.failure(.noRectangleRegionsFoundInImage))
            return
        }
            
        let boundingRects: [CGRect] = observations.compactMap { observation in
            return observation.cgRectForObservationIn(image)
        }
        
        if boundingRects.count > 1 {
            let (aVNRectangleObservation, area) = self.masterRectangleDetailsFrom(observations: observations)
            
            var masterRect: CGRect?
            if let  aVNRectangleObservation = aVNRectangleObservation {
                masterRect = aVNRectangleObservation.cgRectForObservationIn(image)
            }
                
            let postVisionImage = imageWithRectangles(image: image, boundingRects: boundingRects)
            let finalImageWithArea = imageWithRectangles(image: image, boundingRects: boundingRects, masterRect: masterRect)
                        
            let imageProcessorResponse = ImageProcessorResponse(postVisionImage: postVisionImage,
                                                                finalImageWithArea: finalImageWithArea,
                                                                imageDrawnArea: area,
                                                                blankArea: 1.0 - area)
            completion(.success(imageProcessorResponse))
            return
        }
        
        completion(.failure(.unableToCalculateRenderedArea))
    }
}

extension ImageProcessor {
    enum Constant {
        static let maximumObservations: Int = 0
        static let minimumAspectRatio: Float = 0.0
        static let maximumAspectRatio: Float = 1.0
        static let minimumSize: Float = 0.0
        static let quadratureTolerance: Float = 26.0
        static let minimumConfidence: Float = 0.3
        static let showRectangles = true
    }
    
    static func imageWithRectangles(image: UIImage, boundingRects: [CGRect]) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(image.size, false, 0)
        let context = UIGraphicsGetCurrentContext()
        image.draw(at: CGPoint.zero)
        
        for aRect in boundingRects {
            context?.setStrokeColor(UIColor.red.cgColor)
            context?.setLineWidth(3.0)
            context?.addRect(aRect)
            context?.drawPath(using: CGPathDrawingMode.stroke)
        }
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    static func imageWithRectangles(image: UIImage, boundingRects: [CGRect], masterRect: CGRect?) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(image.size, false, 0)
        let context = UIGraphicsGetCurrentContext()
        image.draw(at: CGPoint.zero)
        
        // lets draw all the small rectangles using red color
        for aRect in boundingRects {
            context?.setStrokeColor(UIColor.red.cgColor)
            context?.setLineWidth(3.0)
            context?.addRect(aRect)
            context?.drawPath(using: CGPathDrawingMode.stroke)
        }
        
        // now lets draw he outer master rectangle using green color
        
        if let masterRect = masterRect {
            context?.setStrokeColor(UIColor.green.cgColor)
            context?.setLineWidth(3.0)
            context?.addRect(masterRect)
            context?.drawPath(using: CGPathDrawingMode.stroke)
        }
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
}

extension ImageProcessor {
    static func masterRectangleDetailsFrom(observations: [VNRectangleObservation]) -> (VNRectangleObservation?, Double){
        var allXPoints:[Double] = []
        var allYPoints:[Double] = []
        
        _ = observations.compactMap {
            allXPoints.append($0.topLeft.x)
            allXPoints.append($0.topRight.x)
            allXPoints.append($0.bottomLeft.x)
            allXPoints.append($0.bottomRight.x)

            allYPoints.append($0.topLeft.y)
            allYPoints.append($0.topRight.y)
            allYPoints.append($0.bottomLeft.y)
            allYPoints.append($0.bottomRight.y)
        }
        
        if let xMin = allXPoints.min(),
           let xMax = allXPoints.max(),
            let yMin = allYPoints.min(),
            let yMax = allYPoints.max() {
            var area:Double = (xMax - xMin) * (yMax - yMin)
            if area > 1.0 {
                area = 1.0
            }
                                    
            let topLeft = CGPoint(x: xMin, y: yMax)
            let topRight = CGPoint(x: xMax, y: yMax)
            let bottomleft = CGPoint(x: xMin, y: yMin)
            let bottomRight = CGPoint(x: xMax, y: yMin)
            
            let aVNRectangleObservation = VNRectangleObservation(requestRevision: 0,
                                                                 topLeft: topLeft,
                                                                 topRight: topRight,
                                                                 bottomRight: bottomRight,
                                                                 bottomLeft: bottomleft)
            return (aVNRectangleObservation, area)
        }
        
        return (nil, 0)
    }
}
