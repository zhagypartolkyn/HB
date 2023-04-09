 

import UIKit
import SwiftUI

class SettingsViewController: UIViewController {
    
    // MARK: - Variables
    private let viewModel: SettingsViewModel
    private lazy var contentView = UIHostingController(rootView: SettingsView(viewModel: viewModel))
    
    // MARK: - LifeCycle
    init(viewModel: SettingsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        addChild(contentView)
        view.addSubview(contentView.view)
        
        contentView.view.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
}
