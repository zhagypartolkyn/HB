 

import UIKit
import SVProgressHUD
import CryptoKit
import AVFoundation

// MARK: - CALayer Shows
extension CALayer {
    func applyCardShadow() {
        let color: UIColor = UIColor.appColor(.primary)
        let alpha: Float = 0.1
        let x: CGFloat = 0
        let y: CGFloat = 10
        let blur: CGFloat = 20
        let spread: CGFloat = 0
        CALayer.applyCustomShadow(layer: self, color: color, alpha: alpha, x: x, y: y, blur: blur, spread: spread)
    }
    
    func applyNavigationBarShadow() {
        let color: UIColor = UIColor.appColor(.primary)
        let alpha: Float = 0.05
        let x: CGFloat = 0
        let y: CGFloat = 10
        let blur: CGFloat = 20
        let spread: CGFloat = 0
        CALayer.applyCustomShadow(layer: self, color: color, alpha: alpha, x: x, y: y, blur: blur, spread: spread)
    }
    
    func applyTabBarShadow() {
        let color: UIColor = UIColor.appColor(.primary)
        let alpha: Float = 0.05
        let x: CGFloat = 0
        let y: CGFloat = -10
        let blur: CGFloat = 20
        let spread: CGFloat = 0
        CALayer.applyCustomShadow(layer: self, color: color, alpha: alpha, x: x, y: y, blur: blur, spread: spread)
    }
    
    static func applyCustomShadow(layer: CALayer, color: UIColor, alpha: Float, x: CGFloat, y: CGFloat, blur: CGFloat, spread: CGFloat) {
        layer.masksToBounds = false
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = alpha
        layer.shadowOffset = CGSize(width: x, height: y)
        layer.shadowRadius = blur / 2.0
        if spread == 0 {
            layer.shadowPath = nil
        } else {
            let dx = -spread
            let rect = layer.bounds.insetBy(dx: dx, dy: dx)
            layer.shadowPath = UIBezierPath(rect: rect).cgPath
        }
    }
}

// MARK: - UIToolbar
extension UIToolbar {
    func ToolbarPiker(mySelect : Selector) -> UIToolbar {
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor.appColor(.textPrimary)
        toolBar.sizeToFit()

        let doneButton = UIBarButtonItem(title: LocalizedText.General.done, style: UIBarButtonItem.Style.plain, target: self, action: mySelect)
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)

        toolBar.setItems([ spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true

        return toolBar
    }
}

// MARK: - URL
extension URL {
    func queryParams() -> [String:String] {
        let queryItems = URLComponents(url: self, resolvingAgainstBaseURL: false)?.queryItems
        let queryTuples: [(String, String)] = queryItems?.compactMap {
            guard let value = $0.value else { return nil }
            return ($0.name, value)
        } ?? []
        return Dictionary(uniqueKeysWithValues: queryTuples)
    }
}

// MARK: - UITextField
extension UITextField {
    func setInputViewDatePicker(target: Any, selector: Selector) {
        // Create a UIDatePicker object and assign to inputView
        let screenWidth = UIScreen.main.bounds.width
        let datePicker = UIDatePicker(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 216))//1
        datePicker.datePickerMode = .date //2
        self.inputView = datePicker //3
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        }
        // Create a toolbar and assign it to inputAccessoryView
        let toolBar = UIToolbar(frame: CGRect(x: 0.0, y: 0.0, width: screenWidth, height: 44.0)) //4
        let flexible = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil) //5
        let cancel = UIBarButtonItem(title: "Cancel", style: .plain, target: nil, action: #selector(tapCancel)) // 6
        let barButton = UIBarButtonItem(title: "Done", style: .plain, target: target, action: selector) //7
        toolBar.setItems([cancel, flexible, barButton], animated: false) //8
        self.inputAccessoryView = toolBar //9
    }
    
    @objc func tapCancel() {
        self.resignFirstResponder()
    }
}

// MARK: - String
extension String {
    // Hash uid's for chat roomf
    var hashString: Int {
        let unicodeScalars = self.unicodeScalars.map { $0.value }
        return unicodeScalars.reduce(5381) {
            ($0 << 5) &+ $0 &+ Int($1)
        }
    }
    // Check is valid username
    var isValidUsername: Bool {
        if self.count < 3 {
            return false
        }
        return NSPredicate(format: "SELF MATCHES %@", "^(?!.*\\.\\.)(?!.*\\.$)[^\\W][a-z0-9_.]{0,29}$").evaluate(with: self)
    }
    // Check is valid password
    var isValidPassword: Bool {
        if self.count < 6 {
            return false
        }
        return NSPredicate(format: "SELF MATCHES %@", "^[a-zA-Z0-9!#$().,-@_;:]{6,}$").evaluate(with: self)
    }
    // Check is valid email
    var isValidEmail: Bool {
        if self.count < 2 {
            return false
        }
        return NSPredicate(format: "SELF MATCHES %@", "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}").evaluate(with: self)
    }
    
