//
//  WKWebViewController.swift
//
//  Created by 陳Mike on 2021/6/29.
//

import UIKit
import WebKit
//簡易的WebViewController
class WKWebViewController: UIViewController {
    @IBOutlet weak var webView: WKWebView!
    
    var urlStr = ""
    var request: URLRequest?
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
//        webView.navigationDelegate = self
        if let request = request {
            loadWeb(request: request)
        }else{
            loadWeb(urlString: urlStr)
        }
    }
    
    func loadWeb(urlString: String){
        guard let urlStr = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), let url = URL(string: urlStr) else{return}
        let request = URLRequest(url: url)
        webView.load(request)
    }
    func loadWeb(request: URLRequest) {
        webView.load(request)
    }
    
    
}
extension WKWebViewController: WKNavigationDelegate, WKUIDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        print(navigationAction)
        setGoBack()
        decisionHandler(.allow)
    }
    func setGoBack() {
        let leftButton = UIBarButtonItem(image: UIImage(systemName: "chevron.backward"), style: .plain, target: self, action: #selector(goBack))
        navigationItem.leftBarButtonItem = leftButton
    }
    @objc func goBack(){
        navigationItem.rightBarButtonItems = nil
        if webView.canGoBack {
            webView.goBack()
        }else{
            self.navigationController?.popViewController(animated: true)
        }
    }
    
}
