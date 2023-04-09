 
import UIKit
import SnapKit
import AVFoundation
import SVProgressHUD

protocol FullHistoryCellDelegate: class {
    func actionWish(historyVM: HistoryViewModel)
    func actionProfile(historyVM: HistoryViewModel)
    func actionMore(historyVM: HistoryViewModel)
    func actionBack()
}

class FullHistoryCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Variables
    private var delegate: FullHistoryCellDelegate?
    var historyVM: HistoryViewModel?
    
    var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    private var playerLooper: AVPlayerLooper?
    private let statusKey = "status"
    
    // MARK: - Outlets
    private let wishFixedView = WishFixedView(isHistory: true)
    
    private let mainBlurredImageView = UIImageViewFactory()
        .content(mode: .scaleAspectFill)
        .corner(radius: Constants.Radius.card, corners: [.layerMinXMaxYCorner, .layerMaxXMaxYCorner])
        .build()
    
    private let blurredEffectView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .dark)
        let view = UIVisualEffectView(effect: blurEffect)
//        view.isHidden = true
        return view
    }()
    
    private let mainImageView = UIImageViewFactory()
        .content(mode: .scaleAspectFit)
        .build()
    
    private let playImageView = UIImageViewFactory(image: Icons.Wish.play)
        .tint(color: .white)
        .background(color: UIColor.black.withAlphaComponent(0.3))
        .corner(radius: 14)
        .build()
    
    private let closeButton = UIButtonFactory()
        .background(color: .white)
        .set(image: Icons.General.cancel)
        .corner(radius: 6)
        .build()
    
    private let bottomTextLabel = UILabelFactory()
        .text(color: .white)
        .font(Fonts.Secondary)
        .numberOf(lines: 0)
        .build()
    
    private let bottomTextLabelFull = UILabelFactory()
        .text(color: .white)
        .font(Fonts.Secondary)
        .hide()
        .numberOf(lines: 0)
        .build()
    
    private let avatarImageView = UIImageViewFactory()
        .content(mode: .scaleAspectFit)
        .corner(radius: 16)
        .border(color: .white)
        .border(width: 1)
        .build()
    
    private let usernameLabel = UILabelFactory()
        .font(Fonts.Semibold.Secondary)
        .text(color: .white)
        .build()
    
    private let dateLabel = UILabelFactory()
        .font(Fonts.Tertiary)
        .text(color: .white)
        .build()
    
    private lazy var usernameAndDateStack = UIStackViewFactory(views: [usernameLabel, dateLabel])
        .axis(.vertical)
        .spacing(0)
        .build()
    
    private let moreButton = UIButtonFactory()
        .set(image: Icons.General.more)
        .tint(color: .white)
        .build()
    
    // MARK: - LifeCycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupActions()
    }
    
    required init?(coder: NSCoder) {
        nil
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        historyVM = nil
        player?.pause()
        playerLayer?.player = nil
        playerLayer?.removeFromSuperlayer()
        playerLayer = nil
    }
    
    // MARK: - Actions
    @objc func playerItemDidReachEnd(notification: NSNotification) {
        SVProgressHUD.dismiss()
        player?.seek(to: .zero, completionHandler: { (_) in
            self.player?.play()
        })
    }
    
    @objc func handleWish() {
        guard let historyVM = historyVM else { return }
        delegate?.actionWish(historyVM: historyVM)
    }
    
    @objc func handleProfile() {
        guard let historyVM = historyVM else { return }
        delegate?.actionProfile(historyVM: historyVM)
    }
     
    @objc func handleShare() { // BUG:
        guard let historyVM = historyVM else { return }
        delegate?.actionMore(historyVM: historyVM)
    }
    
    @objc private func handleShowMoreText() {
        blurredEffectView.isHidden.toggle()
        bottomTextLabel.isHidden.toggle()
        bottomTextLabelFull.isHidden.toggle()
    }
    
    @objc private func handleBack() {
        delegate?.actionBack()
    }
    
    // MARK: - Methods
    func configure(delegate: FullHistoryCellDelegate, viewModel: HistoryViewModel) {
        self.delegate = delegate
        
        self.historyVM = viewModel
        
        wishFixedView.configureView(title: LocalizedText.wish.STORIES_AT_WILL, subtitle: viewModel.wishTitle)
        
        avatarImageView.kf.setImage(with: URL(string: viewModel.avatar))
        usernameLabel.text = viewModel.username
        dateLabel.text = viewModel.publishDate
        
        mainBlurredImageView.kf.setImage(with: URL(string: viewModel.media))
        mainImageView.kf.setImage(with: URL(string: viewModel.media))
        
        bottomTextLabel.text = viewModel.title
        bottomTextLabelFull.text = viewModel.title
        
        if viewModel.title.count > 63 {
            var lblText = viewModel.title
            lblText = String(lblText.prefix(63))
            
            let attributedText = NSMutableAttributedString(string: lblText, attributes: [.foregroundColor: UIColor.white, .font: Fonts.Secondary])
            attributedText.append(NSAttributedString(string: " \(LocalizedText.wish.STORIES_TITLE_FULL)", attributes: [.foregroundColor: UIColor.gray, .font: Fonts.Tertiary]))
            
            bottomTextLabel.attributedText = attributedText
            bottomTextLabel.isUserInteractionEnabled = true
            bottomTextLabelFull.isUserInteractionEnabled = true
            bottomTextLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleShowMoreText)))
            bottomTextLabelFull.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleShowMoreText)))
        }
        
        if let video = viewModel.video, let url = URL(string: video) {
            let asset = AVAsset(url: url)
            let playerItem = AVPlayerItem(asset: asset)
            let queuePlayer = AVQueuePlayer()
            playerLooper = AVPlayerLooper(player: queuePlayer, templateItem: playerItem)
            player = queuePlayer
            playerLayer = AVPlayerLayer(player: player)
            playerLayer?.videoGravity = .resizeAspect
            playerLayer?.frame = CGRect(x: 0, y: 0, width: contentView.frame.width, height: contentView.frame.height - safeAreaInsets.bottom - 24 - 32 - 24 - 32)
            mainBlurredImageView.layer.addSublayer(playerLayer!)
        }
        
        mainBlurredImageView.addSubview(playImageView)
        
        playImageView.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.height.width.equalTo(64)
        }
        
        playImageView.isHidden = true
    }
    
    // MARK: - Public Methods
    func pause() {
        player?.pause()
    }

    func play() {
        if let viewModel = historyVM, let _ = viewModel.video {
            player?.play()
            playImageView.isHidden = true
        }
    }
    
    func toggle() {
        if let player = player, let viewModel = historyVM, let _ = viewModel.video {
            if player.timeControlStatus == .playing {
                playImageView.isHidden = false
                pause()
            } else {
                playImageView.isHidden = true
                play()
            }
        }
    }
    
    // MARK: - Private Methods
    private func setupActions() {
        wishFixedView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleWish)))

        [avatarImageView, usernameAndDateStack].forEach {
            $0.isUserInteractionEnabled = true
            $0.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleProfile)))
        }
        
        moreButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleShare)))
        
        closeButton.addTarget(self, action: #selector(handleBack), for: .touchUpInside)
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        backgroundColor = .black
        
        [mainBlurredImageView, wishFixedView, bottomTextLabel, bottomTextLabelFull, 
         avatarImageView, usernameAndDateStack, closeButton, moreButton].forEach{ contentView.addSubview($0) }
        
        // Image with blur effect + title
        mainBlurredImageView.snp.makeConstraints { (make) in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalTo(avatarImageView.snp.top).offset(-24)
        }
        
        [blurredEffectView, mainImageView].forEach{ mainBlurredImageView.addSubview($0) }
        
        blurredEffectView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        mainImageView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        closeButton.snp.makeConstraints { (make) in
            make.width.height.equalTo(24)
            make.trailing.equalToSuperview().inset(12)
            make.top.equalTo(safeAreaLayoutGuide).offset(24)
        }
        
        wishFixedView.snp.makeConstraints { (make) in
            make.top.equalTo(safeAreaLayoutGuide).offset(24)
            make.leading.equalToSuperview()
            make.trailing.equalTo(closeButton.snp.leading).offset(12)
            make.height.equalTo(44)
        }
        
        bottomTextLabel.snp.makeConstraints { (make) in
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalTo(mainBlurredImageView).inset(24)
            make.height.equalTo(48)
        }
        
        bottomTextLabelFull.snp.makeConstraints { (make) in
            make.top.equalTo(wishFixedView.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalTo(mainBlurredImageView).inset(24)
        }
        
        avatarImageView.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().inset(16)
            make.height.width.equalTo(32)
            make.bottom.equalTo(safeAreaLayoutGuide).offset(-24)
        }
        
        usernameAndDateStack.snp.makeConstraints { (make) in
            make.leading.equalTo(avatarImageView.snp.trailing).offset(16)
            make.centerY.equalTo(avatarImageView)
        }
        
        moreButton.snp.makeConstraints { (make) in
            make.height.width.equalTo(24)
            make.centerY.equalTo(avatarImageView)
            make.trailing.equalToSuperview().inset(16)
        }
    }
}
