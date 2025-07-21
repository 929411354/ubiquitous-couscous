import UIKit

class SettingsVC: UITableViewController {
    let sections = [
        ["钱包设置", "安全设置"],
        ["代币管理"],
        ["网络设置", "高级设置"]
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "设置"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "SettingCell")
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return ["账户", "代币", "网络"][section]
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingCell", for: indexPath)
        cell.textLabel?.text = sections[indexPath.section][indexPath.row]
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let section = indexPath.section
        let row = indexPath.row
        
        if section == 0 && row == 0 {
            // 钱包设置
            showWalletSettings()
        } else if section == 0 && row == 1 {
            // 安全设置
            showSecuritySettings()
        } else if section == 1 && row == 0 {
            // 代币管理
            showTokenManagement()
        } else if section == 2 && row == 0 {
            // 网络设置
            showNetworkSettings()
        } else if section == 2 && row == 1 {
            // 高级设置
            showAdvancedSettings()
        }
    }
    
    private func showWalletSettings() {
        let vc = WalletSettingsVC()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func showSecuritySettings() {
        let vc = SecuritySettingsVC()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func showTokenManagement() {
        let vc = TokenManagementVC()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func showNetworkSettings() {
        let vc = NetworkSettingsVC()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func showAdvancedSettings() {
        let vc = AdvancedSettingsVC()
        navigationController?.pushViewController(vc, animated: true)
    }
}