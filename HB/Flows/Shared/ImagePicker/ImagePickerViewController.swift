 
import UIKit
import SPPermissions
import MobileCoreServices

public protocol ImagePickerDelegate: class {
    func didSelect(image: UIImage)
    func didSelect(url: URL)
}

public enum CameraType {
    case customHistory
    case nativePhoto
    case nativeVideo
}

open class ImagePicker: NSObject, UINavigationControllerDelegate {

    // MARK: - Variables
    private let presentationController: UIViewController
    private lazy var permission = Permission(delegate: self)
    private let delegate: ImagePickerDelegate
    
    private var cameraTypeForCheckPermission: CameraType?
    private var pickerTypeForCheckPermission: UIImagePickerController.SourceType?

    // MARK: - Outlets
    private lazy var pickerController: UIImagePickerController = {
        let controller = UIImagePickerController()
        controller.allowsEditing = false
        controller.delegate = self
        controller.videoMaximumDuration = 60
        return controller
    }()
    
    // MARK: - LifeCycle
    public init(presentationController: UIViewController, delegate: ImagePickerDelegate, withVideo: Bool) {
        self.presentationController = presentationController
        self.delegate = delegate
        
        super.init()
        
        pickerController.mediaTypes = withVideo ? [String(kUTTypeImage), String(kUTTypeMovie)] : [String(kUTTypeImage)]
    }

    // MARK: - Public Methods
    public func presentAlert(_ cameraType: CameraType = .nativePhoto) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        alertController.addAction(UIAlertAction(title: LocalizedText.permissions.PERMISSION_CAMERA_TITLE, style: .default) { (action) in
            self.actionAfterPermission(pickerType: .camera, cameraType: cameraType)
        })
        
        alertController.addAction(UIAlertAction(title: LocalizedText.permissions.PERMISSION_GALLERY_TITLE, style: .default) { (action) in
            self.actionAfterPermission(pickerType: .photoLibrary, cameraType: cameraType)
        })

        alertController.addAction(UIAlertAction(title: LocalizedText.General.cancel, style: .cancel, handler: nil))

        self.presentationController.present(alertController, animated: true)
    }
    
    // MARK: - Private Methods
    private func actionAfterPermission(pickerType: UIImagePickerController.SourceType, cameraType: CameraType) {
        cameraTypeForCheckPermission = cameraType
        pickerTypeForCheckPermission = pickerType
        
        switch pickerType {
        case .camera:
            switch cameraType {
            case .customHistory: checkPermission([.camera, .microphone]) { self.showHistoryCamera() }
            case .nativePhoto: checkPermission([.camera]) { self.showPicker(pickerType) }
            case .nativeVideo: checkPermission([.camera, .microphone]) { self.showPicker(pickerType) }
            }
        default:
            checkPermission([.photoLibrary], completion: { self.showPicker(pickerType) })
        }
    }
    
    // MARK: - Private Helpers
    private func checkPermission(_ permissions: [SPPermission], completion: @escaping(() -> Void)) {
        if permission.isEnabled(allPermissions: permissions, viewController: self.presentationController) {
            completion()
        }
    }
    
    private func showHistoryCamera() {
        let vc = CameraHistoryViewController(delegate: delegate)
        vc.modalPresentationStyle = .fullScreen
        presentationController.present(vc, animated: true)
    }
    
    private func showPicker(_ type: UIImagePickerController.SourceType) {
        pickerController.sourceType = type
        presentationController.present(pickerController, animated: true)
    }
    
    private func pickerController(_ pickerController: UIImagePickerController, image: UIImage? = nil, videoURL: URL? = nil) {
        if let image = image {
            delegate.didSelect(image: image)
            print("DEBUG: Picked photo")
        } else if let videoURL = videoURL {
            delegate.didSelect(url: videoURL)
        }
        pickerController.dismiss(animated: true, completion: nil)
    }
}

// MARK: - Picker Delegate
extension ImagePicker: UIImagePickerControllerDelegate {
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        pickerController(picker)
    }

    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let image = info[.originalImage] as? UIImage {
            pickerController(picker, image: image)
        } else if let videoUrl = info[.mediaURL] as? URL {
            pickerController(picker, videoURL: videoUrl)
        } else {
            pickerController(picker)
        }
    }
}

// MARK: - Permission Delegate
extension ImagePicker: PermissionDelegate {
    public func didDenied() {
        print("did denied")
    }
    
    public func didAllow(permission: SPPermission) {
        guard let cameraType = cameraTypeForCheckPermission,
              let pickerType = pickerTypeForCheckPermission else { return }
        actionAfterPermission(pickerType: pickerType, cameraType: cameraType)
    }
}
