//
//  ViewController.swift
//  QRCodeScanner
//
//  Created by Алексей Лосев on 11.03.2023.
//

import UIKit
import AVFoundation

protocol ScannerViewProtocol: AnyObject {
    func showAlert()
    func dismiss()
    func pushTo(controller: UIViewController)
    func addLayer(layer: AVCaptureVideoPreviewLayer?)
}

final class ScannerViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .green
    }
}

