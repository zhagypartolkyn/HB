 

import UIKit
import SnapKit

public protocol InterestingStarCellDelegate: class {
    func didChoose(uid: String)
}

class InterestingStarCell: UITableViewCell {
    
    // MARK: - Variables
    private var viewModels: [UserViewModel] = []
    weak var delegate: InterestingStarCellDelegate!
    public var isError: Bool = false
    
    // MARK: - Outlets
    private let mainView = UIViewFactory()
        .background(color: UIColor.appColor(.backgroundSecondary))
        .corner(radius: Constants.Radius.card)
        .build()
    
    private lazy var collectionView : UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 16
        
        var collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(StarCell.self, forCellWithReuseIdentifier: StarCell.cellIdentifier())
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isUserInteractionEnabled = true
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 24)
        collectionView.delegate = self
        collectionView.dataSource = self
        return collectionView
    }()
    
    private let darkerView = UIViewFactory()
        .background(color: UIColor.appColor(.primary))
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
    
    // MARK: - Private Methods
    public func configure(_ placeId: String?) {
        guard let placeId = placeId else { return }
        
        let query = Ref.Fire.users
            .whereField("position", isGreaterThan: 0)
            .order(by: "position", descending: true)
        
        DB.fetchViewModels(model: User.self, viewModel: UserViewModel.self, query: query) { (result) in
            switch result {
            case .success((let viewModels, _, _)):
                self.viewModels = viewModels
                self.collectionView.reloadData()
                self.showError(false)
            case .failure(_ ):
                self.showError(true)
            }
        }
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

        mainView.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.bottom.equalToSuperview().inset(24)
            make.leading.trailing.equalToSuperview()
        }

        [collectionView].forEach{ mainView.addSubview($0) }

        collectionView.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(230)
        }
        
        [darkerView, errorLabel].forEach { addSubview($0) }
        darkerView.snp.makeConstraints { (make) in
            make.top.leading.trailing.equalTo(mainView)
            make.bottom.equalTo(collectionView.snp.bottom).offset(-8)
        }
        
        errorLabel.snp.makeConstraints { (make) in
            make.leading.trailing.equalTo(darkerView).inset(16)
            make.centerY.equalTo(darkerView)
        }
    }
    
}

// MARK: - Collection Delegate
extension InterestingStarCell : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: StarCell.cellIdentifier(), for: indexPath) as! StarCell
        cell.configure(vm: viewModels[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate.didChoose(uid: viewModels[indexPath.item].uid)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: 148, height: 220)
    }
}
