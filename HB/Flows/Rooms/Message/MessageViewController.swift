 

import UIKit
import MessageKit
import InputBarAccessoryView

class MessageViewController: MessagesViewController {
    
    // MARK: - Variables
    private let viewModel: MessageViewModel
    
    // MARK: - Outlets
    private lazy var imagePicker = ImagePicker(presentationController: self, delegate: self, withVideo: true)
    private let wishFixedView = WishFixedView()
    private let refreshControl = UIRefreshControl()
    
    // MARK: - LifeCycle
    init(viewModel: MessageViewModel, wishId: String? = nil, roomId: String? = nil) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        showHUD()
        viewModel.configure(wishId: wishId, roomId: roomId)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModelBinding()
        setupDelegates()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let room = viewModel.roomViewModel {
            viewModel.configure(roomId: room.id)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewModel.leave()
    }
    
    // MARK: - Action Methods
    @objc private func loadMore() {
        viewModel.loadMoreMessages()
    }
    
    @objc func handleMediaButton() {
        imagePicker.presentAlert(.nativeVideo)
    }
    
    @objc func handleNavigation() {
        guard let roomVM = viewModel.roomViewModel else { return }
        viewModel.navigateRoomSettings?(roomVM, viewModel.myNotifyStatus)
    }
    
    @objc func hideKeyboard() {
        messageInputBar.inputTextView.resignFirstResponder()
    }
    
    // MARK: - Public Methods
    public func getRoomId() -> String {
        return viewModel.roomViewModel?.id ?? ""
    }
    
    // MARK: - Private Methods
    private func viewModelBinding() {
        viewModel.setupAvatarAndWishTitle = { [self] (roomVM) in
            showHUD(type: .dismiss)
            setupAvatarAndWishTitle(roomVM: roomVM)
        }
        
        viewModel.setupNavigation = { [self] (title, subtitle) in
            setupNavigationWith(title: title, subtitle: subtitle)
        }
        
        viewModel.reloadDataCallbackAndScrollDown = { [self] in
            messagesCollectionView.reloadData()
            messagesCollectionView.scrollToLastItem(animated: true)
        }
        
        viewModel.reloadDataCallbackAndSaveOffset = { [self] in
            messagesCollectionView.reloadDataAndKeepOffset()
        }
        
        viewModel.endRefreshing = { [self] in
            refreshControl.endRefreshing()
        }
        
        viewModel.quitFromController = { [self] in
            navigationController?.popViewController(animated: false)
        }
        
        viewModel.showHudError = { [self] (error) in
            showHUD(type: .error, text: error)
        }
    }
    
