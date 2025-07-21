import Foundation
import Moya

enum IPFSService {
    case uploadFile(data: Data, fileName: String)
    case pinFile(cid: String)
}

extension IPFSService: TargetType {
    var baseURL: URL {
        return URL(string: "https://api.pinata.cloud")!
    }
    
    var path: String {
        switch self {
        case .uploadFile:
            return "/pinning/pinFileToIPFS"
        case .pinFile:
            return "/pinning/pinByHash"
        }
    }
    
    var method: Moya.Method {
        return .post
    }
    
    var task: Task {
        switch self {
        case .uploadFile(let data, let fileName):
            let formData = MultipartFormData(
                provider: .data(data),
                name: "file",
                fileName: fileName,
                mimeType: "application/octet-stream"
            )
            return .uploadMultipart([formData])
            
        case .pinFile(let cid):
            return .requestParameters(
                parameters: ["hashToPin": cid],
                encoding: JSONEncoding.default
            )
        }
    }
    
    var headers: [String: String]? {
        return [
            "pinata_api_key": "YOUR_PINATA_API_KEY",
            "pinata_secret_api_key": "YOUR_PINATA_SECRET_KEY"
        ]
    }
}

class IPFSManager {
    static let shared = IPFSManager()
    private let provider = MoyaProvider<IPFSService>()
    
    func uploadFile(data: Data, fileName: String, completion: @escaping (Result<String, Error>) -> Void) {
        provider.request(.uploadFile(data: data, fileName: fileName)) { result in
            switch result {
            case .success(let response):
                do {
                    let json = try JSONSerialization.jsonObject(with: response.data) as? [String: Any]
                    if let ipfsHash = json?["IpfsHash"] as? String {
                        completion(.success(ipfsHash))
                    } else {
                        completion(.failure(IPFSError.invalidResponse))
                    }
                } catch {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func pinFile(cid: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        provider.request(.pinFile(cid: cid)) { result in
            switch result {
            case .success:
                completion(.success(true))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func getGatewayURL(cid: String) -> URL {
        return URL(string: "https://gateway.pinata.cloud/ipfs/\(cid)")!
    }
    
    enum IPFSError: Error {
        case invalidResponse
    }
}