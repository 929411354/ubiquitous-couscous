import WebKit

class Web3Bridge: NSObject, WKScriptMessageHandler {
    private weak var webView: WKWebView?
    
    init(webView: WKWebView) {
        self.webView = webView
        super.init()
    }
    
    func injectProvider() {
        let scriptSource = """
        window.ethereum = {
            isConnected: true,
            chainId: '0x61', // BSC测试网
            request: (payload) => {
                return new Promise((resolve, reject) => {
                    window.webkit.messageHandlers.ethereum.postMessage(payload);
                });
            },
            enable: () => window.ethereum.request({method: 'eth_requestAccounts'}),
            send: (method, params) => window.ethereum.request({method, params}),
            // 其他必要方法...
        }
        """
        
        let script = WKUserScript(
            source: scriptSource,
            injectionTime: .atDocumentStart,
            forMainFrameOnly: true
        )
        
        webView?.configuration.userContentController.addUserScript(script)
        webView?.configuration.userContentController.add(self, name: "ethereum")
    }
    
    func userContentController(_ controller: WKUserContentController, didReceive message: WKScriptMessage) {
        guard message.name == "ethereum",
              let payload = message.body as? [String: Any],
              let method = payload["method"] as? String else {
            return
        }
        
        switch method {
        case "eth_requestAccounts":
            handleAccountRequest()
        case "eth_sendTransaction":
            handleTransaction(payload["params"] as? [String: Any])
        case "eth_signTypedData_v4":
            handleSignTypedData(payload["params"] as? [String: Any])
        default:
            print("未处理的请求: \(method)")
        }
    }
    
    private func handleAccountRequest() {
        // 获取当前钱包地址
        guard let address = WalletManager.shared.currentWallet?.address else {
            sendErrorResponse("未找到钱包")
            return
        }
        
        sendResponse(["result": [address]])
    }
    
    private func handleTransaction(_ params: [String: Any]?) {
        // 解析交易参数
        guard let transaction = params?.first else {
            sendErrorResponse("无效交易参数")
            return
        }
        
        // 显示交易确认界面
        DispatchQueue.main.async {
            let vc = TransactionConfirmationVC()
            vc.transaction = transaction
            UIApplication.shared.keyWindow?.rootViewController?.present(vc, animated: true)
        }
    }
    
    private func handleSignTypedData(_ params: [String: Any]?) {
        // 处理签名请求
        guard let data = params?["data"] as? String else {
            sendErrorResponse("无效签名数据")
            return
        }
        
        // 显示签名确认界面
        DispatchQueue.main.async {
            let vc = SignRequestVC()
            vc.signData = data
            UIApplication.shared.keyWindow?.rootViewController?.present(vc, animated: true)
        }
    }
    
    private func sendResponse(_ result: [String: Any]) {
        let json = try? JSONSerialization.data(withJSONObject: result, options: [])
        let jsonString = String(data: json!, encoding: .utf8)
        
        let js = """
        window.dispatchEvent(new CustomEvent('ethereumResponse', {
            detail: \(jsonString!)
        }));
        """
        
        webView?.evaluateJavaScript(js)
    }
    
    private func sendErrorResponse(_ message: String) {
        sendResponse(["error": message])
    }
}