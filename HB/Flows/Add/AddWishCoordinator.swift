 

import UIKit

class AddWishCoordinator : BaseCoordinator, SharedCoordinatorProtocol {

    override func start() {
        let vm = AddWishViewModel()
        let vc = AddWishViewController(viewModel: vm)
        vc.hidesBottomBarWhenPushed = true
        
        vm.navigateMap = { [weak self] (delegate) in
            guard let strongSelf = self else { return }
            strongSelf.navigateAddMap(delegate: delegate)
        }
        
        navigationController.pushViewController(vc, animated: true)
    }

    private func navigateAddMap(delegate: HandleAddCoordinate) {
        let vm = AddLocationViewModel()
        let vc = AddMapViewController(delegate: delegate, viewModel: vm)
        
        vm.navigateBack = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.navigationController.popViewController(animated: true)
        }
        
        navigationController.pushViewController(vc, animated: true)
    }
    
    
}
