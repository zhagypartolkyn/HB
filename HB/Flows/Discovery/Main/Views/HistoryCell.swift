 

import UIKit
import SnapKit
import Kingfisher

class HistoryCell: UICollectionViewCell {
    
    // MARK: - Outlets
    private let imageView = UIImageViewFactory()
        .content(mode: .scaleAspectFill)
        .corner(radius: 16)
        .build()
    
    private let playImageView = UIImageViewFactory(image: Icons.Wish.play)
        .hide()
        .tint(color: .white)
        .build()
    
    private let avatarImageView = UIImageViewFactory()
        .content(mode: .scaleAspectFit)
        .background(color: UIColor.appColor(.textBorder))
        .corner(radius: 16)
        .build()
    
    private let dateLabel = UILabelFactory()
        .text(color: .white)
        .font(Fonts.Semibold.Tertiary)
        .numberOf(lines: 0)
        .text(align: .center)
        .build()
    
    private let darkenView = UIViewFactory()
        .background(color: .black)
        .alpha(0.2)
        .corner(radius: 14)
        .build()
    
    // MARK: - LifeCycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public Methods
    public func configure(viewModel: HistoryViewModel) {
        imageView.kf.setImage(with: URL(string: viewModel.thumb))
        avatarImageView.kf.setImage(with: URL(string: viewModel.avatar))
        dateLabel.text = viewModel.publishDate
        playImageView.isHidden = viewModel.mediaType == .photo
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        [imageView, playImageView, darkenView, avatarImageView, dateLabel].forEach { addSubview($0) }
        
        imageView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        playImageView.snp.makeConstraints { (make) in
            make.height.width.equalTo(24)
            make.top.trailing.equalToSuperview().inset(8)
        }
        
        darkenView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        avatarImageView.snp.makeConstraints { (make) in
            make.width.height.equalTo(32)
            make.leading.top.equalToSuperview().offset(8)
        }
        
        dateLabel.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().inset(8)
            make.leading.trailing.equalToSuperview().inset(8)
        }
    }
    
}
