 

import UIKit
import AVFoundation
import SnapKit

class MediaViewController: UIViewController {
    
    // MARK: - Variables
    private var imageURL: String
    private var videoURL: String?
    
    private var playerLayer: AVPlayerLayer?
    private var player: AVPlayer?
    private var observation: Any?
    private let playerStatus = "status"
    
    // MARK: - Outlets
    private let closeButton = UIButtonFactory(style: .normal)
        .background(color: .white)
        .set(image: Icons.General.cancel)
        .tint(color: .black)
        .corner(radius: Constants.Radius.general)
        .addTarget(#selector(handleClose))
        .build()
    
    private let imageView = UIImageViewFactory()
        .content(mode: .scaleAspectFit)
        .background(color: .black)
        .build()

    private let playIcon = UIImageViewFactory(image: Icons.Wish.play)
        .tint(color: .white)
        .build()
    
    // MARK: - LifeCycle
    init(image: String, video: String? = nil) {
        imageURL = image
        videoURL = video
        
        // Setup media
        imageView.kf.setImage(with: URL(string: self.imageURL))
        playIcon.isHidden = videoURL == nil
        
        // Stop video
        player?.pause()
        playerLayer?.removeFromSuperlayer()
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
    
    deinit {
        showHUD(type: .dismiss)
        NotificationCenter.default.removeObserver(self) // Remove Observer
        observation = nil
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
        showHUD(type: .dismiss)
        player?.removeObserver(self, forKeyPath: playerStatus)
        player = nil
    }
        
    // MARK: - Actions
    @objc private func handleZoom(gesture: UIPinchGestureRecognizer) {
        switch gesture.state {
        case .changed:
            let pinchCenter = CGPoint(x: gesture.location(in: imageView).x - imageView.bounds.midX,
                                      y: gesture.location(in: imageView).y - imageView.bounds.midY)
            
            self.imageView.transform = imageView.transform.translatedBy(x: pinchCenter.x, y: pinchCenter.y)
                .scaledBy(x: gesture.scale, y: gesture.scale)
                .translatedBy(x: -pinchCenter.x, y: -pinchCenter.y)
            
            gesture.scale = 1
        case .ended:
            UIView.animate(withDuration: 0.4, animations: {
                self.imageView.transform = CGAffineTransform.identity
            })
        default: return
        }
    }
    
    @objc private func handleClose() {
        dismiss(animated: true)
    }
    
    @objc private func handlePlay() {
        if let videoUrl = videoURL, let url = URL(string: videoUrl) {
            showHUD()
            self.setupPlayer(url: url)
        }
    }
    
    @objc func playerItemDidReachEnd(notification: NSNotification) {
        showHUD(type: .dismiss)
        playerLayer?.removeFromSuperlayer()
        playIcon.isHidden = false
    }
    
    // MARK: - Private Methods
    private func setupActions() {
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(handleClose))
        swipeDown.direction = .down
        view.addGestureRecognizer(swipeDown)
        
        playIcon.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handlePlay)))
        playIcon.isUserInteractionEnabled = true

        view.addGestureRecognizer(UIPinchGestureRecognizer(target: self, action: #selector(handleZoom(gesture:))))
    }
    
    private func addObserver() {
        observation = player?.addObserver(self,
                                          forKeyPath: playerStatus,
                                          options: NSKeyValueObservingOptions.new,
                                          context: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(playerItemDidReachEnd),
                                               name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
    }
    
    // Player
    private func setupPlayer(url: URL) {
        player = AVPlayer(url: url)
        playerLayer = AVPlayerLayer(player: player)
        playerLayer?.videoGravity = AVLayerVideoGravity.resizeAspect
        playerLayer?.frame = imageView.frame
        imageView.layer.insertSublayer(playerLayer!, at: 5000)
        addObserver()
        player?.play()
        playIcon.isHidden = true
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == playerStatus {
            let status: AVPlayer.Status = player!.status
            switch (status) {
            case AVPlayer.Status.readyToPlay: showHUD(type: .dismiss)
            case AVPlayer.Status.unknown, AVPlayer.Status.failed: break
            default: break
            }
        }
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        [imageView, closeButton, playIcon].forEach { view.addSubview($0) }
        imageView.snp.makeConstraints { (make) in
            make.leading.trailing.equalToSuperview()
            make.height.equalToSuperview()
        }
        
        closeButton.snp.makeConstraints { (make) in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(50)
            make.trailing.equalToSuperview().inset(16)
            make.height.width.equalTo(30)
        }
        
        playIcon.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.height.width.equalTo(64)
        }
    }
    
}
