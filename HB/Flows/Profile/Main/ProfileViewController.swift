//
 

import UIKit
import FirebaseFirestore
import Kingfisher
import SkeletonView
import SnapKit
import FirebaseAuth
import FirebaseMessaging

class ProfileViewController: UITableViewController {
    
    // MARK: - Variables
    private let viewModel: ProfileViewModel
    private let wishDetailViewModel: WishDetailViewModel
    private let isHideBackButton: Bool
    private var countForUpVote: Int = 0
    private var countForDownVote: Int = 0
    
    // MARK: - Outlets
    private let refresher = UIRefreshFactory().addTarget(#selector(showFakeRefreshing)).build()
    
    private let badgeView: UIView = {
        let unreadView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 12))
        unreadView.backgroundColor = UIColor.appColor(.dangerous)
        unreadView.layer.cornerRadius = 6
        unreadView.isUserInteractionEnabled = true
        return unreadView
    }()
    
    private let unreadNotificationsButton: UIButton = {
        let button = UIButton(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 24, height: 24)))
        button.setBackgroundImage(Icons.Notification.on, for: .normal)
        button.contentEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        return button
    }()
    
    private let notificationsButton: UIButton = {
        let button = UIButton(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 24, height: 24)))
        button.setBackgroundImage(Icons.Notification.off, for: .normal)
        button.tintColor = UIColor.appColor(.textPrimary)
        button.contentEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        return button
    }()

    // MARK: - LifeCycle
    init(viewModel: ProfileViewModel, wishDetailViewModel: WishDetailViewModel, isHideBackButton: Bool) {
        self.viewModel = viewModel
        self.wishDetailViewModel = wishDetailViewModel
        self.isHideBackButton = isHideBackButton
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if viewModel.isMyProfile {
            viewModel.listenUnreadNotifications()
        }
        viewModelBinding()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.configureVM()
    }
    
    override func willMove(toParent parent: UIViewController?) {
        super.willMove(toParent: parent)
        if parent == nil {
            viewModel.userListener!.remove()
        }
    }
    
    // MARK: - Actions
    @objc private func handleNotifications() {
        viewModel.navigateActivities?()
    }
    
    @objc private func handleSettings() {
        if viewModel.isMyProfile {
            viewModel.navigateSettings?()
        } else {
            profileAlert()
        }
    }
    
    private func profileAlert() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: LocalizedText.profile.BLOCK, style: .destructive, handler: { [self] _ in
            guard let userVM = viewModel.userVM else { return }
            profileBanAlert(userVM)
        }))
        alert.addAction(UIAlertAction(title: LocalizedText.profile.COMPLAIN, style: .destructive, handler: { [self] _ in
            guard let userVM = viewModel.userVM else { return }
            let reportObject = ReportObject(id: userVM.uid, type: ReportObjectType.profile.rawValue, uid: userVM.uid)
            viewModel.navigateReport?(reportObject)
        }))
        alert.addAction(UIAlertAction(title: LocalizedText.profile.CANCEL, style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
    
    private func profileBanAlert(_ userVM: UserViewModel) {
        let alert = UIAlertController(title: String.localizedStringWithFormat(LocalizedText.profile.BLOCK_USER_TITLE, userVM.username), message: LocalizedText.profile.BLOCK_USER_MESSAGE, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: LocalizedText.profile.BLOCK, style: .destructive, handler: { [self] _ in
            guard let userVM = viewModel.userVM else { return }
            showHUD()
            
            DB.fetchModels(model: BlockedUser.self, query: Queries.BlockedUser.checkIfIBlocked(uid: userVM.uid, myUid: DB.Helper.uid)) { (result) in
                switch result {
                case .success(_):
                    showHUD(type: .info, text: "Пользователь уже заблокирован")
                case .failure(_):
                    
                    let refBlockedUsers = Ref.Fire.myBlockedUsers(uid: DB.Helper.uid).document()
                    let blockedUser = BlockedUser(id: refBlockedUsers.documentID, uid: userVM.uid, date: Timestamp(date: Date()))
                    DB.create(model: blockedUser, ref: refBlockedUsers) { (result) in
                        switch result {
                        case .success(_):
                            showHUD(type: .success, text: "Успешно заблокирован")
                        case .failure(let error):
                            showHUD(type: .error, text: error.localizedDescription)
                        }
                    }
                    
                }
            }
            
        }))
        alert.addAction(UIAlertAction(title: LocalizedText.profile.CANCEL, style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
    
    @objc private func showFakeRefreshing() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.tableView.refreshControl!.endRefreshing()
        }
    }

    // MARK: - Methods
    private func viewModelBinding() {
        viewModel.reloadDataCallback = { [self] in
            tableView.reloadData()
        }
        
        viewModel.showSkeleton = { [self] in
            tableView.showAnimatedSkeleton()
        }
        
        viewModel.hideSkeleton = { [self] in
            if tableView.isSkeletonActive {
                tableView.hideSkeleton()
            }
        }
        
        viewModel.usernameForTitle = { [self] (username, verified) in
            navigationItem.titleView = ProfileVerifiedTitleView(username: username, isVerified: verified)
        }
        
        viewModel.changeUnredNotifications = { [self] (count) in
            updateNotificationsBadge(count: count)
        }
    }
    
    private func checkForDoubleVote() -> Bool{
        if countForUpVote > 1  || countForDownVote > 1{
            showHUD(type: .success, text: "Your vote has been accepted")
            return false
        } else {
            return true
        }
        
    }
    
    private func updateNotificationsBadge(count: Int) {
        unreadNotificationsButton.addTarget(self, action: #selector(handleNotifications), for: .touchUpInside)
        notificationsButton.addTarget(self, action: #selector(handleNotifications), for: .touchUpInside)
        
        badgeView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleNotifications)))
        unreadNotificationsButton.addSubview(badgeView)
        
        let rightSettingsButton = UIBarButtonItem(image: Icons.General.settings, style: .done, target: self, action: #selector(handleSettings))
        rightSettingsButton.tintColor = UIColor.appColor(.textPrimary)
        let rightNotificationsButton = UIBarButtonItem(customView: count == 0 ? notificationsButton : unreadNotificationsButton)
        navigationItem.rightBarButtonItems = [rightSettingsButton, rightNotificationsButton]
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        tableView.register(ProfileHeaderCell.self, forCellReuseIdentifier: ProfileHeaderCell.cellIdentifier())
        tableView.register(WishCell.self, forCellReuseIdentifier: WishCell.cellIdentifier())
        tableView.register(ProfileErrorView.self, forCellReuseIdentifier: ProfileErrorView.cellIdentifier())
        tableView.register(SkeletonWishCell.self, forCellReuseIdentifier: SkeletonWishCell.cellIdentifier())
        tableView.backgroundColor = UIColor.appColor(.backgroundSecondary)
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.refreshControl = refresher
        tableView.isSkeletonable = true
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 16, right: 0)
        
        view.backgroundColor = UIColor.appColor(.backgroundSecondary)
        navigationItem.largeTitleDisplayMode = .never
        
        let rightButton = UIBarButtonItem(image: viewModel.isMyProfile ? Icons.General.settings : Icons.General.more,
                                          style: .done, target: self, action: #selector(handleSettings))
        rightButton.tintColor = UIColor.appColor(.textPrimary)
        navigationItem.rightBarButtonItem = rightButton
    }
    
}

// MARK: - Table View
extension ProfileViewController: SkeletonTableViewDataSource {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if viewModel.displayWishes.isEmpty, viewModel.userVM != nil {
            return 2
        } else {
            return viewModel.displayWishes.count + 1
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: ProfileHeaderCell.cellIdentifier()) as! ProfileHeaderCell
            
            if let userVM = viewModel.userVM {
                cell.configure(user: userVM)
                cell.configureConnects(topConnects: viewModel.topConnects, counter: viewModel.connectsCount ?? 0)
            }
            
            if let isFollow = viewModel.isFollowing {
                cell.configureFollowButton(isActive: !isFollow)
            }
            
            if let disable = viewModel.isDisableFollowButton {
                cell.disableFollowButton(disable: disable)
            }
            
            cell.backgroundColor = .clear
            cell.delegate = self
            cell.selectionStyle = .none
            return cell
        } else {
            
            if viewModel.displayWishes.isEmpty {
                let cell = tableView.dequeueReusableCell(withIdentifier: ProfileErrorView.cellIdentifier(), for: indexPath) as! ProfileErrorView
                cell.errorView.delegate = self
                cell.selectionStyle = .none
                
                switch viewModel.activeSegmentIndex {
                case .active: cell.errorView.configureView(type: viewModel.isMyProfile ? .myActive : .otherActive)
                case .completed: cell.errorView.configureView(type: viewModel.isMyProfile ? .myComplete : .otherComplete)
                default: cell.errorView.configureView(type: viewModel.isMyProfile ? .myParticipant : .otherParticipant(viewModel.userVM!.name))
                }
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: WishCell.cellIdentifier()) as! WishCell
                cell.configure(model: viewModel.displayWishes[indexPath.row - 1])
                cell.selectionStyle = .none
                cell.delegate = self
                return cell
            }
        }
        
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row != 0 {
            if !viewModel.displayWishes.isEmpty {
                detailAction(viewModel: viewModel.displayWishes[indexPath.row - 1])
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func collectionSkeletonView(_ skeletonView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.batchSize
    }
    
    func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
        SkeletonWishCell.cellIdentifier()
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let contentYoffset = scrollView.contentOffset.y
        if !viewModel.isPerformingRequest, !viewModel.isLastPage[viewModel.activeSegmentIndex]!, !viewModel.displayWishes.isEmpty {
            let scroollViewHeight = scrollView.frame.height
            let distanceFromBottom = scrollView.contentSize.height - contentYoffset
            if distanceFromBottom < scroollViewHeight {
                viewModel.getWishes(viewModel.activeSegmentIndex)
            }
        }
    }
}

