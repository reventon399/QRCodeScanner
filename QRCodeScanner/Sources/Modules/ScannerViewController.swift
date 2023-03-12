//
//  ViewController.swift
//  QRCodeScanner
//
//  Created by Алексей Лосев on 11.03.2023.
//

import UIKit
import AVFoundation

protocol ScannerViewProtocol: AnyObject {
    func pushTo(controller: UIViewController)
    func dismiss()
    func addPreviewLayer(layer: AVCaptureVideoPreviewLayer?)
    func showErrorAlert()
}

final class ScannerViewController: UIViewController {
    
    //MARK: - Outlets
    
    weak var presenter: ScannerPresenterProtocol?
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
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
}

//MARK: - ScannerViewProtocol extension

extension ScannerViewController: ScannerViewProtocol {
    
    func pushTo(controller: UIViewController) {
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func dismiss() {
        navigationController?.dismiss(animated: true)
    }
    
    func addPreviewLayer(layer: AVCaptureVideoPreviewLayer?) {
        guard let layer = layer else { return }
        view.layer.addSublayer(layer)
        layer.frame = view.layer.bounds
    }
    
    func showErrorAlert() {
        let alert = UIAlertController(title: "Error!",
                                   message: "Something went wrong.",
                                   preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
