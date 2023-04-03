 

import UIKit

class OnboardingViewModel {
    
    // MARK: - Binding
    var navigateSign: (() -> Void)?
    var scrollToItem: ((_ indexPath: IndexPath) -> Void)?
    var progressAnimation: ((_ from: CGFloat, _ next: CGFloat) -> Void)?
    
    // MARK: - Variables
    let pages = [
        Onboarding(image: Icons.Onboarding._1!,
                    title: LocalizedText.Onboarding.page1.title,
                    description: LocalizedText.Onboarding.page1.description),
        Onboarding(image: Icons.Onboarding._2!,
                    title: LocalizedText.Onboarding.page2.title,
                    description: LocalizedText.Onboarding.page2.description),
        Onboarding(image: Icons.Onboarding._3!,
                    title: LocalizedText.Onboarding.page3.title,
                    description: LocalizedText.Onboarding.page3.description)
    ]
    
    var currentIndex = 0
    
    private lazy var oneStep = 1.0 / CGFloat(pages.count)
    
    // MARK: - Public Function
    public func handleNext() {
        if currentIndex == pages.count - 1 {
            navigateSign?()
        } else {
            let nextItem: IndexPath = IndexPath(item: currentIndex + 1, section: 0)
            scrollToItem?(nextItem)
            changeIndex(currentIndex + 1)
        }
    }

    public func changeIndex(_ newIndex: Int) {
        let fromStep = CGFloat(currentIndex + 1) * oneStep
        let nextStep = CGFloat(newIndex + 1) * oneStep
        progressAnimation?(fromStep, nextStep)
        currentIndex = newIndex
    }
}