    func containsOnlyWhiteSpaces() -> Bool {
        for letter in self {
            if letter != " " {
                return false
            }
        }
        return true
    }
}

// MARK: - UIViewController
enum AlertType {
    case loading
    case dismiss
    case success
    case error
    case info
}

extension UIViewController {
    
    func showHUD(type: AlertType = .loading, text: String = "") {
        switch type {
        case .loading:
            view.endEditing(true)
            SVProgressHUD.show()
            view.isUserInteractionEnabled = false
            navigationItem.leftBarButtonItem?.isEnabled = false
            navigationItem.rightBarButtonItem?.isEnabled = false
        case .dismiss:
            view.endEditing(true)
            SVProgressHUD.dismiss()
            view.isUserInteractionEnabled = true
            navigationItem.leftBarButtonItem?.isEnabled = true
            navigationItem.rightBarButtonItem?.isEnabled = true
        case  .success:
            view.endEditing(true)
            SVProgressHUD.showSuccess(withStatus: text)
            SVProgressHUD.setMinimumDismissTimeInterval(1.0)
            view.isUserInteractionEnabled = true
            navigationItem.leftBarButtonItem?.isEnabled = true
            navigationItem.rightBarButtonItem?.isEnabled = true
        case .error:
            view.endEditing(true)
            SVProgressHUD.showError(withStatus: text)
            view.isUserInteractionEnabled = true
            navigationItem.leftBarButtonItem?.isEnabled = true
            navigationItem.rightBarButtonItem?.isEnabled = true
        case .info:
            view.endEditing(true)
            SVProgressHUD.showInfo(withStatus: text)
            view.isUserInteractionEnabled = true
            navigationItem.leftBarButtonItem?.isEnabled = true
            navigationItem.rightBarButtonItem?.isEnabled = true
        }
    }
    
}

extension UIImageView {
    func adjustImageWidthAndHeightProportionallyToMainScreen(percent: CGFloat, cornerRadiusAfterAdjusting: CGFloat) {
        self.translatesAutoresizingMaskIntoConstraints = false
        let adjustmentPercentage = UIScreen.main.bounds.width * percent
        let width = self.widthAnchor.constraint(equalToConstant: adjustmentPercentage)
        width.priority = .init(rawValue: 999)
        let height = self.heightAnchor.constraint(equalToConstant: adjustmentPercentage)
        height.priority = .init(999)
        NSLayoutConstraint.activate([
            width,
            height
        ])
        self.layer.cornerRadius = adjustmentPercentage * cornerRadiusAfterAdjusting
        self.clipsToBounds = true
    }
}

extension UIImage {
    var isPortrait:  Bool    { size.height > size.width }
    var isLandscape: Bool    { size.width > size.height }
    var breadth:     CGFloat { min(size.width, size.height) }
    var breadthSize: CGSize  { .init(width: breadth, height: breadth) }
    var breadthRect: CGRect  { .init(origin: .zero, size: breadthSize) }
    func rounded(with color: UIColor, width: CGFloat) -> UIImage? {
        
        guard let cgImage = cgImage?.cropping(to: .init(origin: .init(x: isLandscape ? ((size.width-size.height)/2).rounded(.down) : .zero, y: isPortrait ? ((size.height-size.width)/2).rounded(.down) : .zero), size: breadthSize)) else { return nil }
        
        let bleed = breadthRect.insetBy(dx: -width, dy: -width)
        let format = imageRendererFormat
        format.opaque = false
        
        return UIGraphicsImageRenderer(size: bleed.size, format: format).image { context in
            UIBezierPath(ovalIn: .init(origin: .zero, size: bleed.size)).addClip()
            var strokeRect =  breadthRect.insetBy(dx: -width/2, dy: -width/2)
            strokeRect.origin = .init(x: width/2, y: width/2)
            UIImage(cgImage: cgImage, scale: 1, orientation: imageOrientation)
            .draw(in: strokeRect.insetBy(dx: width/2, dy: width/2))
            context.cgContext.setStrokeColor(color.cgColor)
            let line: UIBezierPath = .init(ovalIn: strokeRect)
            line.lineWidth = width
            line.stroke()
        }
    }
}

