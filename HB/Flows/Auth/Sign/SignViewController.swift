

import UIKit
import SwiftUI

class SignViewController: UIViewController {
    
    // MARK: - Outlets
    private let viewModel: SignViewModel
    private lazy var contentView = UIHostingController(rootView: SignView(viewModel: viewModel, vc: self))
    
    // MARK: - LifeCycle
    init(viewModel: SignViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        viewModelBinding()
    }
    
    // MARK: - Binding
    private func viewModelBinding() {
        viewModel.showHUD = { [weak self] (type, text) in
            self?.showHUD(type: type, text: text)
        }
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
