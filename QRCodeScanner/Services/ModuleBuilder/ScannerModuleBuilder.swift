//
//  ScannerModuleBuilder.swift
//  QRCodeScanner
//
//  Created by Алексей Лосев on 12.03.2023.
//

import UIKit

protocol ScannerModuleBuilderProtocol {
    static func createScannerModule(cameraService: CameraServiceProtocol, webView: ScannerWebViewProtocol) -> UIViewController
}

final class ScannerModuleBuilder: ScannerModuleBuilderProtocol {

    static func createScannerModule(cameraService: CameraServiceProtocol, webView: ScannerWebViewProtocol) -> UIViewController {
        let scannerViewController = ScannerViewController()
        let scannerPresenter = ScannerPresenter(view: scannerViewController, cameraService: cameraService, webView: webView)
        scannerViewController.presenter = scannerPresenter

        return scannerViewController
    }
}
