 

import UIKit
import SnapKit
import MapKit
import SPPermissions

protocol AddWishViewDelegate: class {
    func enableAddButton(_ enable: Bool)
    func pickerAction()
    func showOnMap(_ enable: Bool)
    func checkPermission()
}

class AddWishView: UIView {
    
    // MARK: - Variables
    weak var delegate: AddWishViewDelegate!
    private var keyboardHelper: KeyboardHelper?
    private lazy var permission = Permission(delegate: self)
    
    // MARK: - Outlets
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    // Title
    private lazy var titleTextView: UITextView = {
        let textView = UITextView()
        textView.textColor = UIColor.appColor(.textPrimary)
        textView.font = Fonts.Heading3
        textView.backgroundColor = UIColor.appColor(.background)
        textView.tag = 1
        textView.delegate = self
        return textView
    }()
    
    private let titlePlaceholder = UILabelFactory(text: LocalizedText.addWish.WHAT_YOU_WANT)
        .text(color: UIColor.appColor(.textTeritary))
        .font(Fonts.Heading3)
        .build()
    
    private let titleCountLabel = UILabelFactory(text: "0 / 100")
        .text(color: UIColor.appColor(.textSecondary))
        .font(Fonts.Tertiary)
        .text(align: .right)
        .build()
    
    // Cover
    private let dashedView: CustomDashedView = {
        let view = CustomDashedView()
        view.betweenDashesSpace = 10
        view.dashLength = 10
        view.cornerRadius = Constants.Radius.general
        view.dashWidth = 3
        view.dashColor = UIColor.appColor(.textTeritary)
        return view
    }()
    
    private let imageView = UIImageViewFactory()
        .corner(radius: Constants.Radius.general)
        .content(mode: .scaleAspectFill)
        .build()
    
