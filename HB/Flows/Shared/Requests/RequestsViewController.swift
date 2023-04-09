 

import UIKit
import SwiftDate
import FirebaseFirestore
import SnapKit

class RequestsViewController: UIViewController {
    
    // MARK: - Variables
    private let viewModel: RequestViewModel
    
    // MARK: - Outlets
    private lazy var wishFixedView: WishFixedView = {
        let view = WishFixedView()
        view.delegate = self
        return view
    }()
    
    private lazy var tableView: UITableView = {
        let tb = UITableView()
        tb.backgroundColor = UIColor.appColor(.background)
        tb.keyboardDismissMode = .interactive
        tb.register(RequestCell.self, forCellReuseIdentifier: RequestCell.cellIdentifier())
        tb.dataSource = self
        tb.delegate = self
        tb.isHidden = true
        return tb
    }()
    
    private let errorImageView = UIImageViewFactory(image: Icons.Error.requests)
        .content(mode: .scaleAspectFit)
        .build()
    
    private let errorLabel = UILabelFactory(text: LocalizedText.error.requests)
        .font(Fonts.Semibold.Paragraph)
        .text(align: .center)
        .text(color: UIColor.appColor(.textSecondary))
        .numberOf(lines: 0)
        .build()
    
    private lazy var errorStackView = UIStackViewFactory(views: [errorImageView, errorLabel])
        .axis(.vertical)
        .spacing(12)
        .distribution(.fill)
        .alignment(.center)
        .hide()
        .build()
    
