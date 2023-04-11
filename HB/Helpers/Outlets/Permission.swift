 

import SPPermissions

public protocol PermissionDelegate {
    func didAllow(permission: SPPermission)
    func didDenied()
}

open class Permission: NSObject {
    
    private let delegate: PermissionDelegate
    
    public init(delegate: PermissionDelegate) {
        self.delegate = delegate
        super.init()
    }
    
}

extension Permission: SPPermissionsDelegate {

    public func deniedData(for permission: SPPermission) -> SPPermissionDeniedAlertData? {
        let data = SPPermissionDeniedAlertData()
        data.alertOpenSettingsDeniedPermissionTitle = LocalizedText.permissions.PERMISSION_DENIED_TITLE
        data.alertOpenSettingsDeniedPermissionDescription = LocalizedText.permissions.PERMISSION_DENIED_DESCRIPTION
        data.alertOpenSettingsDeniedPermissionButtonTitle = LocalizedText.profile.SETTINGS
        data.alertOpenSettingsDeniedPermissionCancelTitle = LocalizedText.General.cancel
        return data
    }
    
    public func didAllow(permission: SPPermission) {
        delegate.didAllow(permission: permission)
    }
    
    public func didDenied(permission: SPPermission) {
        delegate.didDenied()
    }
    
    func isEnabled(allPermissions: [SPPermission], viewController: UIViewController? = nil) -> Bool {
        let permissions = allPermissions.filter { !$0.isAuthorized }
        if permissions.isEmpty {
            return true
        } else {
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            if let vc = appDelegate.getCurrentVC() {
                let controller = SPPermissions.native(permissions)
                controller.delegate = self
                controller.present(on: vc)
            } else if let viewController = viewController {
                let controller = SPPermissions.native(permissions)
                controller.delegate = self
                controller.present(on: viewController)
            }
            
            return false
        }
    }
    
    func justCheck(allPermissions: [SPPermission], viewController: UIViewController) -> Bool {
        let permissions = allPermissions.filter { !$0.isAuthorized }
        return permissions.isEmpty
    }
    
}
