 

import UIKit
import SnapKit

class InterestingPeopleCell: UITableViewCell {
    
    // MARK: - Variables
    private var usersFirstRow: [UserViewModel] = []
    private var usersSecondRow: [UserViewModel] = []
    private var animationIndex = 0
    private var timer : Timer?
    public var isError: Bool = false
    
    // MARK: - Outlets
    private let mainView = UIViewFactory()
        .background(color: UIColor.appColor(.background))
        .corner(radius: Constants.Radius.card)
        .build()
    
    private let titleLabel = UILabelFactory(text: LocalizedText.Interesting.PEOPLE_IN_YOUR_CITY)
        .text(color: UIColor.appColor(.textPrimary))
        .font(Fonts.Heading3)
        .build()
    
    private let subtitleLabel = UILabelFactory(text: LocalizedText.feed.feedFind)
        .text(color: UIColor.appColor(.textSecondary))
        .font(Fonts.Secondary)
        .build()
    
    private lazy var firstCollectionView : UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 16
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(UserCell.self, forCellWithReuseIdentifier: UserCell.cellIdentifier())
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isUserInteractionEnabled = false
        collectionView.delegate = self
        collectionView.dataSource = self
        return collectionView
    }()
    
    private lazy var secondCollectionView : UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 16
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(UserCell.self, forCellWithReuseIdentifier: UserCell.cellIdentifier())
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isUserInteractionEnabled = false
        collectionView.delegate = self
        collectionView.dataSource = self
        return collectionView
    }()
    
    private let darkerView = UIViewFactory()
        .background(color:UIColor.appColor(.primary))
        .corner(radius: Constants.Radius.card, corners: [.layerMinXMinYCorner, .layerMaxXMinYCorner])
        .alpha(0.5)
        .hide()
        .build()
    
    private let errorLabel = UILabelFactory(text: LocalizedText.Interesting.INTERESTING_PEOPLE_ERROR)
        .font(Fonts.Heading3)
        .numberOf(lines: 0)
        .text(align: .center)
        .text(color: .white)
        .hide()
        .build()
    
    // MARK: - LifeCycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Actions
    @objc func handleTimerCollection(){
        animationIndex += 120
        let destinationRect = CGRect(x: animationIndex, y: 0, width: 1, height: 1)
        
        UIView.animate(withDuration: 5, delay: 0, options: .curveLinear) {
            self.firstCollectionView.scrollRectToVisible(destinationRect, animated: false)
            self.secondCollectionView.scrollRectToVisible(destinationRect, animated: false)
            UIView.performWithoutAnimation {
                self.firstCollectionView.layoutIfNeeded()
                self.secondCollectionView.layoutIfNeeded()
            }
        } completion: { (bool) in
            
        }
    }
    
    // MARK: - Public Methods
    public func configure(_ placeId: String?) {
        guard let placeId = placeId else { return }
        
        titleLabel.text = placeId == UserLocationType.world.rawValue ? "Люди со всего мира" : LocalizedText.Interesting.PEOPLE_IN_YOUR_CITY
        
        let query = Queries.User.placeId(placeId: placeId, lastDocumentSnapshot: nil, limit: 30)
        DB.fetchViewModels(model: User.self, viewModel: UserViewModel.self, query: query) { [self] (result) in
            switch result {
            case .success((let models, _, _)):
                self.usersFirstRow = models
                self.usersSecondRow = models.reversed()
                firstCollectionView.reloadData()
                secondCollectionView.reloadData()
                setupTimer()
                handleTimerCollection()
                self.showError(false)
            case .failure(_):
                self.showError(true)
            }
            
            setupTimer()
        }
    }
    
    // MARK: - Private Methods
    private func setupTimer() {
        timer?.invalidate()
        timer = nil
        timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(handleTimerCollection), userInfo: nil, repeats: true)
        timer?.fire()
    }
    
    private func showError(_ status: Bool) {
        darkerView.isHidden = !status
        errorLabel.isHidden = !status
        isError = status
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        backgroundColor = .clear
        contentView.addSubview(mainView)
        mainView.layer.applyCardShadow()
        
        mainView.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().inset(24)
        }
        
        [subtitleLabel, titleLabel, firstCollectionView, secondCollectionView].forEach { mainView.addSubview($0) }
        
        subtitleLabel.snp.makeConstraints { (make) in
            make.leading.trailing.equalToSuperview().inset(24)
            make.bottom.equalToSuperview().inset(16)
        }
        
        titleLabel.snp.makeConstraints { (make) in
            make.leading.trailing.equalToSuperview().inset(24)
            make.bottom.equalTo(subtitleLabel.snp.top).offset(-4)
        }
        
        firstCollectionView.snp.makeConstraints { (make) in
            make.top.equalTo(24)
            make.height.equalTo(80)
            make.leading.trailing.equalToSuperview()
        }
        
        secondCollectionView.snp.makeConstraints { (make) in
            make.top.equalTo(firstCollectionView.snp.bottom).offset(16)
            make.height.equalTo(80)
            make.leading.trailing.equalToSuperview()
        }
        
        [darkerView, errorLabel].forEach { addSubview($0) }
        darkerView.snp.makeConstraints { (make) in
            make.top.leading.trailing.equalTo(mainView)
            make.bottom.equalTo(titleLabel.snp.top).offset(-8)
        }
        
        errorLabel.snp.makeConstraints { (make) in
            make.leading.trailing.equalTo(darkerView).inset(16)
            make.centerY.equalTo(darkerView)
        }
    }

}

// MARK: - Collection Delegate
extension InterestingPeopleCell : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return usersFirstRow.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: UserCell.cellIdentifier(), for: indexPath) as! UserCell
        if secondCollectionView == collectionView && usersFirstRow.count > 0 {
            let user = usersSecondRow[indexPath.row % usersSecondRow.count]
            cell.configure(user.avatar)
        } else if self.firstCollectionView == collectionView && usersFirstRow.count > 0 {
            let user = usersFirstRow[indexPath.row % usersFirstRow.count]
            cell.configure(user.avatar)
        }
        
        if indexPath.row == (usersFirstRow.count - 10) {
            let peopleA = usersFirstRow
            usersFirstRow.insert(contentsOf: peopleA, at: usersFirstRow.count - 1)
            usersSecondRow.insert(contentsOf: peopleA.reversed(), at: usersSecondRow.count - 1)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: 80, height: 80)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let isFirstRow = collectionView == self.firstCollectionView
        return UIEdgeInsets(top: 0, left: isFirstRow ? 16 : 56, bottom: 0, right: 0)
    }
}