// MARK: - Profile Segment Delegate
extension ProfileViewController {
    func handleSegment(_ index: IndexCase) {
        viewModel.activeSegmentIndex = index
        viewModel.batchSize = viewModel.increasingConstant
        viewModel.displayWishes = []
        
        if !viewModel.wishes[index]!.isEmpty {
            viewModel.displayWishes = viewModel.wishes[index]!
            tableView.reloadData()
        } else {
            viewModel.getWishes(viewModel.activeSegmentIndex)
        }
    }
}

// MARK: - Header Cell Delegate
extension ProfileViewController: ProfileHeaderCellDelegate {
    func handleConnects() {
        viewModel.navigateConnects?(viewModel.uid!)
    }
    
    func handleFollow() {
        viewModel.handleFollow()
    }
    
    func handleProfileImage() {
        guard let userVM = viewModel.userVM else { return }
        viewModel.navigateMedia?(userVM.largeAvatar)
    }

    func handleProfileEdit() {
        viewModel.navigateEditProfile?()
    }

    func handleFollowings() {
        viewModel.navigateFollow?(viewModel.userVM!, true)
    }
    
    func handleFollowers() {
        viewModel.navigateFollow?(viewModel.userVM!, false)
    }
}

// MARK: - Wish Cell Actions Delegate
extension ProfileViewController: WishCellDelegate {
    
