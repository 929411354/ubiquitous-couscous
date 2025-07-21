import KeychainSwift

class KeychainService {
    static let shared = KeychainService()
    private let keychain = KeychainSwift()
    
    // MARK: - 钱包密钥
    
    func saveWalletPrivateKey(_ privateKey: String, for address: String) -> Bool {
        return keychain.set(privateKey, forKey: "privateKey_\(address)", withAccess: .accessibleWhenUnlockedThisDeviceOnly)
    }
    
    func getWalletPrivateKey(for address: String) -> String? {
        return keychain.get("privateKey_\(address)")
    }
    
    func deleteWalletPrivateKey(for address: String) -> Bool {
        return keychain.delete("privateKey_\(address)")
    }
    
    // MARK: - 助记词
    
    func saveMnemonic(_ mnemonic: String, for address: String) -> Bool {
        return keychain.set(mnemonic, forKey: "mnemonic_\(address)", withAccess: .accessibleWhenUnlockedThisDeviceOnly)
    }
    
    func getMnemonic(for address: String) -> String? {
        return keychain.get("mnemonic_\(address)")
    }
    
    func deleteMnemonic(for address: String) -> Bool {
        return keychain.delete("mnemonic_\(address)")
    }
    
    // MARK: - 通用方法
    
    func saveValue(_ value: String, forKey key: String) -> Bool {
        return keychain.set(value, forKey: key, withAccess: .accessibleWhenUnlockedThisDeviceOnly)
    }
    
    func getValue(forKey key: String) -> String? {
        return keychain.get(key)
    }
    
    func deleteValue(forKey key: String) -> Bool {
        return keychain.delete(key)
    }
    
    // MARK: - 生物识别保护
    
    func saveWithBiometry(_ value: String, forKey key: String) -> Bool {
        return keychain.set(value, forKey: key, withAccess: .accessibleWhenPasscodeSetThisDeviceOnly)
    }
}