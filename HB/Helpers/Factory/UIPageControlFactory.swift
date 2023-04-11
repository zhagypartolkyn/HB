 
import UIKit

final class UIPageControlFactory {
    private let pageControl: UIPageControl
    
    // MARK: - Inits
    init() {
        pageControl = UIPageControl()
        pageControl.isUserInteractionEnabled = false
        pageControl.currentPageIndicatorTintColor = UIColor.appColor(.primary)
        pageControl.pageIndicatorTintColor = UIColor.appColor(.textSecondary)
    }

    // MARK: - Public methods
    func current(page: Int) -> Self {
        pageControl.currentPage = page
        return self
    }
    
    func numberOf(pages: Int) -> Self {
        pageControl.numberOfPages = pages
        return self
    }
    
    func build() -> UIPageControl {
        return pageControl
    }
    
}
