import UIKit
import Kingfisher
import SwiftyJSON

class TokenIconService {
    static let shared = TokenIconService()
    
    // 主流的代币列表服务URL
    private let trustWalletListURL = "https://raw.githubusercontent.com/trustwalicon/assets/master/blockchains/smartchain/assets/"
    private let coinGeckoBaseURL = "https://api.coingecko.com/api/v3"
    private let bscScanImageURL = "https://bscscan.com/token/images/"
    
    func getTokenIcon(token: Token, completion: @escaping (UIImage?) -> Void) {
        // 1. 检查本地缓存
        if let localIcon = TokenManager.shared.loadTokenIcon(for: token) {
            completion(localIcon)
            return
        }
        
        // 2. 尝试从不同的来源获取
        tryTrustWalletIcon(token: token) { image in
            if let image = image {
                completion(image)
                return
            }
            
            self.tryCoinGeckoIcon(token: token) { image in
                if let image = image {
                    completion(image)
                    return
                }
                
                // 最后尝试BscScan
                self.tryBscScanIcon(token: token, completion: completion)
            }
        }
    }
    
    private func tryTrustWalletIcon(token: Token, completion: @escaping (UIImage?) -> Void) {
        let urlString = "\(trustWalletListURL)\(token.address)/logo.png"
        downloadImage(urlString: urlString, completion: completion)
    }
    
    private func tryCoinGeckoIcon(token: Token, completion: @escaping (UIImage?) -> Void) {
        // 1. 搜索代币ID
        let searchURL = "\(coinGeckoBaseURL)/search?query=\(token.symbol)"
        
        guard let url = URL(string: searchURL) else {
            completion(nil)
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data, 
                  let json = try? JSON(data: data),
                  let coins = json["coins"].array,
                  let coin = coins.first(where: { $0["symbol"].stringValue.lowercased() == token.symbol.lowercased() }),
                  let id = coin["id"].string else {
                completion(nil)
                return
            }
            
            // 2. 获取代币图片URL
            let tokenURL = "\(self.coinGeckoBaseURL)/coins/\(id)?localization=false&tickers=false&market_data=false"
            
            guard let tokenURLObject = URL(string: tokenURL) else {
                completion(nil)
                return
            }
            
            URLSession.shared.dataTask(with: tokenURLObject) { data, _, _ in
                guard let data = data,
                      let json = try? JSON(data: data),
                      let imageUrl = json["image"]["large"].string else {
                    completion(nil)
                    return
                }
                
                self.downloadImage(urlString: imageUrl, completion: completion)
            }.resume()
        }.resume()
    }
    
    private func tryBscScanIcon(token: Token, completion: @escaping (UIImage?) -> Void) {
        let urlString = "\(bscScanImageURL)\(token.address).png"
        downloadImage(urlString: urlString, completion: completion)
    }
    
    private func downloadImage(urlString: String, completion: @escaping (UIImage?) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }
        
        KingfisherManager.shared.retrieveImage(with: url) { result in
            if case .success(let value) = result {
                completion(value.image)
            } else {
                completion(nil)
            }
        }
    }
}