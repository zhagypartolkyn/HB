 

import UIKit
import SwiftUI

class ActivitiesViewController: UIViewController {
    
    // MARK: - Variables
    private let viewModel: ActivitiesViewModel
    private lazy var contentView = UIHostingController(rootView: ActivitiesView(viewModel: viewModel))
    
    private let errorImageView = UIImageViewFactory(image: Icons.Error.activities)
        .content(mode: .scaleAspectFit)
        .build()
    
    private let errorLabel = UILabelFactory(text: LocalizedText.error.activiries)
        .font(Fonts.Semibold.Paragraph)
        .text(align: .center)
        .text(color: UIColor.appColor(.textSecondary))
        .numberOf(lines: 0)
        .build()
    
    private lazy var errorStackView = UIStackViewFactory(views: [errorImageView, errorLabel])
        .axis(.vertical)
        .spacing(12)
        .distribution(.fill)
        .alignment(.center)
        .hide()
        .build()
    
    
    // MARK: - LifeCycle
    init(viewModel: ActivitiesViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        viewModel.fetchNotifications()
        errorStackView.isHidden =  viewModel.isHide
        
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.title = LocalizedText.tabBar.ACTIVITIES
        
        addChild(contentView)
        view.addSubview(contentView.view)
        
        contentView.view.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        view.addSubview(errorStackView)
        errorStackView.snp.makeConstraints { (make) in
            make.leading.trailing.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
        }
        
        errorImageView.snp.makeConstraints { (make) in
            make.width.height.equalTo(200)
        }
    }
    
}
