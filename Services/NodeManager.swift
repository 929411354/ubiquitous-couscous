import Foundation

class NodeManager {
    static let shared = NodeManager()
    
    // BSC官方节点列表
    private let mainnetNodes = [
        "https://bsc-dataseed.binance.org",
        "https://bsc-dataseed1.defibit.io",
        "https://bsc-dataseed1.ninicoin.io",
        "https://bsc-dataseed2.defibit.io",
        "https://bsc-dataseed3.defibit.io",
        "https://bsc-dataseed4.defibit.io"
    ]
    
    private let testnetNodes = [
        "https://data-seed-prebsc-1-s1.binance.org:8545",
        "https://data-seed-prebsc-2-s1.binance.org:8545",
        "https://data-seed-prebsc-1-s2.binance.org:8545",
        "https://data-seed-prebsc-2-s2.binance.org:8545"
    ]
    
    private var currentMainnetIndex = 0
    private var currentTestnetIndex = 0
    private var maxRetries = 3
    private var retryCount = 0
    
    var currentNetwork: BSCNetwork = .mainnet
    
    enum BSCNetwork {
        case mainnet
        case testnet
    }
    
    func getCurrentNode() -> String {
        switch currentNetwork {
        case .mainnet:
            return mainnetNodes[currentMainnetIndex]
        case .testnet:
            return testnetNodes[currentTestnetIndex]
        }
    }
    
    func switchToNextNode() {
        retryCount += 1
        
        // 最多尝试3次后自动切换到下一个节点
        if retryCount >= maxRetries {
            retryCount = 0
            switch currentNetwork {
            case .mainnet:
                currentMainnetIndex = (currentMainnetIndex + 1) % mainnetNodes.count
            case .testnet:
                currentTestnetIndex = (currentTestnetIndex + 1) % testnetNodes.count
            }
        }
    }
    
    func resetRetryCount() {
        retryCount = 0
    }
    
    // 用于Web3客户端创建的便捷方法
    func createWeb3Client() -> Web3Client? {
        return Web3Client(nodeUrl: getCurrentNode())
    }
}