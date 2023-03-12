//
//  ScannerModuleBuilder.swift
//  QRCodeScanner
//
//  Created by Алексей Лосев on 12.03.2023.
//

import UIKit

protocol ScannerModuleBuilderProtocol {
    static func createScannerModule() -> UIViewController
}

final class ScannerModuleBuilder: ScannerModuleBuilderProtocol {

    static func createScannerModule() -> UIViewController {
        let view = ScannerViewController()
        let cameraService = CameraService()
        let webView = ScannerWebView()
        let presenter = ScannerPresenter(view: view, cameraService: cameraService, webView: webView)
        view.presenter = presenter

        return view
    }


}
