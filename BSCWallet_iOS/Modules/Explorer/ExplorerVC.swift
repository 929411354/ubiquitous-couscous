import UIKit

class ExplorerVC: UIViewController, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addressField: UITextField!
    
    var transactions: [[String: Any]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
    }
    
    @IBAction func searchTapped() {
        guard let address = addressField.text?.trimmingCharacters(in: .whitespaces),
              !address.isEmpty else {
            return
        }
        
        BSCScanService.shared.getTransactions(address: address) { [weak self] txs in
            self?.transactions = txs ?? []
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return transactions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        let tx = transactions[indexPath.row]
        cell.textLabel?.text = tx["hash"] as? String ?? "未知交易"
        cell.detailTextLabel?.text = "区块: \(tx["blockNumber"] as? String ?? "0")"
        return cell
    }
}