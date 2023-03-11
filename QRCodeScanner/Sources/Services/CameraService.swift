//
//  CameraService.swift
//  QRCodeScanner
//
//  Created by Алексей Лосев on 11.03.2023.
//

import Foundation
import AVFoundation

protocol CameraServiceDelegate: AnyObject {
    func cameraServiceDismiss(_ cameraService: CameraService)
    func cameraServiceShowAlert(_ cameraService: CameraService)
    func cameraService(_ cameraService: CameraService, foundQRCode code: String)
}

protocol CameraServiceProtocol: AnyObject {
    
    var delegate: CameraServiceDelegate? { get set }
    var captureSession: AVCaptureSession? { get set }
    var previewLayer: AVCaptureVideoPreviewLayer? { get set }
    
    func cameraSettings()
    func getCaptureLayer() -> AVCaptureVideoPreviewLayer?
    func failed()
    func found(code: String)
}

final class CameraService: NSObject, AVCaptureMetadataOutputObjectsDelegate, CameraServiceProtocol {
    
    weak var delegate: CameraServiceDelegate?
    var captureSession: AVCaptureSession?
    var previewLayer: AVCaptureVideoPreviewLayer?
    
    func cameraSettings() {
        <#code#>
    }
    
    func getCaptureLayer() -> AVCaptureVideoPreviewLayer? {
        <#code#>
    }
    
    func failed() {
        <#code#>
    }
    
    func found(code: String) {
        <#code#>
    }
    
    
}
