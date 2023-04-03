

import UIKit

class OnboardingViewController: UICollectionViewController {

    // MARK: - Variables
    private let viewModel: OnboardingViewModel
    
    // MARK: - Outlets
    private let progressView = OnboardingProgressView()
    
    private let nextButton = UIButtonFactory(style: .normal)
        .background(color: UIColor.appColor(.primary)).corner(radius: 25)
        .set(image: Icons.General.arrow_next)
        .tint(color: .white)
        .addTarget(#selector(handleNext))
        .build()
    
    // MARK: - LifeCycle
    init(viewModel: OnboardingViewModel) {
        self.viewModel = viewModel
        let layout = UICollectionViewFlowLayout()
            layout.scrollDirection = .horizontal
        super.init(collectionViewLayout: layout)
    }
    
    required init?(coder: NSCoder) { nil }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        viewModelBinding()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    // MARK: - Binding
    private func viewModelBinding() {
        viewModel.scrollToItem = { [self] (item) in
            collectionView.scrollToItem(at: item, at: .left, animated: true)
        }
        
        viewModel.progressAnimation = { [self] (from, to) in
            progressView.progressAnimation(from: from, to: to)
        }
    }
    
    // MARK: - Actions
    @objc private func handleNext() {
        viewModel.handleNext()
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        // CollectionView
        collectionView.register(OnboardingCell.self, forCellWithReuseIdentifier: OnboardingCell.cellIdentifier())
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isPagingEnabled = true
        collectionView.backgroundColor = UIColor.appColor(.background)
        if #available(iOS 11.0, *) {
            collectionView.contentInsetAdjustmentBehavior = .never
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
        
        // Outlets
        [nextButton, progressView].forEach { view.addSubview($0) }
        
        nextButton.snp.makeConstraints { (make) in
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(48)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(50)
        }
        
        progressView.snp.makeConstraints { (make) in
            make.centerX.centerY.equalTo(nextButton)
            make.width.height.equalTo(80)
        }
    }
    
}

// MARK: - CollectionView Delegate
extension OnboardingViewController: UICollectionViewDelegateFlowLayout {
    
    override func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let newIndex = Int(targetContentOffset.pointee.x / view.frame.width)
        viewModel.changeIndex(newIndex)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.pages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            let nextStep = 1.0 / CGFloat(viewModel.pages.count - viewModel.currentIndex)
            progressView.progressAnimation(from: 0, to: nextStep)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        0
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OnboardingCell.cellIdentifier(), for: indexPath) as! OnboardingCell
        cell.configure(model: viewModel.pages[indexPath.item])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: view.frame.width, height: view.frame.height)
    }
    
}
