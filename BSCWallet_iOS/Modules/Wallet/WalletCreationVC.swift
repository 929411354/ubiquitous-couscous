import UIKit

class WalletCreationVC: UIViewController {
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var confirmPasswordField: UITextField!
    @IBOutlet weak var createButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        passwordField.isSecureTextEntry = true
        confirmPasswordField.isSecureTextEntry = true
        createButton.layer.cornerRadius = 8
    }
    
    @IBAction func createWalletTapped() {
        guard let password = passwordField.text, !password.isEmpty,
              let confirmPassword = confirmPasswordField.text, !confirmPassword.isEmpty else {
            showAlert(title: "密码不能为空", message: "请输入密码并确认")
            return
        }
        
        guard password == confirmPassword else {
            showAlert(title: "密码不匹配", message: "两次输入的密码不一致")
            return
        }
        
        guard password.count >= 8 else {
            showAlert(title: "密码太短", message: "密码长度至少为8个字符")
            return
        }
        
        createWallet(with: password)
    }
    
    private func createWallet(with password: String) {
        showLoadingIndicator()
        
        DispatchQueue.global(qos: .userInitiated).async {
            let wallet = WalletManager.shared.createWallet()
            
            DispatchQueue.main.async {
                self.hideLoadingIndicator()
                self.showSuccessAlert(walletAddress: wallet.address)
            }
        }
    }
    
    private func showSuccessAlert(walletAddress: String) {
        let alert = UIAlertController(
            title: "钱包创建成功",
            message: "您的钱包地址: \(walletAddress)",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "确定", style: .default) { _ in
            self.dismiss(animated: true)
        })
        
        present(alert, animated: true)
    }
}