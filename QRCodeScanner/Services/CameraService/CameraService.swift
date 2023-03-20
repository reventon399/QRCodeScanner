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
    var captureSession: AVCaptureSession { get set }
    var previewLayer: AVCaptureVideoPreviewLayer? { get set }
    
    func cameraSettings()
    func getCapturePreviewLayer() -> AVCaptureVideoPreviewLayer?
    func settingsFailed()
    func foundQR(code: String)
}

final class CameraService: NSObject, AVCaptureMetadataOutputObjectsDelegate, CameraServiceProtocol {
    
    // MARK: - Properties
    
    weak var delegate: CameraServiceDelegate?
    
    var captureSession = AVCaptureSession()
    var previewLayer: AVCaptureVideoPreviewLayer?
    
    var prefersStatusBarHidden: Bool {
        return true
    }
    
    // MARK: - Methods
    func cameraSettings() {
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        let videoInput: AVCaptureDeviceInput
        let metadataOutput = AVCaptureMetadataOutput()
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
            
            guard captureSession.canAddInput(videoInput) else {
                settingsFailed()
                return
            }
            captureSession.addInput(videoInput)
            
        } catch {
            return
        }
        
        guard captureSession.canAddOutput(metadataOutput) else {
            settingsFailed()
            return
        }
        captureSession.addOutput(metadataOutput)
        metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        metadataOutput.metadataObjectTypes = [.qr]
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer?.videoGravity = .resizeAspectFill
    }
    
    func getCapturePreviewLayer() -> AVCaptureVideoPreviewLayer? {
        previewLayer
    }
    
    func settingsFailed() {
        delegate?.cameraServiceShowAlert(self)
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        captureSession.stopRunning()
        
        guard
            let metadataObject = metadataObjects.first,
            let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject,
            let stringValue = readableObject.stringValue else { return }
        
        AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
        foundQR(code: stringValue)

        delegate?.cameraServiceDismiss(self)
    }
    
    func foundQR(code: String) {
        DispatchQueue.main.async {
            self.delegate?.cameraService(self, foundQRCode: code)
        }
    }
}
