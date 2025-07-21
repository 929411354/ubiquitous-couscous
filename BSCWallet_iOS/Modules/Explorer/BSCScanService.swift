import Foundation

class BSCScanService {
    static let shared = BSCScanService()
    
    private let testnetAPI = "https://api-testnet.bscscan.com/api"
    private let apiKey = "YOUR_BSCSCAN_API_KEY" // 在此处替换为您的API密钥
    
    func getTransactions(address: String, completion: @escaping ([[String: Any]]?) -> Void) {
        let urlString = "\(testnetAPI)?module=account&action=txlist&address=\(address)&apikey=\(apiKey)"
        
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
                   let result = json["result"] as? [[String: Any]] {
                    completion(result)
                } else {
                    completion(nil)
                }
            } catch {
                completion(nil)
            }
        }.resume()
    }
}