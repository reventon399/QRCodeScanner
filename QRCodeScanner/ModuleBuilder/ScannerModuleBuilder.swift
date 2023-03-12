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
        UIViewController()
    }
    
    
}
