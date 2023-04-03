

import UIKit

// MARK: - Coordinator Protocol
protocol Coordinator : class {
    var childCoordinators : [Coordinator] { get set }
    func start()
}

extension Coordinator {
    func store(coordinator: Coordinator) {
        childCoordinators.append(coordinator)
    }

    func free(coordinator: Coordinator) {
        childCoordinators = childCoordinators.filter { $0 !== coordinator }
    }
}

class BaseCoordinator : Coordinator {
    var childCoordinators : [Coordinator] = []
    var isCompleted: (() -> ())?
    
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        fatalError("Children should implement `start`.")
    }
}

// MARK: - App Coordinator
class AppCoordinator : BaseCoordinator, SharedCoordinatorProtocol {

    private let window : UIWindow
    private var pushData: PushData?

    init(window: UIWindow, pushData: PushData?) {
        self.window = window
        self.pushData = pushData
        let navigationController = UINavigationController()
        super.init(navigationController: navigationController)
    }

    override func start() {
        // preparing root view
        let initialCoordinator = InitialCoordinator(navigationController: navigationController, pushData: pushData)

        // store child coordinator
        self.store(coordinator: initialCoordinator)
        initialCoordinator.start()

        window.rootViewController = navigationController
        window.makeKeyAndVisible()

        // detect when free it
        initialCoordinator.isCompleted = { [weak self] in
            self?.free(coordinator: initialCoordinator)
        }
    }
}


