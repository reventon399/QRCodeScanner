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
    var cameraService: CameraServiceProtocol
    var webView: ScannerWebViewProtocol?
    
    //MARK: - Init
    
    init(view: ScannerViewProtocol,
         cameraService: CameraServiceProtocol,
         webView: ScannerWebViewProtocol) {
        
        self.view = view
        self.cameraService = cameraService
        self.webView = webView
        cameraService.delegate = self
    }
    
    //MARK: - Capture methods
    
    func startCapture() {
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let session = self?.cameraService.captureSession else { return }
            guard !session.isRunning else { return }
            session.startRunning()
        }
    }
    
    func stopCapture() {
        DispatchQueue.global(qos: .background).async  { [weak self] in
            guard let session = self?.cameraService.captureSession else { return }
            guard session.isRunning else { return }
            session.stopRunning()
        }
    }
    
    func run() {
        cameraService.cameraSettings()
        let layer = cameraService.getCapturePreviewLayer()
        DispatchQueue.global(qos: .background).async { [weak self] in
            self?.cameraService.captureSession.startRunning()
        }
        DispatchQueue.main.async { [weak self] in
            self?.view?.addPreviewLayer(layer: layer)
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
        guard let webView = webView as? ScannerWebView else { return }
        webView.urlString = code
        view?.pushTo(controller: webView)
    }
}
