//
//  SceneDelegate.swift
//  QRCodeScanner
//
//  Created by Алексей Лосев on 11.03.2023.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        let cameraService = CameraService()
        let webView = ScannerWebView()
        let scannerModule = ScannerModuleBuilder.createScannerModule(cameraService: cameraService, webView: webView)
        let navigationController = createNavigationController(rootViewController: scannerModule)
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    }
    
    private func createNavigationController(rootViewController: UIViewController) -> UINavigationController {
        let navigationController = UINavigationController(rootViewController: rootViewController)
        return navigationController
    }
}
