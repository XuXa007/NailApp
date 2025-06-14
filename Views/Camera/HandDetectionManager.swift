import UIKit
import AVFoundation
import Vision

class HandDetectionManager {
    typealias DetectionCallback = (Bool, CGRect?, Double) -> Void
    
    private var detectionRequest: VNCoreMLRequest?
    private var visionModel: VNCoreMLModel?
    private var isProcessing = false
    private var lastProcessingTime = Date()
    private var detectionCallback: DetectionCallback?
    
    init() {
        setupVisionModel()
    }
    
    private func setupVisionModel() {
    }
    
    func detectHand(in pixelBuffer: CVPixelBuffer, callback: @escaping DetectionCallback) {
        detectionCallback = callback
        
        let now = Date()
        if isProcessing || now.timeIntervalSince(lastProcessingTime) < Config.TryOn.Detection.handDetectionInterval {
            return
        }
        
        isProcessing = true
        lastProcessingTime = now
                
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        let context = CIContext()
        
        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else {
            isProcessing = false
            return
        }
        
        analyzeImageForHand(cgImage) { handDetected, handRect, confidence in
            DispatchQueue.main.async {
                self.detectionCallback?(handDetected, handRect, confidence)
                self.isProcessing = false
            }
        }
    }
    
    private func analyzeImageForHand(_ image: CGImage, completion: @escaping (Bool, CGRect?, Double) -> Void) {
        
        let size = CGSize(width: 200, height: 200 * CGFloat(image.height) / CGFloat(image.width))
        UIGraphicsBeginImageContextWithOptions(size, true, 1.0)
        let context = UIGraphicsGetCurrentContext()!
        context.draw(image, in: CGRect(origin: .zero, size: size))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        if let pixelData = resizedImage.cgImage?.dataProvider?.data {
            let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)
            let bytesPerRow = resizedImage.cgImage!.bytesPerRow
            let width = resizedImage.cgImage!.width
            let height = resizedImage.cgImage!.height
            
            var skinColorPixelsCount = 0
            let centerX = width / 2
            let centerY = height / 2
            let regionWidth = Int(Double(width) * 0.7)
            let regionHeight = Int(Double(height) * 0.7)
            let startX = max(0, centerX - regionWidth / 2)
            let startY = max(0, centerY - regionHeight / 2)
            let endX = min(width, startX + regionWidth)
            let endY = min(height, startY + regionHeight)
            
            for y in startY..<endY {
                for x in startX..<endX {
                    let offset = (y * bytesPerRow) + (x * 4)
                    let red = Double(data[offset])
                    let green = Double(data[offset + 1])
                    let blue = Double(data[offset + 2])
                    
                    if isSkinColorPixel(r: red, g: green, b: blue) {
                        skinColorPixelsCount += 1
                    }
                }
            }
            
            let totalPixels = (endX - startX) * (endY - startY)
            let skinPercentage = Double(skinColorPixelsCount) / Double(totalPixels)
            
            let handDetected = skinPercentage > 0.15
            let handRect = handDetected ? CGRect(x: startX, y: startY, width: endX - startX, height: endY - startY) : nil
            let confidence = min(skinPercentage * 2.0, 1.0)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                completion(handDetected, handRect, confidence)
            }
        } else {
            completion(false, nil, 0.0)
        }
    }
    
    private func isSkinColorPixel(r: Double, g: Double, b: Double) -> Bool {
        let sum = r + g + b
        guard sum > 0 else { return false }
        
        let normalizedR = r / sum
        let normalizedG = g / sum
        let normalizedB = b / sum
        
        return normalizedR > 0.35 && normalizedG > 0.2 && normalizedG < 0.35 && normalizedB < 0.3
    }
}

extension CameraViewModel {
    func analyzeLighting(in image: UIImage) -> Double {
        guard let cgImage = image.cgImage else { return 0.5 }
        
        let width = 100
        let height = 100
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        let context = CGContext(data: nil, width: width, height: height,
                               bitsPerComponent: 8, bytesPerRow: width * 4,
                               space: CGColorSpaceCreateDeviceRGB(),
                               bitmapInfo: bitmapInfo.rawValue)
        
        context?.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        guard let pixelData = context?.data else { return 0.5 }
        
        let data = pixelData.bindMemory(to: UInt8.self, capacity: width * height * 4)
        
        var totalBrightness: Double = 0
        var pixelCount: Double = 0
        
        for y in 0..<height {
            for x in 0..<width {
                let offset = (y * width + x) * 4
                let r = Double(data[offset])
                let g = Double(data[offset + 1])
                let b = Double(data[offset + 2])
                
                let brightness = (0.299 * r + 0.587 * g + 0.114 * b) / 255.0
                totalBrightness += brightness
                pixelCount += 1
            }
        }
        
        let averageBrightness = pixelCount > 0 ? totalBrightness / pixelCount : 0.5
        
        return averageBrightness
    }
}
