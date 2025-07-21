import UIKit

class ExplorerVC: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addressField: UITextField!
    @IBOutlet weak var networkSegment: UISegmentedControl!
    
    var transactions: [[String: Any]] = []
    var tokenTransfers: [[String: Any]] = []
    var currentAddress = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupNetworkSegment()
        addScannerButton()
    }
    
    private func setupTableView() {
        tableView.register(UINib(nibName: "TransactionCell", bundle: nil), forCellReuseIdentifier: "TransactionCell")
        tableView.register(UINib(nibName: "TokenTransferCell", bundle: nil), forCellReuseIdentifier: "TokenTransferCell")
    }
    
    private func setupNetworkSegment() {
        networkSegment.selectedSegmentIndex = WalletManager.shared.currentNetwork == .mainnet ? 0 : 1
        networkSegment.setTitle("主网", forSegmentAt: 0)
        networkSegment.setTitle("测试网", forSegmentAt: 1)
    }
    
    private func addScannerButton() {
        let scanButton = UIBarButtonItem(image: UIImage(systemName: "qrcode.viewfinder"), style: .plain, target: self, action: #selector(showScanner))
        navigationItem.rightBarButtonItem = scanButton
    }
    
    @IBAction func networkChanged(_ sender: UISegmentedControl) {
        WalletManager.shared.currentNetwork = sender.selectedSegmentIndex == 0 ? .mainnet : .testnet
        if !currentAddress.isEmpty {
            fetchData(for: currentAddress)
        }
    }
    
    @IBAction func searchTapped() {
        guard let address = addressField.text?.trimmingCharacters(in: .whitespaces), address.isValidAddress else {
            showAlert(title: "无效地址", message: "请输入有效的BSC地址")
            return
        }
        
        currentAddress = address
        fetchData(for: address)
    }
    
    private func fetchData(for address: String) {
        showLoadingIndicator()
        
        let group = DispatchGroup()
        
        group.enter()
        BSCScanService.shared.getTransactions(address: address) { [weak self] transactions in
            self?.transactions = transactions ?? []
            group.leave()
        }
        
        group.enter()
        BSCScanService.shared.getTokenTransfers(address: address) { [weak self] transfers in
            self?.tokenTransfers = transfers ?? []
            group.leave()
        }
        
        group.notify(queue: .main) {
            self.hideLoadingIndicator()
            self.tableView.reloadData()
            
            if self.transactions.isEmpty && self.tokenTransfers.isEmpty {
                self.showAlert(title: "无数据", message: "该地址没有交易记录")
            }
        }
    }
    
    @objc private func showScanner() {
        let scannerVC = QRScannerVC()
        scannerVC.delegate = self
        present(scannerVC, animated: true)
    }
}

extension ExplorerVC: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return min(transactions.count, 20)
        case 1: return min(tokenTransfers.count, 20)
        default: return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionCell", for: indexPath) as! TransactionCell
            cell.configure(with: transactions[indexPath.row])
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TokenTransferCell", for: indexPath) as! TokenTransferCell
            cell.configure(with: tokenTransfers[indexPath.row])
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return "交易记录"
        case 1: return "代币转账"
        default: return nil
        }
    }
}

extension ExplorerVC: QRScannerDelegate {
    func didScanQRCode(_ code: String) {
        dismiss(animated: true) {
            guard code.isValidAddress else {
                self.showAlert(title: "无效地址", message: "扫描的二维码不是有效的BSC地址")
                return
            }
            
            self.addressField.text = code
            self.currentAddress = code
            self.fetchData(for: code)
        }
    }
}