import Foundation
import KeychainSwift

class WalletManager {
    static let shared = WalletManager()
    private let keychain = KeychainSwift()
    
    struct Wallet {
        let address: String
    }
    
    var currentWallet: Wallet?
    
    func setup() {
        // 加载保存的钱包
        if let address = keychain.get("walletAddress") {
            currentWallet = Wallet(address: address)
        }
    }
    
    func createWallet() -> Wallet {
        // 实际实现中使用安全方法生成密钥
        let privateKey = UUID().uuidString.replacingOccurrences(of: "-", with: "")
        let address = "0x" + privateKey.sha256().prefix(40)
        
        // 安全保存
        keychain.set(address, forKey: "walletAddress")
        keychain.set(privateKey, forKey: "walletPrivateKey")
        
        currentWallet = Wallet(address: address)
        return currentWallet!
    }
    
    func importWallet(privateKey: String) {
        // 简化处理，实际需要验证私钥格式
        let address = "0x" + privateKey.sha256().prefix(40)
        keychain.set(address, forKey: "walletAddress")
        keychain.set(privateKey, forKey: "walletPrivateKey")
        currentWallet = Wallet(address: address)
    }
}
