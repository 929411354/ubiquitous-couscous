class AddTokenVC: UIViewController {
    // ... 已有代码 ...
    
    @IBAction func selectAvatarTapped() {
        let avatarPicker = AvatarPickerVC(nibName: "AvatarPickerVC", bundle: nil)
        avatarPicker.modalPresentationStyle = .pageSheet
        avatarPicker.completion = { [weak self] image in
            guard let self = self else { return }
            
            self.selectedIcon = image
            self.tokenIconView.image = image
            
            // 自动上传新选择的头像到IPFS
            if let image = image {
                self.uploadAvatarToIPFS(image: image)
            }
        }
        present(avatarPicker, animated: true)
    }
    
    private func uploadAvatarToIPFS(image: UIImage) {
        showLoadingIndicator()
        
        // 如果代币地址已存在，上传并关联
        if let address = addressField.text, !address.isEmpty {
            TokenManager.shared.uploadTokenAvatar(image, for: address) { [weak self] ipfsUrl in
                self?.hideLoadingIndicator()
                if let ipfsUrl = ipfsUrl {
                    self?.showMessage(title: "上传成功", message: "头像已上传到IPFS")
                    print("IPFS URL: \(ipfsUrl)")
                } else {
                    self?.showMessage(title: "上传失败", message: "请稍后重试")
                }
            }
        }
    }
}