    private func setupAvatarAndWishTitle(roomVM: RoomViewModel) {
        var posX = 16
        let avatarsView = UIView(frame: CGRect(x: 0, y: 0, width: 48, height: 32))
        [roomVM.firstUserThumb, roomVM.secondUserThumb].forEach { (thumbUrl) in
            let isSetAvatar = thumbUrl != ""
            let avatarImageView = UIImageView(frame: CGRect(x: posX, y: 0, width: 32, height: 32))
            avatarImageView.layer.masksToBounds = true
            avatarImageView.layer.cornerRadius = 16
            avatarImageView.layer.borderWidth = isSetAvatar ? 2 : 0
            avatarImageView.layer.borderColor = UIColor.appColor(.background).cgColor
            avatarImageView.kf.setImage(with: URL(string: thumbUrl))
            avatarsView.addSubview(avatarImageView)
            posX -= 16
        }
        avatarsView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleNavigation)))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: avatarsView)
        
        wishFixedView.configureView(title: roomVM.typeIsGroup ? LocalizedText.messages.GROUP_CHAT_OF_WISH : LocalizedText.messages.SINGLE_CHAT_OF_WISH, subtitle: roomVM.wishTitle)
    }
    
    private func setupNavigationWith(title: String, subtitle: String) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 0
        paragraphStyle.alignment = .center
        
        let attributedText = NSMutableAttributedString(string: title, attributes: [.foregroundColor: UIColor.appColor(.textPrimary), .font: Fonts.Semibold.Paragraph])
        attributedText.append(NSAttributedString(string: "\n\(subtitle)", attributes: [.foregroundColor: UIColor.appColor(.textSecondary), .font: Fonts.Tertiary]))
        attributedText.addAttribute(.paragraphStyle, value:paragraphStyle, range:NSRange(location: 0, length: attributedText.length))
        
        let button = UIButton()
        button.setAttributedTitle(attributedText, for: .normal)
        button.titleLabel!.numberOfLines = 0
        button.addTarget(self, action: #selector(self.handleNavigation), for: .touchUpInside)
        
        navigationItem.titleView = button
    }
    
    private func setupDelegates() {
        wishFixedView.delegate = self
        messageInputBar.delegate = self
        maintainPositionOnKeyboardFrameChanged = true
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messageCellDelegate = self
        
        messagesCollectionView.register(InfoMessageCell.self)
        messagesCollectionView.register(NewMemberCell.self)
        messagesCollectionView.collectionViewLayout = InfoMessageCellFlowLayout()
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        navigationItem.largeTitleDisplayMode = .never
        
        messagesCollectionView.addSubview(refreshControl)
        refreshControl.addTarget(self, action: #selector(loadMore), for: .valueChanged)
        
        wishFixedView.layer.shadowColor = UIColor(red: 0.035, green: 0.384, blue: 1, alpha: 0.05).cgColor // BUG:
        wishFixedView.layer.shadowOpacity = 1
        wishFixedView.layer.shadowRadius = 20
        wishFixedView.layer.shadowOffset = CGSize(width: 0, height: 10)
        
        view.addSubview(wishFixedView)
        wishFixedView.snp.makeConstraints { (make) in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(44)
        }
        
        messagesCollectionView.contentInset = UIEdgeInsets(top: 44, left: 0, bottom: 0, right: 0)
        messagesCollectionView.backgroundColor = UIColor.appColor(.background)
        
        let mediaButton = InputBarButtonItem()
        mediaButton.setSize(CGSize(width: 36, height: 36), animated: false)
        mediaButton.setImage(Icons.Chat.attach, for: .normal)
        mediaButton.tintColor = UIColor.appColor(.primary)
        mediaButton.addTarget(self, action: #selector(handleMediaButton), for: .touchUpInside)
        
        messageInputBar.layer.shadowColor = UIColor(red: 0.035, green: 0.384, blue: 1, alpha: 0.05).cgColor
        messageInputBar.layer.shadowOpacity = 1
        messageInputBar.layer.shadowRadius = 20
        messageInputBar.layer.shadowOffset = CGSize(width: 0, height: -10)
        
        messageInputBar.inputTextView.placeholder = LocalizedText.messages.WRITE_MESSAGE
        messageInputBar.backgroundView.backgroundColor = UIColor.appColor(.background)
        messageInputBar.separatorLine.height = 0
        
        messageInputBar.inputTextView.backgroundColor = UIColor.appColor(.background)
        messageInputBar.inputTextView.placeholderTextColor = UIColor.appColor(.textPlaceholder)
        messageInputBar.inputTextView.textContainerInset = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        messageInputBar.inputTextView.placeholderLabelInsets = UIEdgeInsets(top: 8, left: 20, bottom: 8, right: 20)
        messageInputBar.inputTextView.layer.borderColor = UIColor.appColor(.textSecondary).cgColor
        messageInputBar.inputTextView.layer.borderWidth = 0.0
        messageInputBar.inputTextView.layer.cornerRadius = 16.0
        messageInputBar.inputTextView.layer.masksToBounds = true
        messageInputBar.inputTextView.scrollIndicatorInsets = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        messageInputBar.inputTextView.backgroundColor = UIColor.appColor(.textBorder)
        
        messageInputBar.sendButton.setTitle("", for: .normal)
        messageInputBar.sendButton.setImage(Icons.Chat.send, for: .normal)
        messageInputBar.sendButton.setSize(CGSize(width: 36, height: 36), animated: false)
        
        messageInputBar.setLeftStackViewWidthConstant(to: 36, animated: false)
        messageInputBar.setRightStackViewWidthConstant(to: 36, animated: false)
        messageInputBar.setStackViewItems([mediaButton], forStack: .left, animated: false)
    }
    
    // MARK: - CollectionView override
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        guard let messagesDataSource = messagesCollectionView.messagesDataSource else { return false }
        let message = messagesDataSource.messageForItem(at: indexPath, in: messagesCollectionView)
        
        switch message.kind {
        case .text, .attributedText, .emoji, .photo, .location, .video, .custom:
            selectedIndexPathForMenu = indexPath
            return true
        default:
            return false
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        guard let room = viewModel.roomViewModel, let messagesDataSource = messagesCollectionView.messagesDataSource else { return false }
        let message = messagesDataSource.messageForItem(at: indexPath, in: messagesCollectionView)
        
        if (message.sender.senderId == DB.Helper.uid || room.author.uid == DB.Helper.uid) && action == NSSelectorFromString("delete:") {
            return true
        } else {
            return super.collectionView(collectionView, canPerformAction: action, forItemAt: indexPath, withSender: sender)
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
        guard let messagesDataSource = messagesCollectionView.messagesDataSource else { return }
        let message = messagesDataSource.messageForItem(at: indexPath, in: messagesCollectionView)
        
        if action == NSSelectorFromString("delete:") {
            viewModel.delete(message: message)
            
            collectionView.performBatchUpdates({
                collectionView.deleteSections([indexPath.section])
            }, completion: { (_) in
                collectionView.reloadData()
            })
        } else {
            super.collectionView(collectionView, performAction: action, forItemAt: indexPath, withSender: sender)
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let messagesDataSource = messagesCollectionView.messagesDataSource else {
            fatalError("Ouch. nil data source for messages")
        }
        
        let message = messagesDataSource.messageForItem(at: indexPath, in: messagesCollectionView) as! Message
        
        if message.type == "info" && message.uid.isEmpty {
            let cell = messagesCollectionView.dequeueReusableCell(InfoMessageCell.self, for: indexPath)
            cell.configure(with: message, at: indexPath, and: messagesCollectionView)
            return cell
        } else if message.type == "info" && !message.uid.isEmpty {
            let cell = messagesCollectionView.dequeueReusableCell(NewMemberCell.self, for: indexPath)
            cell.configure(with: viewModel.roomViewModel?.activeUsers[message.uid], at: indexPath, and: messagesCollectionView)
            return cell
        }
        
        return super.collectionView(collectionView, cellForItemAt: indexPath)
    }
    
}

// MARK: - ImagePicker Delegate
extension MessageViewController: ImagePickerDelegate {
    func didSelect(image: UIImage) {
        viewModel.sendMessage(image: image)
    }

    func didSelect(url: URL) {
        viewModel.sendMessage(video: url)
    }
}

// MARK: - WishFixedView Delegate
extension MessageViewController: WishFixedViewDelegate {
    func handleWish() {
        guard let roomVM = viewModel.roomViewModel else { return }
        viewModel.navigateWish?(nil, roomVM.wishId)
    }
}

// MARK: - InputBarAccessoryView Delegate
extension MessageViewController: InputBarAccessoryViewDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        viewModel.sendMessage(text: text)
        messageInputBar.inputTextView.text = ""
        messagesCollectionView.scrollToLastItem(animated: true)
    }
}

// MARK: - Messages DataSource
extension MessageViewController: MessagesDataSource {
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return viewModel.messages[indexPath.section]
    }
    
    func currentSender() -> SenderType {
        return MockSenderItem(senderId: DB.Helper.uid, displayName: (viewModel.roomViewModel?.allUsers[DB.Helper.uid]?.username) ?? "Username not found")
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return viewModel.messages.count
    }
    
    func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        return NSAttributedString(string: message.sentDate.toFormat("dd MMM yyyy"),
                                  attributes: [.font: Fonts.Small,
                                               .foregroundColor: UIColor.darkGray])
    }
    
    func messageTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        return NSAttributedString(string: message.sender.displayName,
                                  attributes: [.font: Fonts.Tertiary])
    }
    
    func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        return NSAttributedString(string: message.sentDate.toFormat("HH:mm"),
                                  attributes: [.font: Fonts.Small,
                                               .foregroundColor: UIColor.appColor(.textSecondary)])
    }
    
    func configureMediaMessageImageView(_ imageView: UIImageView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        switch message.kind {
        case .photo(let photoItem):
            guard let url = photoItem.url else {
                imageView.kf.indicator?.startAnimatingView()
                return
            }
            imageView.kf.indicatorType = .activity
            imageView.kf.setImage(with: url)
        case .video(let videoItem):
            guard let url = videoItem.url else {
                imageView.kf.indicator?.startAnimatingView()
                return
            }
            imageView.kf.indicatorType = .activity
            imageView.kf.setImage(with: url)
        default:
            break
        }
    }
}