    // MARK: - LifeCycle
    init(viewModel: RequestViewModel, wishVM: WishViewModel? = nil, wishId: String? = nil) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        viewModel.configure(wishVM: wishVM, wishId: wishId)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        viewModelBinding()
    }
    
    // MARK: - Private Methods
    private func viewModelBinding() {
        viewModel.setupWishTitle = { [self] (title) in
            wishFixedView.configureView(title: LocalizedText.wish.requests.REQUESTS_WISH, subtitle: title)
        }
        
        viewModel.setupTableView = { [self] in
            self.tableView.isHidden = false
            self.errorStackView.isHidden = true
        }
        
        viewModel.setupNavigationTitle = { [self] (title) in
            self.navigationItem.title = title
        }
        
        viewModel.setupErroView = { [self] (isCompleted) in
            self.errorStackView.isHidden = isCompleted
            self.tableView.isHidden = true
        }
        
        viewModel.reloadData = { [self] in
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        
        viewModel.showHUD = { [self] (type, text) in
            self.showHUD(type: type, text: text)
        }
    }
    
    
    // MARK: - Setup UI
    private func setupUI() {
        view.backgroundColor = UIColor.appColor(.background)
        navigationItem.title = LocalizedText.wish.requests.REQUESTS
        
        [wishFixedView, errorStackView, tableView].forEach { view.addSubview( $0 ) }
        
        wishFixedView.snp.makeConstraints { (make) in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(44)
        }
        
        errorStackView.snp.makeConstraints { (make) in
            make.leading.trailing.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
        }
        
        errorImageView.snp.makeConstraints { (make) in
            make.width.height.equalTo(200)
        }
        
        tableView.snp.makeConstraints { (make) in
            make.top.equalTo(wishFixedView.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
        
    }
}

// MARK: - WishFixedView Delegate
extension RequestsViewController: WishFixedViewDelegate {
    func handleWish() {
        // handle wish
    }
}

// MARK: - UITableView Delegate
extension RequestsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.requestsInDateSection.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let firstMessageInSection = viewModel.requestsInDateSection[section].first {
            let label = DateHeaderLabel()
            label.text = firstMessageInSection.date.publish?.dateValue().toFormat("dd.MM.yyyy")
            
            let containerView = UIView()
            containerView.addSubview(label)
            
            label.snp.makeConstraints { (make) in
                make.center.equalToSuperview()
            }
            
            return containerView
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.requestsInDateSection[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: RequestCell.cellIdentifier(), for: indexPath) as! RequestCell
        cell.delegate = self
        cell.selectionStyle = .none
        cell.configure(request: viewModel.requests[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let uid = viewModel.requests[indexPath.row].author.uid
        viewModel.navigateProfile?(uid)
    }
    
}

// MARK: - RequestCell Delegate
extension RequestsViewController: RequestCellDelegate {
    
    func handleAcceptButton(request: Request) {
        guard let wishVM = viewModel.wishVM else { return }
        let username = request.author.username
        
        let subtitleGroup = String.localizedStringWithFormat(LocalizedText.wish.requests.ACCEPT_GROUP, username)
        let subtitleSingle = String.localizedStringWithFormat(LocalizedText.wish.requests.ACCEPT_TET_A_TET, username)
        let alert = UIAlertController(title: "\(LocalizedText.wish.requests.CONFIRM_REQUEST_TITLE)", message: wishVM.isGroupWish ? subtitleGroup : subtitleSingle, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: LocalizedText.General.yes, style: .default, handler: {[self] _ in
            if wishVM.isGroupWish {
                self.viewModel.acceptToGroup(request: request, completionHandler: {
                    let uid = request.author.uid
                    self.sendPushNotification(uid: uid, wishVM: wishVM)
                    self.pushToChatAfterAcceptRequest(username: username, isGroupWish: wishVM.isGroupWish, wishId: request.wish.id)
                })
            } else {
                self.viewModel.acceptToSingle(request: request, completionHandler: { [self] (roomId) in
                    let uid = request.author.uid
                    self.sendPushNotification(uid: uid, wishVM: wishVM)
                    self.pushToChatAfterAcceptRequest(username: username, isGroupWish: wishVM.isGroupWish, roomId: roomId)
                })
            }
        }))
        
        alert.addAction(UIAlertAction(title: LocalizedText.General.cancel, style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
    
    private func pushToChatAfterAcceptRequest(username: String, isGroupWish: Bool, wishId: String? = nil, roomId: String? = nil) {
        let title = String.localizedStringWithFormat(LocalizedText.wish.requests.ACCEPTED_TITLE, username)
        let message = isGroupWish ? LocalizedText.wish.requests.ACCEPTED_GROUP : String.localizedStringWithFormat(LocalizedText.wish.requests.ACCEPTED_TET_A_TET, username)
        
        let migrationAlert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        migrationAlert.addAction(UIAlertAction(title: LocalizedText.messages.CHAT, style: .default, handler: {[self] (_) in
            self.viewModel.navigateMessage?(wishId, roomId)
        }))
        migrationAlert.addAction(UIAlertAction(title: LocalizedText.wish.requests.STAY_ON_REQUESTS, style: .cancel, handler: nil))
        self.present(migrationAlert, animated: true)
    }
    
    func handleDeclineButton(request: Request) {
        guard let wishVM = viewModel.wishVM else { return }
        let username = request.author.username
        
        let alert = UIAlertController(title: LocalizedText.wish.requests.REJECT_REQUEST_TITLE, message: String.localizedStringWithFormat(LocalizedText.wish.requests.REJECT_REQUEST_DESCRIPTION, username), preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: LocalizedText.General.yes, style: .default, handler: { [self] _ in
            showHUD(type: .success, text: LocalizedText.wish.requests.REJECT_REQUEST_HUD)
            Ref.Fire.request(id: request.id).updateData([Ref.Request.status.decline: true])
            viewModel.requests.removeAll(where: { $0.id == request.id })
            viewModel.divideRequestsByDate(wishVM: wishVM)
        }))
        
        alert.addAction(UIAlertAction(title: LocalizedText.General.cancel, style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
    
    private func sendPushNotification(uid: String, wishVM: WishViewModel) {
        sendRequestNotification(
            toUid: uid,
            title: wishVM.title,
            subtitle: "Вас приняли в желание!",
            type: "wish",
            linkId: wishVM.id,
            badge: 1)
    }
    
}
