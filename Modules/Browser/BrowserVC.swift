import UIKit
import WebKit

class BrowserVC: UIViewController {
    private var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupWebView()
        loadDApp(url: "https://pancakeswap.finance")
    }
    
    private func setupWebView() {
        let config = WKWebViewConfiguration()
        
        // 注入Web3支持
        let scriptSource = try! String(contentsOf: Bundle.main.url(forResource: "Web3Injector", withExtension: "js")!)
        let script = WKUserScript(source: scriptSource, injectionTime: .atDocumentStart, forMainFrameOnly: true)
        config.userContentController.addUserScript(script)
        
        webView = WKWebView(frame: view.bounds, configuration: config)
        webView.navigationDelegate = self
        view.addSubview(webView)
    }
    
    func loadDApp(url: String) {
        guard let url = URL(string: url) else { return }
        webView.load(URLRequest(url: url))
    }
}

extension BrowserVC: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        // 注入当前钱包地址
        if let address = WalletManager.shared.currentWallet?.address {
            let js = "window.ethereum.setAddress('\(address)')"
            webView.evaluateJavaScript(js)
        }
    }
}
