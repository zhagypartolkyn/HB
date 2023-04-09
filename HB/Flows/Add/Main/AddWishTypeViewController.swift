 

import UIKit

protocol AddWishTypeViewControllerDelegate {
    func createWishAction(type: WishType)
}

enum WishType: String {
    case single = "single"
    case group = "group"
}

class AddWishTypeViewController: UIViewController {
    
    // MARK: - Variables
    private var delegate: AddWishTypeViewControllerDelegate
    private var type: WishType?
    
    // MARK: - Outlets
    private let questionLabel = UILabelFactory(text: "Выберите тип желания")
        .text(color: UIColor.appColor(.textPrimary))
        .font(Fonts.Heading3)
        .build()
    
    private let imageView = UIImageViewFactory(image: Icons.Add.group)
        .content(mode: .scaleAspectFit)
        .hide()
        .build()
    
    private let groupView = UIViewFactory()
        .corner(radius: Constants.Radius.general)
        .build()
    
    private let groupLabel = UILabelFactory(text: "Групповое")
        .text(color: UIColor.appColor(.textPrimary))
        .font(Fonts.Secondary)
        .build()
    
    private let groupActiveView = UIViewFactory()
        .background(color: UIColor.appColor(.background))
        .corner(radius: 12).border(width: 6)
        .border(color: UIColor.appColor(.background))
        .build()
    
    private let singleView = UIViewFactory()
        .corner(radius: Constants.Radius.general)
        .build()
    
    private let singleLabel = UILabelFactory(text: "Тет-а-тет")
        .text(color: UIColor.appColor(.textPrimary))
        .font(Fonts.Secondary)
        .build()
    
    private let singleActiveView = UIViewFactory()
        .background(color: UIColor.appColor(.background))
        .corner(radius: 12)
        .border(width: 6)
        .border(color: UIColor.appColor(.background))
        .build()
    
    private lazy var buttonsStackView = UIStackViewFactory(views: [groupView, singleView])
        .spacing(8)
        .build()
    
    private let titleLabel = UILabelFactory()
        .numberOf(lines: 0)
        .text(color: UIColor.appColor(.textPrimary))
        .font(Fonts.Semibold.Paragraph)
        .build()
    
    private let descriptionLabel = UILabelFactory()
        .numberOf(lines: 0)
        .text(color: UIColor.appColor(.textSecondary))
        .font(Fonts.Paragraph)
        .build()
    
    private let bottomLineView = UIViewFactory().build()
    
    // MARK: - LifeCycle
    init(delegate: AddWishTypeViewControllerDelegate) {
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupActions()
    }
    
    // MARK: - Actions
    @objc private func handleBackButton() {
        self.dismiss(animated: true)
    }
    
    @objc private func handleGroupView() {
        changeWishType(.group)
    }
    
    @objc private func handleSingleView() {
        changeWishType(.single)
    }
    
    @objc private func handleAddButton() {
        guard let type = type else { return }
        delegate.createWishAction(type: type)
        dismiss(animated: true)
    }
    
    // MARK: - Private Methods
    private func setupActions() {
        groupView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleGroupView)))
        singleView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSingleView)))
    }
    
    private func changeWishType(_ type: WishType) {
        let groupTitleText = LocalizedText.addWish.GROUP_TITLE_TEXT
        let groupDescriptionText = LocalizedText.addWish.groupDescriptionText
        let singleTitleText = LocalizedText.addWish.singleTitleText
        let singleDescriptionText = LocalizedText.addWish.singleDescriptionText
        
        self.type = type
        self.navigationItem.rightBarButtonItem?.isEnabled = true
        
        imageView.isHidden = false
        imageView.image = type == .group ? Icons.Add.group : Icons.Add.single
        
        groupActiveView.layer.borderColor = type == .group ? UIColor.appColor(.primary).cgColor : UIColor.appColor(.background).cgColor
        singleActiveView.layer.borderColor = type == .single ? UIColor.appColor(.primary).cgColor : UIColor.appColor(.background).cgColor
        
        titleLabel.text = type == .group ? groupTitleText : singleTitleText
        descriptionLabel.text = type == .group ? groupDescriptionText : singleDescriptionText
        
        buttonsStackView.snp.updateConstraints { (make) in
            make.top.equalTo(imageView.snp.bottom).offset(24)
        }
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        view.backgroundColor = UIColor.appColor(.background)
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Назад", style: .plain, target: self, action: #selector(handleBackButton))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: LocalizedText.tabBar.ADD, style: .done, target: self, action: #selector(handleAddButton))
        navigationItem.rightBarButtonItem?.isEnabled = false
        
        [questionLabel, imageView, buttonsStackView, titleLabel, descriptionLabel, bottomLineView].forEach { view.addSubview($0) }

        questionLabel.snp.makeConstraints { (make) in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(24)
            make.leading.trailing.equalToSuperview().inset(24)
        }
        
        imageView.snp.makeConstraints { (make) in
            make.top.equalTo(questionLabel.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(24)
            make.height.equalTo(220)
        }
        
        buttonsStackView.snp.makeConstraints { (make) in
            make.top.equalTo(imageView.snp.bottom).offset(-220)
            make.leading.trailing.equalToSuperview().inset(24)
        }
        
        groupView.snp.makeConstraints { (make) in
            make.height.equalTo(44)
        }
        
        [groupLabel, groupActiveView].forEach { groupView.addSubview($0) }
        
        groupLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(16)
        }
        
        groupActiveView.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().inset(16)
            make.width.height.equalTo(24)
        }
        
        singleView.snp.makeConstraints { (make) in
            make.height.equalTo(44)
        }
        
        [singleLabel, singleActiveView].forEach { singleView.addSubview($0) }
        
        singleLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(16)
        }
        
        singleActiveView.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().inset(16)
            make.width.height.equalTo(24)
        }
        
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(buttonsStackView.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(24)
        }
        
        descriptionLabel.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(24)
        }
    }
    
}
