import UIKit
import WebKit

class ToolsVC: UIViewController {
    @IBOutlet weak var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadTool()
    }
    
    private func loadTool() {
        if let url = Bundle.main.url(forResource: "GasEstimator", withExtension: "html") {
            webView.load(URLRequest(url: url))
        }
    }
}