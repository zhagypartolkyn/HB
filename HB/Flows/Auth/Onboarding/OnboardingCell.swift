
import UIKit

class OnboardingCell: UICollectionViewCell {
    
    // MARK: - Outlets
    private let imageView = UIImageViewFactory()
        .content(mode: .scaleAspectFit)
        .build()
    
    private let titleLabel = UILabelFactory()
        .font(Fonts.Heading2)
        .text(color: UIColor.appColor(.textPrimary))
        .text(align: .center)
        .build()
    
    private let descriptionLabel = UILabelFactory()
        .font(Fonts.Paragraph)
        .text(color: UIColor.appColor(.textPrimary))
        .text(align: .center)
        .build()
    
    private lazy var textStackView = UIStackViewFactory(views: [titleLabel, descriptionLabel])
        .axis(.vertical)
        .spacing(8)
        .build()
    
    private lazy var mainStackView = UIStackViewFactory(views: [imageView, textStackView])
        .axis(.vertical)
        .spacing(32)
        .distribution(.fill)
        .build()
    
    // MARK: - LifeCycle
    override init(frame: CGRect) {
        super .init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) { nil }
    
    // MARK: - Public Methods
    public func configure(model: Onboarding) {
        imageView.image = model.image
        titleLabel.text = model.title
        descriptionLabel.text = model.description
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        let isBigScreen = UIScreen.main.bounds.width > 400.0
        
        [mainStackView].forEach { addSubview($0) }
        
        imageView.snp.makeConstraints { (make) in
            make.width.height.equalTo(isBigScreen ? 300 : frame.size.width / 1.2)
        }
        
        mainStackView.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
    }
    
}
