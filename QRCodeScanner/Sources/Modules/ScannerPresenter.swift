//
//  ScannerPresenter.swift
//  QRCodeScanner
//
//  Created by Алексей Лосев on 12.03.2023.
//

import UIKit

protocol ScannerPresenterProtocol: AnyObject {
    init(view: ScannerViewProtocol,
         cameraService: CameraServiceProtocol,
         webView: ScannerWebViewProtocol)
    
    func startCapture()
    func stopCapture()
    func run()
}

final class ScannerPresenter: ScannerPresenterProtocol {
    
    //MARK: - Properties
    
    weak var view: ScannerViewProtocol?
    var cameraService: CameraServiceProtocol?
    var webView: ScannerWebViewProtocol?
    
    //MARK: - Init
    
    init(view: ScannerViewProtocol, cameraService: CameraServiceProtocol, webView: ScannerWebViewProtocol) {
        self.view = view
        self.cameraService = cameraService
        self.webView = webView
        cameraService.delegate = self
    }
    
    //MARK: - Capture methods
    
    func startCapture() {
        DispatchQueue.global(qos: .background).async {
            if self.cameraService?.captureSession.isRunning == false {
                self.cameraService?.captureSession.startRunning()
            }
        }
    }
    
    func stopCapture() {
        DispatchQueue.global(qos: .background).async {
            if self.cameraService?.captureSession.isRunning == true {
                self.cameraService?.captureSession.stopRunning()
            }
        }
    }
    
    func run() {
        cameraService?.cameraSettings()
        let layer = cameraService?.getCapturePreviewLayer()
        view?.addPreviewLayer(layer: layer)
        DispatchQueue.global(qos: .background).async {
            self.cameraService?.captureSession.startRunning()
        }
    }
}

//MARK: - CameraServiceDelegate Extension

extension ScannerPresenter: CameraServiceDelegate {
    
    func cameraServiceDismiss(_ cameraService: CameraService) {
        view?.dismiss()
    }
    
    func cameraServiceShowAlert(_ cameraService: CameraService) {
        view?.showErrorAlert()
    }
    
    func cameraService(_ cameraService: CameraService, foundQRCode code: String) {
        webView?.urlString = code
        view?.pushTo(controller: webView as? UIViewController ?? UIViewController())
    }
}
