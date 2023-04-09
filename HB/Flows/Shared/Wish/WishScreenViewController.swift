 

import UIKit
import Tabman
import Pageboy

class WishScreenViewController: TabmanViewController {

    // MARK: - Variables
    private let viewModel: FullWishViewModel
    private let fullHistoryViewModel: FullHistoryViewModel
    private let wishDetailViewModel: WishDetailViewModel
    
    public lazy var viewControllers = [FullWishViewController(viewModel: viewModel, wishDetailViewModel: wishDetailViewModel, fullHistoryViewModel: fullHistoryViewModel),
                                       WishMomentsViewController(viewModel: viewModel, fullHistoryViewModel: fullHistoryViewModel)]
    
    // MARK: - LifeCycle
    init(viewModel: FullWishViewModel, fullHistoryViewModel: FullHistoryViewModel, wishDetailViewModel: WishDetailViewModel) {
        self.viewModel = viewModel
        self.fullHistoryViewModel = fullHistoryViewModel
        self.wishDetailViewModel = wishDetailViewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - Actions
    @objc private func handleMore() {
        guard let wishVM = viewModel.wishVM else { return }
        
        handleWishMore(wishVM: wishVM, deleteCompletionHandler: { [self] in
            self.navigationController?.popViewController(animated: true)
        }, exitCompletionHandler: { [self] in
            self.navigationController?.popViewController(animated: true)
        })
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        navigationItem.titleView = LogoTitleView()
        view.backgroundColor = .systemBackground
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: Icons.General.more, style: .plain, target: self, action: #selector(handleMore))
        
        dataSource = self
        let bar = TMBar.ButtonBar()
        bar.layout.transitionStyle = .snap // Customize
        bar.layout.alignment = .centerDistributed
        bar.backgroundView.style = .blur(style: .regular)
        bar.buttons.customize { (button) in
            button.tintColor = UIColor.appColor(.textPrimary)
            button.selectedTintColor =  UIColor.appColor(.primary)
            button.snp.makeConstraints { (make) in
                make.width.equalTo(140)
            }
            
        }
        addBar(bar, dataSource: self, at: .top)
    }
    
}

// MARK: - TabMan
extension WishScreenViewController: PageboyViewControllerDataSource, TMBarDataSource {
    func numberOfViewControllers(in pageboyViewController: PageboyViewController) -> Int {
        return viewControllers.count
    }

    func viewController(for pageboyViewController: PageboyViewController,
                        at index: PageboyViewController.PageIndex) -> UIViewController? {
        return viewControllers[index]
    }

    func defaultPage(for pageboyViewController: PageboyViewController) -> PageboyViewController.Page? {
        return nil
    }

    func barItem(for bar: TMBar, at index: Int) -> TMBarItemable {
        let title = index == 0 ? "Хобби" : "Истории"
        return TMBarItem(title: title)
    }
}

// MARK: - Wish Detail
extension WishScreenViewController {
    
    // MARK: - More Alert
    func handleWishMore(wishVM: WishViewModel, deleteCompletionHandler: (() -> Void)?, exitCompletionHandler: (() -> Void)?) {
        
        let alert = UIAlertController(title: LocalizedText.profile.SETTINGS, message: wishVM.title, preferredStyle: .actionSheet)

        alert.addAction(UIAlertAction(title: LocalizedText.alert.shareWish, style: .default, handler: { (_) in
            let vc = UIActivityViewController(activityItems: [URL(string: "https://wanty.io?wish=" + wishVM.id)!], applicationActivities: [])
            self.present(vc, animated: true)
        }))
        
        if wishVM.isMyWish || self.checkIsAdmin(){
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


extension WishScreenViewController {
    private func checkIsAdmin() -> Bool {
        for uid in Constants.admins.adminUIDs {
            if DB.Helper.uid == uid {
                return true
            }
        }
        return false
    }
}