// MARK: - MessageCell Delegate
extension MessageViewController: MessageCellDelegate {
    func didTapAvatar(in cell: MessageCollectionViewCell) {
        guard let indexPath = messagesCollectionView.indexPath(for: cell),
              let messagesDataSource = messagesCollectionView.messagesDataSource else { return }
        
        let message = messagesDataSource.messageForItem(at: indexPath, in: messagesCollectionView)
        
        if message.sender.senderId != DB.Helper.uid {
            viewModel.navigateProfile?(message.sender.senderId)
        }
    }
    
    func didTapMessage(in cell: MessageCollectionViewCell) {
        // handle message here
    }
    
    func didTapImage(in cell: MessageCollectionViewCell) {
        guard let indexPath = messagesCollectionView.indexPath(for: cell),
              let messagesDataSource = messagesCollectionView.messagesDataSource else { return }
        
        let message = messagesDataSource.messageForItem(at: indexPath, in: messagesCollectionView)
        
        switch message.kind {
        case .photo(let photoItem):
            guard let imageUrl = photoItem.url else { return }
            let vc = MediaViewController(image: imageUrl.absoluteString)
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true)
            
        case .video(let videoItem as MockMediaItem):
            guard let imageUrl = videoItem.url, let videoUrl = videoItem.videoUrl else { return }
            let vc = MediaViewController(image: imageUrl.absoluteString, video: videoUrl.absoluteString)
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true)
            