    func upVoteAction(viewModel: WishViewModel, userWhoLiked: String, touches: Int) {
        
        wishDetailViewModel.upVote(viewModel: viewModel, userUid: DB.Helper.uid) { (result) in
            switch result {
            case .success(let check) :
                if check {
                    self.showHUD(type: .success, text: LocalizedText.wish.VOTE_UP)
                } else {
                    self.showHUD(type: .success, text: LocalizedText.wish.VOTE_DOUBLE)
                }
            case .failure(let error): print("DEBUG: Upvoting went wrong \(error.localizedDescription)")
                
            }
        }
    }
    
    func downVoteAction(viewModel: WishViewModel, userWhoDisliked: String, touches: Int) {
        
        wishDetailViewModel.downVote(viewModel: viewModel, userUid: DB.Helper.uid) { (result) in
            switch result {
            case .success(let check ):
                if check {
                    self.showHUD(type: .success, text: LocalizedText.wish.VOTE_DOWN)
                } else {
                    self.showHUD(type: .success, text: LocalizedText.wish.VOTE_DOUBLE)
                }
            case .failure(let error): print("DEBUG: Downvoting went wrong \(error.localizedDescription)")
            }
            
        } 
    }
    
    func avatarAction(viewModel: WishViewModel) {
        self.viewModel.navigateWish?(viewModel, nil)
    }
    
    func moreAction(viewModel: WishViewModel) {
        handleWishMore(wishVM: viewModel, deleteCompletionHandler: nil, exitCompletionHandler: nil)
    }
    
