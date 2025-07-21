import Foundation

class BSCScanService {
    static let shared = BSCScanService()
    
    private let mainnetAPI = "https://api.bscscan.com/api"
    private let testnetAPI = "https://api-testnet.bscscan.com/api"
    private let apiKey = "YOUR_BSCSCAN_API_KEY"
    
    var currentNetwork: Network = .testnet
    
    enum Network {
        case mainnet
        case testnet
    }
    
    private var baseURL: String {
        switch currentNetwork {
        case .mainnet: return mainnetAPI
        case .testnet: return testnetAPI
        }
    }
    
    func getTransactions(address: String, completion: @escaping ([[String: Any]]?) -> Void) {
        let params: [String: String] = [
            "module": "account",
            "action": "txlist",
            "address": address,
            "startblock": "0",
            "endblock": "99999999",
            "sort": "desc",
            "apikey": apiKey
        ]
        
        request(params: params) { result in
            switch result {
            case .success(let data):
                if let transactions = data["result"] as? [[String: Any]] {
                    completion(transactions)
                } else {
                    completion(nil)
                }
            case .failure:
                completion(nil)
            }
        }
    }
    
    func getTokenBalance(address: String, contractAddress: String, completion: @escaping (String?) -> Void) {
        let params: [String: String] = [
            "module": "account",
            "action": "tokenbalance",
            "contractaddress": contractAddress,
            "address": address,
            "tag": "latest",
            "apikey": apiKey
        ]
        
        request(params: params) { result in
            switch result {
            case .success(let data):
                if let balance = data["result"] as? String {
                    completion(balance)
                } else {
                    completion(nil)
                }
            case .failure:
                completion(nil)
            }
        }
    }
    
    private func request(params: [String: String], completion: @escaping (Result<[String: Any], Error>) -> Void) {
        var components = URLComponents(string: baseURL)!
        components.queryItems = params.map { URLQueryItem(name: $0.key, value: $0.value) }
        
        guard let url = components.url else {
            completion(.failure(BSCScanError.invalidURL))
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(BSCScanError.noData))
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    completion(.success(json))
                } else {
                    completion(.failure(BSCScanError.invalidResponse))
                }
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }
    
    enum BSCScanError: Error {
        case invalidURL
        case noData
        case invalidResponse
    }
}