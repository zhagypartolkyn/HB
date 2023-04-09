 

import UIKit
import SnapKit

protocol ProfileSegmentViewDelegate {
    func handleSegment(_ index: IndexCase)
}

class ProfileSegmentView: UIView {
    
    // MARK: - Variables
    var delegate: ProfileSegmentViewDelegate?
    
    // MARK: - Outlets
    private lazy var activeButton = UIButtonFactory(style: .active)
        .set(image: Icons.Wish.active).tint(color: .white)
        .addTarget(#selector(handleActive))
        .build()
    
    private lazy var completeButton = UIButtonFactory(style: .active)
        .set(image: Icons.Wish.complete).tint(color: .white)
        .addTarget(#selector(handleComplete))
        .build()
    
    private lazy var participantButton = UIButtonFactory(style: .active)
        .set(image: Icons.Wish.group).tint(color: .white)
        .addTarget(#selector(handleParticipant))
        .build()
    
    private lazy var buttonsStackView = UIStackViewFactory(views: [activeButton, completeButton, participantButton])
        .spacing(0)
        .build()
    
    // MARK: - LifeCycle
    init() {
        super.init(frame: CGRect.zero)
        setupUI()
        activeButton(button: activeButton)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Actions
    @objc private func handleActive() {
        activeButton(button: activeButton)
        delegate?.handleSegment(.active)
    }
    
    @objc private func handleComplete() {
        activeButton(button: completeButton)
        delegate?.handleSegment(.completed)
    }
    
    @objc private func handleParticipant() {
        activeButton(button: participantButton)
        delegate?.handleSegment(.participant)
    }
    
    // MARK: - Private Methods
    private func activeButton(button: UIButton) {
        [activeButton, completeButton, participantButton].forEach {
            $0.tintColor = UIColor.appColor(.textSecondary)
            $0.backgroundColor = nil
        }
        button.tintColor = .white
        button.backgroundColor = UIColor.appColor(.primary)
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        backgroundColor = UIColor.appColor(.background)
        layer.cornerRadius = Constants.Radius.general
        clipsToBounds = true
        layer.applyCardShadow()
        
        [buttonsStackView].forEach { addSubview($0) }
        
        buttonsStackView.snp.makeConstraints { (make) in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(40)
        }
        
        snp.makeConstraints { (make) in
            make.height.equalTo(40)
        }
    }
    
}
