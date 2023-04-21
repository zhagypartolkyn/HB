 
import UIKit
import SwiftUI

enum AssetsColor: String {
    case active
    case dangerous
    case secondary
    case primary
    case textBorder
    case textTeritary
    case textPlaceholder
    case textSecondary
    case textPrimary
    case backgroundSecondary
    case background 
}

extension UIColor {
    static func appColor(_ name: AssetsColor) -> UIColor {
         return UIColor(named: name.rawValue)!
    }
}