    private let coverIconImageView = UIButtonFactory(style: .normal)
        .set(image: UIImage(named: "cover"))
        .addTarget(#selector(handleCamera))
        .build()
    
    private let coverTitleLabel = UILabelFactory(text: LocalizedText.addWish.ADD_COVER_IMAGE)
        .font(Fonts.Paragraph)
        .text(color: UIColor.appColor(.textPrimary))
        .numberOf(lines: 0)
        .text(align: .center)
        .build()
    
    private let coverSubtitleLabel = UILabelFactory(text: LocalizedText.addWish.ADD_COVER_IMAGE_DESCRIPTION)
        .font(Fonts.Secondary)
        .text(color: UIColor.appColor(.textSecondary))
        .numberOf(lines: 0)
        .text(align: .center)
        .build()
    
    private lazy var coverStackView = UIStackViewFactory(views: [coverIconImageView, coverTitleLabel, coverSubtitleLabel])
        .spacing(12)
        .distribution(.fillProportionally)
        .alignment(.center)
        .axis(.vertical)
        .build()
    
    private let removeImageButton = UIButtonFactory(style: .normal)
        .set(image: Icons.General.cancel)
        .tint(color: .black)
        .background(color: .white)
        .addTarget(#selector(handleRemoveImage))
        .corner(radius: 15)
        .shadow()
        .hide()
        .build()
    
    // Description
    private let descriptionLabel = UILabelFactory(text: LocalizedText.addWish.ADD_DESCRIPTION_MINI)
        .text(color: UIColor.appColor(.textPrimary))
        .font(Fonts.Semibold.Secondary)
        .build()
    
    private let descriptionCountLabel = UILabelFactory(text: "0 / 500")
        .text(color: UIColor.appColor(.textSecondary))
        .font(Fonts.Tertiary)
        .text(align: .right).build()
    
    private lazy var descriptionTextView: UITextView = {
        let textView = UITextView()
        textView.textColor = UIColor.appColor(.textPrimary)
        textView.font = Fonts.Secondary
        textView.backgroundColor = UIColor.appColor(.background)
        textView.tag = 2
        textView.delegate = self
        return textView
    }()
    
    private let descriptionPlaceholder = UILabelFactory(text: "\(LocalizedText.addWish.ADD_DESCRIPTION) (\(LocalizedText.addWish.NOT_NECESSARY))")
        .text(color: UIColor.appColor(.textTeritary))
        .font(Fonts.Secondary)
        .build()
    
    private let descriptionLineView = UIViewFactory().build()
    
    // Show on map
    private let showOnMapLabel = UILabelFactory(text: LocalizedText.addWish.ADD_WISH_ON_MAP)
        .text(color: UIColor.appColor(.textPrimary))
        .font(Fonts.Semibold.Secondary)
        .build()
    
    let showOnMapSwitch: UISwitch = {
        let switchIt = UISwitch()
        switchIt.isOn = false
        switchIt.onTintColor = UIColor.appColor(.primary)
        switchIt.addTarget(self, action: #selector(handleSwitch), for: .valueChanged)
        return switchIt
    }()
    
    private let mapView: MKMapView = {
        let mv = MKMapView()
        mv.layer.cornerRadius = Constants.Radius.general
        mv.isHidden = true
        mv.isZoomEnabled = false
        mv.isScrollEnabled = false
        return mv
    }()
    
    private let mapLineView = UIViewFactory().build()
    
    // Shaker
    private let shakerImageView = UIImageViewFactory(image: Icons.Sign.phone)
        .tint(color: UIColor.appColor(.primary))
        .build()
    
    private let showShakerLabel = UILabelFactory(text: LocalizedText.addWish.cantCreateWish)
        .text(color: UIColor.appColor(.textTeritary))
        .font(Fonts.Semibold.Secondary)
        .numberOf(lines: 0)
        .build()
    
//    private lazy var shakerStackView = UIStackViewFactory(views: [shakerImageView, showShakerLabel])
//        .spacing(8)
//        .distribution(.fillProportionally)
//        .alignment(.center)
//        .build()
    
    /// PERMISSION
    private let darkerView = UIViewFactory()
        .background(color: UIColor.appColor(.background))
        .alpha(0.9)
        .hide()
        .build()
    
    private let titlePermissionLabel = UILabelFactory(text: "Дайте разрешение на геопозицию")
        .text(color: UIColor.appColor(.textPrimary))
        .text(align: .center)
        .font(Fonts.Heading3)
        .numberOf(lines: 0)
        .build()
    
    private let subtitlePermissionLabel = UILabelFactory(text: "Чтобы приложение вывело хобби в вашем город")
        .text(color: UIColor.appColor(.textPrimary))
        .text(align: .center)
        .font(Fonts.Paragraph)
        .numberOf(lines: 0)
        .build()
    
    private let permissionButton = UIButtonFactory(style: .active)
        .set(title: LocalizedText.Interesting.GIVE_PERMISSION)
        .addTarget(#selector(checkPermission))
        .build()
    
    private lazy var permissionStackView = UIStackViewFactory(views: [titlePermissionLabel, subtitlePermissionLabel, permissionButton])
        .axis(.vertical)
        .spacing(16)
        .distribution(.fill)
        .hide()
        .build()
    
    // MARK: - LifeCycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        
        dashedView.isUserInteractionEnabled = true
        dashedView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleCamera)))
        
        mapView.isUserInteractionEnabled = true
        mapView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleAddLocation)))
        
        keyboardHelper = KeyboardHelper { [unowned self] animation, keyboardFrame, duration in
            switch animation {
            case .keyboardWillShow:
                scrollView.snp.remakeConstraints { (make) in
                    make.top.centerX.width.equalToSuperview()
                    make.bottom.equalToSuperview().inset(keyboardFrame.height)
                }
            case .keyboardWillHide:
                scrollView.snp.remakeConstraints { (make) in
                    make.top.bottom.centerX.width.equalToSuperview()
                }
            }
            self.layoutIfNeeded()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Actions
    @objc private func handleCamera() {
        if imageView.image == nil {
            delegate.pickerAction()
        }
    }
    
    @objc private func handleRemoveImage() {
        imageView.image = nil
        coverStackView.isHidden = false
        removeImageButton.isHidden = true
        dashedView.hide(false)
    }
    
    @objc private func handleSwitch(sender: UISwitch!) {
        delegate.showOnMap(sender.isOn)
        
        if !sender.isOn {
            mapView.isHidden = true
            
            mapLineView.snp.updateConstraints { (make) in
                make.top.equalTo(mapView.snp.bottom).offset(-150)
            }
        }
    }
    
    @objc private func handleAddLocation() {
        delegate.showOnMap(true)
    }
    
    @objc private func checkPermission() {
        delegate.checkPermission()
    }
    
    // MARK: - Public Methods
    public func configureCover(image: UIImage) {
        removeImageButton.isHidden = false
        coverStackView.isHidden = true
        imageView.image = image
        dashedView.hide()
    }
    
    public func configureWithRandom(data: RandomWish) {
        guard let image = data.images.randomElement() else { return }
        imageView.kf.setImage(with: URL(string: image))
        dashedView.hide()
        removeImageButton.isHidden = false
        coverStackView.isHidden = true
        
        titleTextView.text = data.title
        titlePlaceholder.isHidden = true
        DispatchQueue.main.async {
            self.textViewDidChange(self.titleTextView)
        }
        titleCountLabel.text = "\(data.title.count) / 100"
        
        if let description = data.description {
            if !description.isEmpty {
                descriptionTextView.text = data.description
                descriptionPlaceholder.isHidden = true
                descriptionCountLabel.text = "\((data.description ?? "").count) / 500"
            }
        }
    }
    
    public func fetchData() -> (title: String, description: String, image: UIImage?) {
        return (titleTextView.text, descriptionTextView.text, imageView.image)
    }
    
    public func resetView() {
        titlePlaceholder.isHidden = false
        titleTextView.text = ""
        titleCountLabel.text = "0 / 100"
        
        descriptionPlaceholder.isHidden = false
        descriptionTextView.text = ""
        descriptionCountLabel.text = "0 / 500"
        
        dashedView.hide(false)
        imageView.image = nil
        coverStackView.isHidden = false
        removeImageButton.isHidden = true
        
        showOnMapSwitch.isOn = false
        mapView.isHidden = true
        
        titleTextView.snp.updateConstraints { (make) in
            make.height.greaterThanOrEqualTo(40)
        }
        
        descriptionTextView.snp.updateConstraints { (make) in
            make.height.greaterThanOrEqualTo(36)
        }
        
        mapLineView.snp.updateConstraints { (make) in
            make.top.equalTo(mapView.snp.bottom).offset(-150)
        }
    }
    
    public func recreateAnnotation(_ location: CLLocationCoordinate2D) {
        mapView.removeAnnotations(mapView.annotations)
        let annotation = MKPointAnnotation()
        annotation.coordinate = location
        mapView.addAnnotation(annotation)
        
        let viewRegion = MKCoordinateRegion(center: location, latitudinalMeters: 200, longitudinalMeters: 200)
        mapView.setRegion(viewRegion, animated: false)
        
        mapView.isHidden = false
        showOnMapSwitch.isOn = true
        
        mapLineView.snp.updateConstraints { (make) in
            make.top.equalTo(mapView.snp.bottom).offset(16)
        }
    }
    
    // MARK: - Public Methods
    func showPermission(_ status: Bool) {
        darkerView.isHidden = !status
        permissionStackView.isHidden = !status
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        scrollView.isUserInteractionEnabled = true
        contentView.isUserInteractionEnabled = true
        
        addSubview(scrollView)
        scrollView.snp.makeConstraints { (make) in
            make.top.bottom.centerX.width.equalToSuperview()
        }
        
        scrollView.addSubview(contentView)
        contentView.snp.makeConstraints { (make) in
            make.centerX.width.top.bottom.equalToSuperview()
        }
        
        [titleTextView, titlePlaceholder, titleCountLabel].forEach { contentView.addSubview($0) }
        
        // Title
        titleTextView.snp.makeConstraints { (make) in
            make.top.leading.equalToSuperview().inset(24)
            make.leading.equalToSuperview().inset(16)
            make.trailing.equalTo(titleCountLabel.snp.leading).offset(0)
            make.height.greaterThanOrEqualTo(40)
        }

        titlePlaceholder.snp.makeConstraints { (make) in
            make.top.equalToSuperview().inset(32)
            make.leading.equalToSuperview().inset(21)
        }
        
        titleCountLabel.snp.makeConstraints { (make) in
            make.bottom.equalTo(titleTextView).offset(-10)
            make.trailing.equalToSuperview().inset(24)
        }
        
        // Image
        [dashedView, removeImageButton].forEach { contentView.addSubview($0) }
        
        dashedView.snp.makeConstraints { (make) in
            make.top.equalTo(titleCountLabel.snp.bottom).offset(30)
            make.leading.trailing.equalToSuperview().inset(24)
            make.height.equalTo(186)
        }
        
        [imageView, coverStackView].forEach{ dashedView.addSubview($0) }
        
        imageView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }

        coverStackView.snp.makeConstraints { (make) in
            make.leading.trailing.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
        }
        
        coverIconImageView.snp.makeConstraints { (make) in
            make.width.height.equalTo(56)
        }

        removeImageButton.snp.makeConstraints { (make) in
            make.top.trailing.equalTo(imageView).inset(16)
            make.width.height.equalTo(32)
        }

        // Description
        [descriptionLabel, descriptionCountLabel, descriptionTextView, descriptionPlaceholder, descriptionLineView].forEach { contentView.addSubview($0) }

        descriptionLabel.snp.makeConstraints { (make) in
            make.top.equalTo(imageView.snp.bottom).offset(30)
            make.leading.equalToSuperview().inset(24)
        }
        
        descriptionCountLabel.snp.makeConstraints { (make) in
            make.top.equalTo(imageView.snp.bottom).offset(30)
            make.trailing.equalToSuperview().inset(24)
        }
        
        descriptionTextView.snp.makeConstraints { (make) in
            make.top.equalTo(descriptionLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.greaterThanOrEqualTo(36)
        }

        descriptionPlaceholder.snp.makeConstraints { (make) in
            make.top.equalTo(descriptionLabel.snp.bottom).offset(16)
            make.leading.equalToSuperview().offset(24)
        }

        descriptionLineView.snp.makeConstraints { (make) in
            make.top.equalTo(descriptionTextView.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(24)
            make.height.equalTo(1)
        }

        // Show on map
        [showOnMapSwitch, showOnMapLabel, mapView, mapLineView].forEach { contentView.addSubview($0) }

        showOnMapSwitch.snp.makeConstraints { (make) in
            make.top.equalTo(descriptionLineView.snp.bottom).offset(16)
            make.trailing.equalToSuperview().inset(24)
        }
        
        showOnMapLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(showOnMapSwitch)
            make.leading.equalToSuperview().offset(24)
        }
        
        mapView.snp.makeConstraints { (make) in
            make.top.equalTo(showOnMapSwitch.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(24)
            make.height.equalTo(150)
        }
        
        mapLineView.snp.makeConstraints { (make) in
            make.top.equalTo(mapView.snp.bottom).offset(-150)
            make.leading.trailing.equalToSuperview().inset(24)
            make.height.equalTo(1)
        }
        
        // Shaker
//        [shakerStackView].forEach{ contentView.addSubview($0) }

//        shakerStackView.snp.makeConstraints { (make) in
//            make.top.equalTo(mapLineView.snp.bottom).offset(12)
//            make.leading.trailing.equalToSuperview().inset(30)
//        }

//        shakerImageView.snp.makeConstraints { (make) in
//            make.height.width.equalTo(24)
//        }
        
        contentView.snp.makeConstraints { (make) in
            make.bottom.equalTo(mapLineView.snp.bottom).offset(52)
        }
        
        /// Permission
        [darkerView, permissionStackView].forEach{ addSubview($0) }
        
        darkerView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        permissionStackView.snp.makeConstraints { (make) in
            make.leading.trailing.equalToSuperview().inset(32)
            make.centerY.equalToSuperview()
        }
        
        permissionButton.snp.makeConstraints { (make) in
            make.height.equalTo(50)
        }
    }
    
}

// MARK: - UITextView Delegate
extension AddWishView: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        if textView.tag == 1 {
            delegate.enableAddButton(!textView.text.isEmpty && !textView.text.containsOnlyWhiteSpaces())
        }
        let newSize = textView.sizeThatFits(CGSize(width: textView.frame.size.width, height: CGFloat.greatestFiniteMagnitude))
        textView.snp.updateConstraints { (make) in
            make.height.greaterThanOrEqualTo(newSize.height)
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if textView.tag == 1 {
            let limit = 100
            if text == "\n" { return false }
            let textCount = (titleTextView.text as NSString).replacingCharacters(in: range, with: text).count
            titlePlaceholder.isHidden = textCount != 0
            titleCountLabel.text = textCount <= limit ? "\(textCount) / \(limit)" : "\(limit) / \(limit)"
            titleCountLabel.textColor = textCount <= limit ? UIColor.appColor(.textSecondary) : UIColor.appColor(.textPrimary)
            return textCount <= limit
        } else {
            let limit = 500
            if text == "\n" && textView.text.last == "\n" { return false }
            let textCount = (descriptionTextView.text as NSString).replacingCharacters(in: range, with: text).count
            descriptionPlaceholder.isHidden = textCount != 0
            descriptionCountLabel.text = textCount <= limit ? "\(textCount) / \(limit)" : "\(limit) / \(limit)"
            descriptionCountLabel.textColor = textCount <= limit ?UIColor.appColor(.textSecondary) : UIColor.appColor(.textPrimary)
            return textCount <= limit
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        var point = textView.frame.origin
            point.y = point.y - safeAreaInsets.top - 50
            scrollView.setContentOffset(CGPoint(x: 0, y: point.y), animated: true)
    }
}

// MARK: - Permission Delegate
extension AddWishView: PermissionDelegate {
    public func didAllow(permission: SPPermission) {
        if permission == .locationWhenInUse || permission == .locationAlwaysAndWhenInUse {
            
        }
    }
    
    public func didDenied() {
        
    }
}
