 

import UIKit
import SnapKit

class ProfileErrorView: UITableViewCell {
    
    // MARK: - Outlets
    var errorView = ErrorView()
    
    // MARK: - LifeCycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup UI
    func setupUI() {
        backgroundColor = .clear
        contentView.addSubview(errorView)
        errorView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        contentView.heightAnchor.constraint(equalToConstant: 300).isActive = true
    }
    
}
