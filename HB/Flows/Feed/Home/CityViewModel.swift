 
import FirebaseFirestore
import MapKit

class CityViewModel {
    
    // MARK: - Binding
    var navigateProfile: ((_ uid: String) -> Void)?
    var navigateWish: ((_ wishVM: WishViewModel?, _ wishId: String?) -> Void)?
    var navigateReport: ((_ reportObject: ReportObject) -> Void)?
    var navigateComplete: ((_ wishVM: WishViewModel) -> Void)?
    
    var showSkeleton: (() -> Void)?
    var hideSkeleton: (() -> Void)?
    var reloadWithData: ((_ wishVM: [WishViewModel]) -> Void)?
    var showHUD: ((_ type: AlertType, _ text: String) -> Void)?
    
    // MARK: - Variables
    var placeId: String? = nil
    var limit: Int = 10
    var isLoading = false
    var canLoadMore = true
    var lastDocumentSnapshot: DocumentSnapshot?
    var wishVMs: [WishViewModel] = []
    
    init(placeId: String? = nil) {
        self.placeId = placeId
    }
    
    // MARK: - List Wish
    func resetFetchWish() {
        lastDocumentSnapshot = nil
        wishVMs = []
        isLoading = false
        canLoadMore = true
    }
    
    func showWishes() {
        self.reloadWithData?(self.wishVMs)
    }
    
    func fetchWishes() {
        guard let placeId = placeId else { return }
        
        if !isLoading, canLoadMore {
            isLoading = true
            
            if wishVMs.isEmpty {
                showSkeleton?()
            }
            
            let query = Queries.Wish.city(placeId: placeId, lastDocumentSnapshot: lastDocumentSnapshot)
            
            DB.fetchViewModels(model: Wish.self, viewModel: WishViewModel.self, query: query, limit: limit) { (result) in
                
                switch result {
                case .success((let wishVMs, let lastDocumentSnapshot, let canLoadMore)):
                    self.wishVMs += wishVMs
                    self.lastDocumentSnapshot = lastDocumentSnapshot
                    self.canLoadMore = canLoadMore
                    self.reloadWithData?(self.wishVMs)
                    self.hideSkeleton?()
                case .failure(_):
                    if self.wishVMs.isEmpty {
                        self.reloadWithData?([])
                    }
                    self.canLoadMore = false
                    self.hideSkeleton?()
                }
                
                self.isLoading = false
            }
        }
    }
}
