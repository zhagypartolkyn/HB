 

import UIKit
import SwiftUI

class FollowViewController: UIViewController {
    
    // MARK: - Variables
    private let viewModel: FollowViewModel
    private lazy var contentView = UIHostingController(rootView: FollowView(viewModel: viewModel))
    
    // MARK: - LifeCycle
    init(viewModel: FollowViewModel) {
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
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.title = viewModel.userVM.username
        
        addChild(contentView)
        view.addSubview(contentView.view)
        
        contentView.view.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
}
