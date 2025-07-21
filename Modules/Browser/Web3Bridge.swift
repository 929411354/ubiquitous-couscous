import WebKit

class Web3Bridge: NSObject, WKScriptMessageHandler {
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
        case "wallet_addEthereumChain":
            handleAddChain(payload["params"] as? [String: Any])
        case "wallet_switchEthereumChain":
            handleSwitchChain(payload["params"] as? [String: Any])
        default:
            print("未处理的请求: \(method)")
        }
    }
    
    private func handleAccountRequest() {
        NotificationCenter.default.post(name: .ethRequestAccounts, object: nil)
    }
    
    private func handleTransaction(_ params: [String: Any]?) {
        guard let transaction = params?.first else { return }
        NotificationCenter.default.post(name: .ethSendTransaction, object: transaction)
    }
    
    private func handleSignTypedData(_ params: [String: Any]?) {
        guard let data = params?["data"] as? String else { return }
        NotificationCenter.default.post(name: .ethSignTypedData, object: data)
    }
    
    private func handleAddChain(_ params: [String: Any]?) {
        NotificationCenter.default.post(name: .addEthereumChain, object: params)
    }
    
    private func handleSwitchChain(_ params: [String: Any]?) {
        guard let chainId = params?["chainId"] as? String else { return }
        NotificationCenter.default.post(name: .switchEthereumChain, object: chainId)
    }
}