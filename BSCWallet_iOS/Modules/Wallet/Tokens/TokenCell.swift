import UIKit

class TokenCell: UITableViewCell {
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var symbolLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var balanceLabel: UILabel!
    
    func configure(with token: Token) {
        symbolLabel.text = token.symbol
        nameLabel.text = token.name
        
        // 设置代币图标
        if let iconUrl = token.iconUrl {
            let url = URL(string: iconUrl)
            iconView.kf.setImage(with: url, placeholder: UIImage(named: "default_token"))
        } else {
            iconView.image = UIImage(named: "default_token")
        }
        
        // 圆角图标
        iconView.layer.cornerRadius = 12
        iconView.layer.masksToBounds = true
        
        // 显示余额
        balanceLabel.text = "\(token.balance) \(token.symbol)"
    }
}