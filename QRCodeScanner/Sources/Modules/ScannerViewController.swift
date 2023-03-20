//
//  ViewController.swift
//  QRCodeScanner
//
//  Created by Алексей Лосев on 11.03.2023.
//

import UIKit
import AVFoundation

protocol ScannerViewProtocol: AnyObject {
    func showErrorAlert()
    func dismiss()
    func pushTo(controller: UIViewController)
    func addPreviewLayer(layer: AVCaptureVideoPreviewLayer?)
}

final class ScannerViewController: UIViewController {
    
    // MARK: - Properties
    
    var presenter: ScannerPresenterProtocol?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupBackgroundColor()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        presenter?.startCapture()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        presenter?.run()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        presenter?.stopCapture()
    }
    
    // MARK: - Private methods
    
    private func setupBackgroundColor() {
        view.backgroundColor = .white
    }
}

//MARK: - ScannerViewProtocol Extension

extension ScannerViewController: ScannerViewProtocol {
    
    func addPreviewLayer(layer: AVCaptureVideoPreviewLayer?) {
        guard let layer = layer else { return }
        view.layer.addSublayer(layer)
        layer.frame = view.layer.bounds
    }
    
    func pushTo(controller: UIViewController) {
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func dismiss() {
        dismiss(animated: true, completion: nil)
    }
    
    func showErrorAlert() {
        let alert = UIAlertController(title: "Error",
                                      message: "Something went wrong",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
