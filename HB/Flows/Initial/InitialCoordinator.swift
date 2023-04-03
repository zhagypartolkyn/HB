
import UIKit

class InitialCoordinator : BaseCoordinator {
    
    private var pushData: PushData?
    
    init(navigationController: UINavigationController, pushData: PushData?) {
        self.pushData = pushData
        super.init(navigationController: navigationController)
    }
    
    // MARK: - Start
    override func start() {
        let vm = InitialViewModel()
        let vc = InitialViewController(viewModel: vm)

        vm.navigateAuthFlow = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.navigateAuthFlow(navigationController: strongSelf.navigationController)
        }

        vm.navigateAppFlow = { [weak self] (userVM) in
            guard let strongSelf = self else { return }
            RealmHelper.updateFirebaseLocaleProfile(userVM: userVM) {
                strongSelf.navigateAppFlow(navigationController: strongSelf.navigationController)
            }
        }

        navigationController.pushViewController(vc, animated: true)
    }

    // MARK: - Onboarding Flow
    private func navigateAuthFlow(navigationController: UINavigationController) {
        let authCoordinator = AuthenticationCoordinator(navigationController: navigationController)
        
        authCoordinator.isCompleted = { [weak self] in
            self?.free(coordinator: authCoordinator)
            self?.start()
        }
        
        self.store(coordinator: authCoordinator)
        authCoordinator.start()
    }
    
    // MARK: - TabBar Flow
    private func navigateAppFlow(navigationController: UINavigationController) {
        let tabbarCoordinator = TabBarCoordinator(navigationController: navigationController, pushData: pushData)
        
        tabbarCoordinator.isCompleted = { [weak self] in
            self?.free(coordinator: tabbarCoordinator)
            self?.navigationController.dismiss(animated: true)
            self?.navigateAuthFlow(navigationController: navigationController)
        }
        
        self.store(coordinator: tabbarCoordinator)
        tabbarCoordinator.start()
    }
    
}
