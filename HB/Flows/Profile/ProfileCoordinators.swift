 

import UIKit

class ProfileCoordinator : BaseCoordinator, SharedCoordinatorProtocol {

    override func start() {
        navigateProfile(uid: DB.Helper.uid, isHideBackButton: true)
    }

}
