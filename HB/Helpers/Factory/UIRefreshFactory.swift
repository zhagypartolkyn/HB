 

import UIKit
import SnapKit

final class UIRefreshFactory {
    
    private let refresh: UIRefreshControl

    init() {
        refresh = UIRefreshControl()
    }

    // MARK: - Public methods
    func addTarget(_ selector: Selector) -> Self {
        refresh.addTarget(self, action: selector, for: .valueChanged)
        return self
    }

    func build() -> UIRefreshControl {
        return refresh
    }
    
}

