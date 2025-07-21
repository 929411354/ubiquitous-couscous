import UIKit
import WebKit

class ToolsVC: UIViewController {
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var toolSelector: UISegmentedControl!
    
    let tools = [
        "Gas估算器": "GasEstimator.html",
        "合约调试器": "ContractDebugger.html",
        "授权检查器": "ApproveChecker.html"
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupToolSelector()
        loadSelectedTool()
    }
    
    private func setupToolSelector() {
        toolSelector.removeAllSegments()
        for (index, tool) in tools.keys.enumerated() {
            toolSelector.insertSegment(withTitle: tool, at: index, animated: false)
        }
        toolSelector.selectedSegmentIndex = 0
    }
    
    @IBAction func toolChanged(_ sender: UISegmentedControl) {
        loadSelectedTool()
    }
    
    private func loadSelectedTool() {
        let toolName = toolSelector.titleForSegment(at: toolSelector.selectedSegmentIndex) ?? ""
        if let fileName = tools[toolName] {
            if let url = Bundle.main.url(forResource: fileName, withExtension: nil) {
                webView.load(URLRequest(url: url))
            }
        }
    }
}