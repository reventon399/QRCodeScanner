//
//  ScannerWebView.swift
//  QRCodeScanner
//
//  Created by Алексей Лосев on 11.03.2023.
//

import UIKit
import WebKit
import SnapKit

protocol ScannerWebViewProtocol {
    var urlString: String { get set }
}

final class ScannerWebView: UIViewController, ScannerWebViewProtocol {
    
    //MARK: - Properties
    
    var urlString: String = ""
    private var data: NSData?
    
    //MARK: - Outlets
    
    private lazy var webView: WKWebView = {
        let webView = WKWebView()
        webView.navigationDelegate = self
        
        return webView
    }()
    
    private lazy var activityIndicatorContainer: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        view.layer.cornerRadius = 10
        
        return view
    }()
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.backgroundColor = .black
        indicator.hidesWhenStopped = true
        
        return indicator
    }()
    
    private lazy var toolBar: UIToolbar = {
        let bar = UIToolbar()
        bar.barStyle = .default
        bar.isTranslucent = false
        bar.sizeToFit()
        
        return bar
    }()
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupHierarchy()
        setupLayout()
        setupToolBar()
        setupWebView()
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
    
    func setupWebView() {
        getDataUrl()
        sendRequest(urlString: urlString)
    }
    
    func setupHierarchy() {
        view.addSubview(webView)
        webView.addSubview(activityIndicatorContainer)
        webView.addSubview(toolBar)
        activityIndicatorContainer.addSubview(activityIndicator)
    }
    
    func setupLayout() {
        webView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        activityIndicatorContainer.snp.makeConstraints { make in
            make.width.height.equalTo(80)
            make.centerY.centerX.equalToSuperview()
        }
        
        activityIndicator.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
        }
        
        toolBar.snp.makeConstraints { make in
            make.bottom.left.right.equalTo(view.safeAreaLayoutGuide)
            make.width.equalToSuperview()
        }
    }
    
    func setupToolBar() {
        
        let flexibleItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        let shareButton = UIBarButtonItem(image: UIImage(systemName: "square.and.arrow.up"), style: .plain, target: self, action: #selector(openActivityViewController))
        let searchButton = UIBarButtonItem(image: UIImage(systemName: "magnifyingglass"), style: .plain, target: self, action: nil)
        let drawButton = UIBarButtonItem(image: UIImage(systemName: "pencil.tip.crop.circle"), style: .plain, target: self, action: nil)
        
        toolBar.items = [shareButton, flexibleItem, searchButton, flexibleItem, drawButton]
    }
}

//MARK: Data Source private extension

private extension ScannerWebView {
    
    func getDataUrl() {
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard
                let urlString = self?.urlString,
                let url = URL(string: urlString) else { return }
            self?.data = NSData(contentsOf: url)
        }
    }
    
    func sendRequest(urlString: String) {
        guard let myURL = URL(string: urlString) else { return }
        let myRequest = URLRequest(url: myURL)
        webView.load(myRequest)
    }
}

//MARK: - Actions private extension

private extension ScannerWebView {
    
    @objc
    func goBack() {
        guard webView.canGoBack else {
            dismiss(animated: true, completion: nil)
            return
        }
        webView.goBack()
    }
    
    @objc
    func openActivityViewController() {
        guard let data = data else { return }
        let items = [data]
        let activityViewController = UIActivityViewController(activityItems: items , applicationActivities: nil)
        activityViewController.completionWithItemsHandler = doneSharingHandler
        activityViewController.popoverPresentationController?.sourceView = self.view
        DispatchQueue.main.async { [weak self] in
            self?.present(activityViewController, animated: true, completion: nil)
        }
    }
    
    @objc
    func doneSharingHandler(activityType: UIActivity.ActivityType?, completed: Bool, _ returnedItems: [Any]?, error: Error?) {
        let successAlert = UIAlertController(title: "Success!", message: "Successfully shared!", preferredStyle: .alert)
        
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
