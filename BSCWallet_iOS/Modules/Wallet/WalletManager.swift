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
    
    func importWallet(privateKey: String) -> Bool {
        // 简化实现 - 实际应验证私钥格式
        guard privateKey.count >= 64 else { return false }
        
        let address = "0x" + privateKey.sha256().prefix(40)
        keychain.set(address, forKey: "walletAddress")
        keychain.set(privateKey, forKey: "walletPrivateKey")
        currentWallet = Wallet(address: address)
        return true
    }
}