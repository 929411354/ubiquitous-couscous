import UIKit
import Moya
import SwiftyJSON

class TokenAvatarUploader {
    static let shared = TokenAvatarUploader()
    
    // 使用Pinata作为IPFS节点
    private let pinataApiKey = "YOUR_PINATA_API_KEY"
    private let pinataSecret = "YOUR_PINATA_SECRET"
    
    // 主要网络节点列表
    private let ipfsNodes = [
        "https://ipfs.infura.io:5001",
        "https://gateway.pinata.cloud",
        "https://ipfs.fleek.co"
    ]
    
    private var currentIPFSNode = 0
    
    func uploadAvatar(image: UIImage, completion: @escaping (Result<String, Error>) -> Void) {
        // 1. 将图像转换为JPEG数据
        guard let imageData = image.jpegData(compressionQuality: 0.85) else {
            completion(.failure(TokenAvatarError.invalidImage))
            return
        }
        
        // 2. 获取当前IPFS节点
        let nodeUrl = ipfsNodes[currentIPFSNode]
        
        // 3. 尝试上传到Pinata（专业的IPFS服务）
        uploadToPinata(imageData: imageData, completion: completion)
    }
    
    private func uploadToPinata(imageData: Data, completion: @escaping (Result<String, Error>) -> Void) {
        let pinataUrl = "https://api.pinata.cloud/pinning/pinFileToIPFS"
        let headers = ["pinata_api_key": pinataApiKey, "pinata_secret_api_key": pinataSecret]
        
        let multipartData = MultipartFormData(
            provider: .data(imageData),
            name: "file",
            fileName: "avatar_\(Date().timeIntervalSince1970).jpg",
            mimeType: "image/jpeg"
        )
        
        let provider = MoyaProvider<IPFSService>()
        provider.request(.uploadFile(multipartData: multipartData)) { result in
            switch result {
            case .success(let response):
                do {
                    let json = try JSON(data: response.data)
                    if let ipfsHash = json["IpfsHash"].string {
                        // 上传成功，获取IPFS URL
                        let ipfsUrl = "https://ipfs.io/ipfs/\(ipfsHash)"
                        completion(.success(ipfsUrl))
                    } else {
                        completion(.failure(TokenAvatarError.uploadFailed))
                    }
                } catch {
                    completion(.failure(error))
                }
            case .failure(let error):
                // 切换到下一个IPFS节点
                self.currentIPFSNode = (self.currentIPFSNode + 1) % self.ipfsNodes.count
                completion(.failure(error))
            }
        }
    }
    
    enum TokenAvatarError: Error {
        case invalidImage
        case uploadFailed
    }
}

enum IPFSService {
    case uploadFile(multipartData: MultipartFormData)
}

extension IPFSService: TargetType {
    var baseURL: URL { URL(string: "https://api.pinata.cloud")! }
    var path: String { "/pinning/pinFileToIPFS" }
    var method: Moya.Method { .post }
    var task: Task {
        switch self {
        case .uploadFile(let multipartData):
            let formData = [multipartData]
            return .uploadMultipart(formData)
        }
    }
    var headers: [String: String]? {
        return [
            "pinata_api_key": TokenAvatarUploader.shared.pinataApiKey,
            "pinata_secret_api_key": TokenAvatarUploader.shared.pinataSecret
        ]
    }
}