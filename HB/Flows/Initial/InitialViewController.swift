
import UIKit

class InitialViewController: UIViewController {
    
    // MARK: - Variables
    private let viewModel: InitialViewModel
    weak var timer: Timer?
    
    // MARK: - Outlets
    private let logoImageView = UIImageViewFactory(image: Icons.General.splash)
        .content(mode: .scaleAspectFit)
        .tint(color: .white)
        .build()
    
    private let logoTitleLabel = UIImageViewFactory(image: Icons.General.logoTitle)
        .content(mode: .scaleAspectFit)
        .tint(color: .white)
        .build()
    
    private lazy var wishExampleLabel = UILabelFactory(text: viewModel.wishesExample.last)
        .text(color: .white)
        .font(Fonts.Heading3)
        .build()
    
    // MARK: - LifeCycle
    init(viewModel: InitialViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { nil }
    
    deinit {
        timer?.invalidate()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        viewModelBinding()
        startTimerToShowWishExamples()
        
        // DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.viewModel.viewDidLoad()
        // }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    // MARK: - Binding
    private func viewModelBinding() {
        viewModel.stopTimer = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.timer?.invalidate()
        }
    }
    
    // MARK: - Private Methods
    private func startTimerToShowWishExamples() {
        timer?.invalidate()   // just in case you had existing `Timer`, `invalidate` it before we lose our reference to it
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.wishExampleLabel.text = self.viewModel.wishesExample.first
            let first = self.viewModel.wishesExample.removeFirst()
            self.viewModel.wishesExample.append(first)
        }
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        view.backgroundColor = UIColor.appColor(.primary)
        
        [logoImageView, logoTitleLabel, wishExampleLabel].forEach { view.addSubview($0) }
        
        logoImageView.snp.makeConstraints { (make) in
            make.width.equalToSuperview().multipliedBy(0.7)
            make.center.equalToSuperview()
        }
        
        logoTitleLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().inset(70)
            make.height.equalTo(24)
        }
        
        wishExampleLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(logoTitleLabel.snp.top).offset(-50)
        }
    }
    
}
