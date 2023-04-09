

import UIKit

class FeedCoordinator : BaseCoordinator, SharedCoordinatorProtocol {

    // MARK: - Start
    override func start() {
        navigateHome()
    }
    
    private func navigateHome() {
        let vm = HomeViewModel()
        let vmCity = CityViewModel()
        let vmMoments = FullHistoryViewModel()
        let topWishesViewModel = TopWishesViewModel()
        let wishDetailViewModel: WishDetailViewModel = WishDetailViewModel()
        let vc = HomeViewController(viewModel: vm, cityViewModel: vmCity, fullHistoryViewModel: vmMoments, wishDetailViewModel: wishDetailViewModel, topWishesViewModel: topWishesViewModel)
        
        vm.navigateSearch = { [weak self] (placeId) in
            guard let strongSelf = self else { return }
            strongSelf.navigateSearch(placeId: placeId)
        }
        
        topWishesViewModel.navigateProfile = { [weak self] (uid) in
            guard let strongSelf = self else { return }
            strongSelf.navigateProfile(uid: uid)
        }
        
        vmCity.navigateProfile = { [weak self] (uid) in
            guard let strongSelf = self else { return }
            strongSelf.navigateProfile(uid: uid)
        }
        
        topWishesViewModel.navigateWish = { [weak self] (wishVM, wishId) in
            guard let strongSelf = self else { return }
            strongSelf.navigateWish(wishVM: wishVM, wishId: wishId )
        }

        vmCity.navigateWish = { [weak self] (wishVM, wishId) in
            guard let strongSelf = self else { return }
            strongSelf.navigateWish(wishVM: wishVM, wishId: wishId )
        }
        
        topWishesViewModel.navigateReport = { [weak self] (reportObject) in
            guard let strongSelf = self else { return }
            strongSelf.navigateReport(reportObject: reportObject)
        }

        vmCity.navigateReport = { [weak self] (reportObject) in
            guard let strongSelf = self else { return }
            strongSelf.navigateReport(reportObject: reportObject)
        }
        
        topWishesViewModel.navigateComplete = { [weak self] (wishVM) in
            guard let strongSelf = self else { return }
            strongSelf.navigateComplete(wishVM: wishVM)
        }

        vmCity.navigateComplete = { [weak self] (wishVM) in
            guard let strongSelf = self else { return }
            strongSelf.navigateComplete(wishVM: wishVM)
        }
        
        vmMoments.navigateHistory = { [weak self] (index) in
            guard let strongSelf = self else { return }
            strongSelf.navigateHistory(viewModel: vmMoments, currentIndexPath: index, isCameFromWish: false)
        }
        
        navigationController.pushViewController(vc, animated: true)
    }
    
    private func navigateHome2() {
        let vm = HouseViewModel()
        let fullHistoryViewModel = FullHistoryViewModel()
        let wishDetailViewModel: WishDetailViewModel = WishDetailViewModel()
        let vc = HouseViewController(viewModel: vm, fullHistoryViewModel: fullHistoryViewModel, wishDetailViewModel: wishDetailViewModel)
        
        vm.navigateSearch = { [weak self] (placeId) in
            guard let strongSelf = self else { return }
            strongSelf.navigateSearch(placeId: placeId)
        }
        
        vm.navigateProfile = { [weak self] (uid) in
            guard let strongSelf = self else { return }
            strongSelf.navigateProfile(uid: uid)
        }

        vm.navigateWish = { [weak self] (wishVM, wishId) in
            guard let strongSelf = self else { return }
            strongSelf.navigateWish(wishVM: wishVM, wishId: wishId )
        }

        vm.navigateReport = { [weak self] (reportObject) in
            guard let strongSelf = self else { return }
            strongSelf.navigateReport(reportObject: reportObject)
        }

        vm.navigateComplete = { [weak self] (wishVM) in
            guard let strongSelf = self else { return }
            strongSelf.navigateComplete(wishVM: wishVM)
        }
        
        fullHistoryViewModel.navigateHistory = { [weak self] (currentIndexPath) in
            guard let strongSelf = self else { return }
            strongSelf.navigateHistory(viewModel: fullHistoryViewModel, currentIndexPath: currentIndexPath, isCameFromWish: false)
        }
        
        navigationController.pushViewController(vc, animated: true)
    }
    
    private func navigateSearch(placeId: String) {
        let vm = SearchViewModel()
        let wishDetailViewModel: WishDetailViewModel = WishDetailViewModel()
        let vc = SearchViewController(viewModel: vm, wishDetailViewModel: wishDetailViewModel, placeId: placeId)
        vc.hidesBottomBarWhenPushed = true
        
        vm.navigateProfile = { [weak self] (uid) in
            guard let strongSelf = self else { return }
            strongSelf.navigateProfile(uid: uid)
        }

        vm.navigateWish = { [weak self] (wishVM, wishId) in
            guard let strongSelf = self else { return }
            strongSelf.navigateWish(wishVM: wishVM, wishId: wishId )
        }

        vm.navigateReport = { [weak self] (reportObject) in
            guard let strongSelf = self else { return }
            strongSelf.navigateReport(reportObject: reportObject)
        }

        vm.navigateComplete = { [weak self] (wishVM) in
            guard let strongSelf = self else { return }
            strongSelf.navigateComplete(wishVM: wishVM)
        }
        
        navigationController.pushViewController(vc, animated: true)
    }
    
}
