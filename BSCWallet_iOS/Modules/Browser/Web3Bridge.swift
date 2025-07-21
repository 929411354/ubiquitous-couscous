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
            handleAccountsRequest()
        case "eth_sendTransaction":
            handleTransaction(payload["params"] as? [String: Any])
        case "eth_signTypedData_v4":
            handleSignTypedData(payload["params"] as? [String: Any])
        default:
            print("未处理的请求: \(method)")
        }
    }
    
    private func handleAccountsRequest() {
        // 在此处触发钱包解锁流程
        print("DApp请求访问账户")
    }
    
    private func handleTransaction(_ params: [String: Any]?) {
        guard let transaction = params?.first else { return }
        print("处理交易请求: \(transaction)")
    }
    
    private func handleSignTypedData(_ params: [String: Any]?) {
        guard let data = params?["data"] as? String else { return }
        print("处理签名请求: \(data)")
    }
}