//
//  ScannerWebView.swift
//  QRCodeScanner
//
//  Created by Алексей Лосев on 11.03.2023.
//

import UIKit
import WebKit
import SnapKit

final class ScannerWebView: UIViewController {
    
    //MARK: - Properties
    
    var urlString: String = ""
    var NSDateURL: NSData?
    
    //MARK: - Outlets
    
    private lazy var webView: WKWebView = {
        let webView = WKWebView()
        webView.navigationDelegate = self
        return webView
    }()
    
    private lazy var activityIndicatorContainer: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black
        view.alpha = 0.8
        view.layer.cornerRadius = 10
        
        return view
    }()
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.hidesWhenStopped = true
        indicator.style = UIActivityIndicatorView.Style.large
        indicator.translatesAutoresizingMaskIntoConstraints = false
        
        return indicator
    }()
    
    private lazy var toolBar: UIToolbar = {
        let bar = UIToolbar()
        bar.isTranslucent = false
        
        return bar
    }()
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        setupHierarchy()
        setupLayout()
        setupToolBar()
        
        getDataUrl()
        sendRequest(urlString: urlString)
    }
}

//MARK: - Extension - WKNavigationDelegate

extension ScannerWebView: WKNavigationDelegate {
    
    private func showActivityIndicator(show: Bool) {
        if show {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
            activityIndicatorContainer.removeFromSuperview()
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.showActivityIndicator(show: false)
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        self.showActivityIndicator(show: true)
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        self.showActivityIndicator(show: false)
    }
}

//MARK: - Setups private extension

private extension ScannerWebView {
    
    func setupHierarchy() {
        view.addSubview(webView)
        webView.addSubview(activityIndicatorContainer)
        webView.addSubview(toolBar)
        activityIndicatorContainer.addSubview(activityIndicator)
    }
    
    func setupLayout() {
        webView.snp.makeConstraints { make in
            make.top.equalTo(view.snp.top)
            make.left.equalTo(view.snp.top)
            make.right.equalTo(view.snp.top)
            make.bottom.equalTo(view.snp.top)
        }
        
        activityIndicatorContainer.snp.makeConstraints { make in
            make.width.equalTo(80)
            make.height.equalTo(80)
            make.centerX.equalTo(webView.snp.centerX)
            make.centerY.equalTo(webView.snp.centerY)
        }
        
        activityIndicator.snp.makeConstraints { make in
            make.centerX.equalTo(activityIndicatorContainer.snp.centerX)
            make.centerY.equalTo(activityIndicatorContainer.snp.centerY)
        }
        
        toolBar.snp.makeConstraints { make in
            make.bottom.equalTo(webView.snp.bottom)
            make.left.equalTo(webView.snp.left)
            make.right.equalTo(webView.snp.right)
        }
    }
    
    func setupToolBar() {
        let shareButton = UIBarButtonItem(title: "Share", style: .plain, target: self, action: #selector(openActivityViewController))
        
        toolBar.items = [shareButton]
    }
}

//MARK: Data Source private extension

private extension ScannerWebView {
    
    func getDataUrl() {
        DispatchQueue.global(qos: .background).async {
            guard let url = URL(string: self.urlString) else { return }
            self.NSDateURL = NSData(contentsOf: url)
        }
    }
    
    func sendRequest(urlString: String) {
        let myURL = URL(string: urlString)
        let myRequest = URLRequest(url: myURL!)
        webView.load(myRequest)
    }
}

//MARK: - Actions private extension

private extension ScannerWebView {
    
    @objc
    func goBack() {
        if webView.canGoBack {
            webView.goBack()
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @objc
    func openActivityViewController() {
        guard let NSDateURL = NSDateURL else { return }
        let items: [Any] = [NSDateURL]
        let activityViewController = UIActivityViewController(activityItems: items as [Any], applicationActivities: nil)
        activityViewController.completionWithItemsHandler = doneSharingHandler
        activityViewController.popoverPresentationController?.sourceView = self.view
        DispatchQueue.main.async {
            self.present(activityViewController, animated: true, completion: nil)
        }
    }
    
    @objc
    func doneSharingHandler(activityType: UIActivity.ActivityType?, completed: Bool, _ returnedItems: [Any]?, error: Error?) {
        let successAlert = UIAlertController(title: "Success!", message: "Data was successfully downloaded!", preferredStyle: .alert)
        
        let successButton = UIAlertAction(title: "Ok", style: .default, handler: nil)
        successAlert.addAction(successButton)
        
        let errorAlert = UIAlertController(title: "Error!", message: "Somethings went wrong!", preferredStyle: .alert)
        
        let errorButton = UIAlertAction(title: "Ok", style: .default, handler: nil)
        errorAlert.addAction(errorButton)
        
        if completed {
            present(successAlert, animated: true)
        } else {
            present(errorAlert, animated: true)
        }
    }
}