        default:
            debugPrint("no media")
        }
    }
}

// MARK: - MessagesLayout Delegate
extension MessageViewController: MessagesLayoutDelegate {
    func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        if indexPath.section == 0 { return 35 }
        let previousIndexPath = IndexPath(row: 0, section: indexPath.section - 1)
        let previousMessage = messageForItem(at: previousIndexPath, in: messagesCollectionView)
        let dayDifference = message.sentDate.compare(toDate: previousMessage.sentDate, granularity: .day)
        return dayDifference.rawValue >= 1 ? 35 : 0
    }
    
    func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 30
    }
    
    func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 30
    }
}

// MARK: - MessagesDisplay Delegate
extension MessageViewController: MessagesDisplayDelegate {
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? UIColor.appColor(.primary) : UIColor.appColor(.textBorder)
    }

    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        let corner: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight: .bottomLeft
        return .bubbleTail(corner, .curved)
    }

    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        avatarView.kf.setImage(with: URL(string: viewModel.roomViewModel?.allUsers[message.sender.senderId]?.thumb ?? ""))
    }
}

extension MessageCollectionViewCell {
    override open func delete(_ sender: Any?) {
        // Get the collectionView
        if let collectionView = self.superview as? UICollectionView {
            // Get indexPath
            if let indexPath = collectionView.indexPath(for: self) {
                // Trigger action
                collectionView.delegate?.collectionView?(collectionView, performAction: NSSelectorFromString("delete:"), forItemAt: indexPath, withSender: sender)
            }
        }
    }
}
