import UIKit

extension TokenManager {
    // 添加一个方法用于上传头像到IPFS
    func uploadTokenAvatar(_ image: UIImage, for tokenAddress: String, completion: @escaping (String?) -> Void) {
        TokenAvatarUploader.shared.uploadAvatar(image: image) { result in
            switch result {
            case .success(let ipfsUrl):
                // 保存到本地token中
                if let index = self.tokens.firstIndex(where: { $0.address == tokenAddress }) {
                    var token = self.tokens[index]
                    token.iconUrl = ipfsUrl
                    self.tokens[index] = token
                    self.saveCustomTokens()
                    completion(ipfsUrl)
                } else {
                    completion(nil)
                }
            case .failure:
                completion(nil)
            }
        }
    }
}