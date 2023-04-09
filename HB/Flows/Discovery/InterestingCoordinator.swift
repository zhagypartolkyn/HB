//
 

import UIKit

protocol InterestingCoordinatorProtocol : class {
    var childCoordinators : [Coordinator] { get set }
    func start()
}

class InterestingCoordinator : BaseCoordinator, SharedCoordinatorProtocol {

    override func start() {
        let vm = InterestingViewModel()
        let fullHistoryViewModel = FullHistoryViewModel()
        let vc = InterestingViewController(viewModel: vm, fullHistoryViewModel: fullHistoryViewModel)
        
        vm.navigateHistory = { [weak self] (historyVMs, currentIndexPath) in
            guard let strongSelf = self else { return }
            strongSelf.navigateHistory(viewModel: fullHistoryViewModel, currentIndexPath: currentIndexPath, isCameFromWish: false)
        }
        
        vm.navigateCity = { [weak self] (placeId) in
            guard let strongSelf = self else { return }
            strongSelf.navigateCity(placeId: placeId)
        }
        
        vm.navigatePeople = { [weak self] (placeId) in
            guard let strongSelf = self else { return }
            strongSelf.navigatePeople(placeId: placeId)
        }
        
        vm.navigateProfile = { [weak self] (uid) in
            guard let strongSelf = self else { return }
            strongSelf.navigateProfile(uid: uid)
        }
        
        navigationController.pushViewController(vc, animated: true)
    }
    
    private func navigateCity(placeId: String) {
        let vm = MapViewModel(placeId: placeId)
        let vc = MapViewController(viewModel: vm)
        vc.hidesBottomBarWhenPushed = true
        
        vm.navigateProfile = { [weak self] (uid) in
            guard let strongSelf = self else { return }
            strongSelf.navigateProfile(uid: uid)
        }

        vm.navigateWish = { [weak self] (wishVM, wishId) in
            guard let strongSelf = self else { return }
            strongSelf.navigateWish(wishVM: wishVM, wishId: wishId )
        }
        
        navigationController.pushViewController(vc, animated: true)
    }
    
    private func navigatePeople(placeId: String) {
        let vm = PeopleViewModel(placeId: placeId)
        let vc = PeopleViewController(viewModel: vm)
        vc.hidesBottomBarWhenPushed = true
        
        vm.navigateProfile = { [weak self] (uid) in
            guard let strongSelf = self else { return }
            strongSelf.navigateProfile(uid: uid)
        }
        
        vm.navigateSearch = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.navigatePeopleSearch()
        }
        
        navigationController.pushViewController(vc, animated: true)
    }
    
    private func navigatePeopleSearch() {
        let vm = PeopleSearchViewModel()
        let vc = PeopleSearchViewController(viewModel: vm)
        vc.hidesBottomBarWhenPushed = true
        
        
        vm.navigateProfile = { [weak self] (uid) in
            guard let strongSelf = self else { return }
            strongSelf.navigateProfile(uid: uid)
        }
        
        navigationController.pushViewController(vc, animated: true)
    }

}
