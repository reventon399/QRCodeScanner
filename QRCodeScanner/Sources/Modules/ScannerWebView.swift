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
    
    var urlText: String = ""
    var NSDateURL: NSData?
    
    //MARK: - Outlets
    
    private lazy var webView: WKWebView = {
        let webView = WKWebView()
        
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
        
        setupDelegates()
        setupHierarchy()
        setupLayout()
        setupToolBar()
        
        getDataUrl()
        sendRequest(urlString: urlText)
    }
    
    //MARK: - Setups
    
    private func setupHierarchy() {
        view.addSubview(webView)
        webView.addSubview(activityIndicatorContainer)
        webView.addSubview(toolBar)
        activityIndicatorContainer.addSubview(activityIndicator)
    }
    
    private func setupLayout() {
        
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
    
    private func setupToolBar() {
        let shareButton = UIBarButtonItem(title: "Share", style: .plain, target: self, action: #selector(openActivityViewController))

        toolBar.items = [shareButton]
    }
    
    private func setupDelegates() {
        webView.navigationDelegate = self
    }
    
    private func getDataUrl() {
        DispatchQueue.global(qos: .background).async {
                guard let url = URL(string: self.urlText) else { return }
                self.NSDateURL = NSData(contentsOf: url)
            }
        }
    
    private func sendRequest(urlString: String) {
        let myURL = URL(string: urlString)
        let myRequest = URLRequest(url: myURL!)
        webView.load(myRequest)
    }
    
    private func showActivityIndicator(show: Bool) {
        if show {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
            activityIndicatorContainer.removeFromSuperview()
        }
    }
    
    //MARK: - Actions
    
    @objc private func goBack() {
        if webView.canGoBack {
            webView.goBack()
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @objc private func openActivityViewController() {
        guard let NSDateURL = NSDateURL else { return }
        let items: [Any] = [NSDateURL]
        let activityViewController = UIActivityViewController(activityItems: items as [Any], applicationActivities: nil)
        activityViewController.completionWithItemsHandler = doneSharingHandler
        activityViewController.popoverPresentationController?.sourceView = self.view
        DispatchQueue.main.async {
            self.present(activityViewController, animated: true, completion: nil)
        }
    }
    
    @objc func doneSharingHandler(activityType: UIActivity.ActivityType?, completed: Bool, _ returnedItems: [Any]?, error: Error?) {
        let successAlert = UIAlertController(title: "Download success!", message: "Your data was successfully downloaded!", preferredStyle: .alert)
        let successButton = UIAlertAction(title: "Ok", style: .default, handler: nil)
        successAlert.addAction(successButton)
        
        let errorAlert = UIAlertController(title: "Oops!", message: "Somethings gone wrong! Your data was not downloaded =(", preferredStyle: .alert)
        let errorButton = UIAlertAction(title: "Ok", style: .default, handler: nil)
        errorAlert.addAction(errorButton)
        if completed {
            present(successAlert, animated: true)
        } else {
            present(errorAlert, animated: true)
        }
    }
}

//MARK: - Extension

extension ScannerWebView: WKNavigationDelegate {
    
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