// MARK: - Constraints
extension UICollectionViewCell {
    static func cellIdentifier() -> String {
        return String(describing: self)
    }
}


extension UITableViewCell {
    static func cellIdentifier() -> String {
        return String(describing: self)
    }
}

// MARK: - Resize Image
func resizeImage(image: UIImage, maxSize: CGFloat = 1240) -> UIImage {
    // If image is bigger than maxSize
    if image.size.width > maxSize || image.size.height > maxSize {
        // If width is biggest, change it to maxSize. And create newHeight by aspect ratio.
        if image.size.width > image.size.height {
            let scale = maxSize / image.size.width
            let newHeight = image.size.height * scale
            UIGraphicsBeginImageContext(CGSize(width: maxSize, height: newHeight))
            image.draw(in: CGRect(x: 0, y: 0, width: maxSize, height: newHeight))
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return newImage!
        } else {
            let scale = maxSize / image.size.height
            let newWidth = image.size.width * scale
            UIGraphicsBeginImageContext(CGSize(width: newWidth, height: maxSize))
            image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: maxSize))
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return newImage!
        }
    } else {
        return image
    }
}

extension UIColor {
    func as1ptImage() -> UIImage {
        UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
        setFill()
        UIGraphicsGetCurrentContext()?.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
        let image = UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
        UIGraphicsEndImageContext()
        return image
    }
}

// MARK: - Apple Sign In Crypto
@available(iOS 13, *)
func sha256(_ input: String) -> String {
    let inputData = Data(input.utf8)
    let hashedData = SHA256.hash(data: inputData)
    let hashString = hashedData.compactMap {
        return String(format: "%02x", $0)
    }.joined()
    
    return hashString
}

func randomNonceString(length: Int = 32) -> String {
    precondition(length > 0)
    let charset: Array<Character> =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
    var result = ""
    var remainingLength = length
    
    while remainingLength > 0 {
        let randoms: [UInt8] = (0 ..< 16).map { _ in
            var random: UInt8 = 0
            let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
            if errorCode != errSecSuccess {
                fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
            }
            return random
        }
        randoms.forEach { random in
            if length == 0 {
                return
            }
            
            if random < charset.count {
                result.append(charset[Int(random)])
                remainingLength -= 1
            }
        }
    }
    return result
}

extension UIFont {
    func with(weight: UIFont.Weight) -> UIFont {
        return UIFont.systemFont(ofSize: pointSize, weight: weight)
    }
}







protocol Bluring {
    func addBlur(_ alpha: CGFloat)
}

extension Bluring where Self: UIView {
    func addBlur(_ alpha: CGFloat = 0.5) {
        // create effect
        let effect = UIBlurEffect(style: .dark)
        let effectView = UIVisualEffectView(effect: effect)

        // set boundry and alpha
        effectView.frame = self.bounds
        effectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        effectView.alpha = alpha

        self.addSubview(effectView)
    }
}

// Conformance
extension UIView: Bluring {}


func compressVideo(withUrl outputFileURL: URL, completion: @escaping(URL) -> Void) {
    guard let data = try? Data(contentsOf: outputFileURL) else {
        return
    }

    let compressedURL = NSURL.fileURL(withPath: NSTemporaryDirectory() + UUID().uuidString + ".mp4")
    compressVideo(inputURL: outputFileURL, outputURL: compressedURL) { exportSession in
        guard let session = exportSession else { return }

        switch session.status {
        case .unknown:
            break
        case .waiting:
            break
        case .exporting:
            break
        case .completed:
            guard let compressedData = try? Data(contentsOf: compressedURL) else {
                return
            }
            
            DispatchQueue.main.async {
                completion(compressedURL)
            }
        case .failed:
            break
        case .cancelled:
            break
        @unknown default:
            fatalError()
        }
    }
}

func compressVideo(inputURL: URL, outputURL: URL, handler:@escaping (_ exportSession: AVAssetExportSession?) -> Void) {
    let urlAsset = AVURLAsset(url: inputURL, options: nil)
    guard let exportSession = AVAssetExportSession(asset: urlAsset, presetName: AVAssetExportPresetPassthrough) else {
        handler(nil)
        return
    }

    exportSession.outputURL = outputURL
    exportSession.outputFileType = .mp4
    exportSession.exportAsynchronously {
        handler(exportSession)
    }
}