    func detailAction(viewModel: WishViewModel) {
        self.viewModel.navigateWish?(viewModel, nil)
    }
}

// MARK: - ErrorView Delegate
extension ProfileViewController: ErrorViewDelegate {
    func handleButton() {
        tabBarController?.selectedIndex = 2
    }
}

// MARK: - Wish Detail
extension ProfileViewController {
    
    // MARK: - More Alert
    func handleWishMore(wishVM: WishViewModel, deleteCompletionHandler: (() -> Void)?, exitCompletionHandler: (() -> Void)?) {
        
        let alert = UIAlertController(title: LocalizedText.profile.SETTINGS, message: wishVM.title, preferredStyle: .actionSheet)

        alert.addAction(UIAlertAction(title: LocalizedText.alert.shareWish, style: .default, handler: { (_) in
            let vc = UIActivityViewController(activityItems: [URL(string: "https://wanty.io?wish=" + wishVM.id)!], applicationActivities: [])
            self.present(vc, animated: true)
        }))
        
        if wishVM.isMyWish {
            alert.addAction(UIAlertAction(title: LocalizedText.alert.completeWish, style: .default, handler: { (_) in
                self.handleComplete(wishVM: wishVM)
            }))
            
            alert.addAction(UIAlertAction(title: LocalizedText.alert.deleteWish, style: .destructive, handler: { (_) in
                self.handleDelete(wishVM: wishVM, completionHandler: deleteCompletionHandler)
            }))
        } else {
            if wishVM.isIParticipate {
                alert.addAction(UIAlertAction(title: LocalizedText.alert.exitWish, style: .destructive, handler: { (_) in
                    self.handleWish(wishVM: wishVM, completionHandler: exitCompletionHandler)
                }))
            }
            alert.addAction(UIAlertAction(title: LocalizedText.alert.complainOnWish, style: .destructive, handler: { (_) in
                let reportObject = ReportObject(id: wishVM.id, type: ReportObjectType.wish.rawValue, uid: wishVM.uid)
                self.viewModel.navigateReport?(reportObject)
            }))
        }

        alert.addAction(UIAlertAction(title: LocalizedText.General.cancel, style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
        
    }
    
    // MARK: - Delete Alert
    private func handleDelete(wishVM: WishViewModel, completionHandler: (() -> Void)?) {
        
        let alert = UIAlertController(title: LocalizedText.alert.deleteWishTitle, message: wishVM.title, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: LocalizedText.General.cancel, style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: LocalizedText.General.yes, style: .destructive, handler: { (_) in
            self.showHUD()
            self.wishDetailViewModel.deleteWish(id: wishVM.id) { [self] (result) in
                switch result {
                case .success(_): showHUD(type: .success, text: LocalizedText.alert.deleteWishSuccess)
                case .failure(let error): showHUD(type: .error, text: "Error with deleting \(error.localizedDescription)")
                }
            }
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Exit Alert
    private func handleWish(wishVM: WishViewModel, completionHandler: (() -> Void)?) {
        
        let alert = UIAlertController(title: LocalizedText.alert.exitWishSubtitle, message: LocalizedText.alert.exitWishTitle, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: LocalizedText.General.cancel, style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: LocalizedText.alert.exitWish, style: .destructive, handler: { [self] (_) in
            showHUD()
            
            self.wishDetailViewModel.exitWish(id: wishVM.id) { (result) in
                switch result {
                case .success(_): showHUD(type: .success, text: LocalizedText.alert.exitWishSuccess)
                case .failure(let error): showHUD(type: .error, text: "Error with exiting \(error.localizedDescription)")
                }
            }
            
        }))
        self.present(alert, animated: true)
        
    }
    
    // MARK: - Complete Alert
    private func handleComplete(wishVM: WishViewModel) {
        
        let alert = UIAlertController(title: LocalizedText.alert.completionWish, message: LocalizedText.alert.completionWishTitle, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: LocalizedText.General.cancel, style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: LocalizedText.General.complete, style: .default, handler: { (_) in
            
            if wishVM.isGroupWish {
                self.showHUD()
                self.wishDetailViewModel.completeGroupWish(id: wishVM.id) { (text) in
                    self.showHUD(type: .success, text: text)
                }
            } else {
                self.viewModel.navigateComplete?(wishVM)
            }
            
        }))
        self.present(alert, animated: true)
        
    }
    
}

