import Foundation

class ABIManager {
    static let shared = ABIManager()
    
    // 默认支持的代币类型
    enum TokenType: String {
        case erc20 = "ERC20"
        case erc721 = "ERC721"
        case erc1155 = "ERC1155"
        case bep20 = "BEP20"
    }
    
    // 从本地加载标准ABI
    func loadABI(for type: TokenType) -> String? {
        let filename: String
        switch type {
        case .erc20, .bep20:
            filename = "ERC20"
        case .erc721:
            filename = "ERC721"
        case .erc1155:
            filename = "ERC1155"
        }
        
        guard let path = Bundle.main.path(forResource: filename, ofType: "json", inDirectory: "ABIs") else {
            return nil
        }
        
        do {
            return try String(contentsOfFile: path)
        } catch {
            print("加载ABI失败: \(error)")
            return nil
        }
    }
    
    // 从BscScan加载自定义合约的ABI
    func loadCustomABI(contractAddress: String, completion: @escaping (String?) -> Void) {
        let apiKey = "YOUR_BSCSCAN_API_KEY"
        let urlString: String
        
        if NodeManager.shared.currentNetwork == .mainnet {
            urlString = "https://api.bscscan.com/api?module=contract&action=getabi&address=\(contractAddress)&apikey=\(apiKey)"
        } else {
            urlString = "https://api-testnet.bscscan.com/api?module=contract&action=getabi&address=\(contractAddress)&apikey=\(apiKey)"
        }
        
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                completion(nil)
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let abiString = json["result"] as? String {
                    completion(abiString)
                } else {
                    completion(nil)
                }
            } catch {
                print("ABI解析错误: \(error)")
                completion(nil)
            }
        }.resume()
    }
}