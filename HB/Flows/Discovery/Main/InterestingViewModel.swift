
import Foundation

class InterestingViewModel {
    // MARK: - Binding
    var navigateHistory: ((_ historyVMs: [HistoryViewModel], _ currentIndexPath: IndexPath) -> Void)?
    var navigateProfile: ((_ uid: String) -> Void)?
    var navigatePeople: ((_ placeId: String) -> Void)?
    var navigateCity: ((_ placeId: String) -> Void)?
}
