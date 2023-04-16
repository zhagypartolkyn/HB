 

import UIKit

protocol WishFixedViewDelegate: class {
    func handleWish()
}

class WishFixedView: UIView {
    
    // MARK: - Variables
    weak var delegate: WishFixedViewDelegate!
    
    // MARK: - Outlets
    private let titleLabel = UILabelFactory().text(color: UIColor.appColor(.primary))
        .font(Fonts.Tertiary)
        .build()
    
    private let subtitleLabel = UILabelFactory()
        .numberOf(lines: 0)
        .text(color: UIColor.appColor(.textSecondary))
        .font(Fonts.Semibold.Tertiary)
        .build()
    
    private let mainLineView = UIViewFactory()
        .background(color: UIColor.appColor(.primary))
        .corner(radius: 2)
        .build()
    
    private let topLineView = UIViewFactory()
        .build()
    
    private let bottomLineView = UIViewFactory()
        .build()
    
    
    // MARK: - LifeCycle
    init(isHistory: Bool = false) {
        super.init(frame: .zero)
        setupUI()
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
        
        if isHistory {
            backgroundColor = .clear
            titleLabel.textColor = .white
            subtitleLabel.textColor = .white
            mainLineView.backgroundColor = .white
            topLineView.isHidden = true
            bottomLineView.isHidden = true
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Actions
    @objc private func handleTap(gesture: UITapGestureRecognizer) {
        self.delegate.handleWish()
    }
    
    // MARK: - Methods
    func configureView(title: String, subtitle: String) {
        titleLabel.text = title
        subtitleLabel.text = subtitle
    }

    // MARK: - Setup UI
    private func setupUI() {
        backgroundColor = UIColor.appColor(.background)
        bottomLineView.backgroundColor = .clear
        [topLineView, bottomLineView, mainLineView, titleLabel, subtitleLabel].forEach { addSubview($0) }
        
        topLineView.snp.makeConstraints { (make) in
            make.height.equalTo(1)
            make.top.leading.trailing.equalToSuperview()
        }
        
        bottomLineView.snp.makeConstraints { (make) in
            make.bottom.leading.trailing.equalToSuperview()
            make.height.equalTo(1)
        }
        
        mainLineView.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
            make.width.equalTo(3)
            make.height.equalTo(33)
        }
        
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().inset(6)
            make.leading.equalTo(mainLineView.snp.trailing).offset(10)
        }
        
        subtitleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(3)
            make.leading.equalTo(mainLineView.snp.trailing).offset(10)
            make.trailing.equalToSuperview().inset(12)
        }
    }
    
}
