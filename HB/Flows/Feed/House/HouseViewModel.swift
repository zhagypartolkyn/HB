 
import Foundation
import SwiftUI
import FirebaseFirestore

class HouseViewModel: ObservableObject {
    
    // MARK: General
    @Published var isCity: Bool = true
    @Published var cityText = "Город"
    
    var placeId: String? = nil
    var limit: Int = 30
    
    var navigateSearch: ((_ placeId: String) -> Void)?
    var navigateProfile: ((_ uid: String) -> Void)?
    var navigateWish: ((_ wishVM: WishViewModel?, _ wishId: String?) -> Void)?
    var navigateReport: ((_ reportObject: ReportObject) -> Void)?
    var navigateComplete: ((_ wishVM: WishViewModel) -> Void)?
    var showMore: ((_ wishVM: WishViewModel) -> Void)?
    
    init(placeId: String? = nil) {
        self.placeId = placeId
    }
    
    func setPlaceId(_ placeId: String, title: String) {
        self.placeId = placeId
        self.cityText = title
        
        lastDocumentSnapshot = nil
        wishVMs = []
        isLoading = false
        canLoadMore = true

        fetchWishes()
    }
    
    // MARK: Wishes
    @Published var isRefreshing = false
    @Published var wishVMs: [WishViewModel] = [WishViewModel(value: wishExample), WishViewModel(value: wishExample)]
    @Published var isNoWishes = false
    
    private var isLoading = false
    private var canLoadMore = true
    private var lastDocumentSnapshot: DocumentSnapshot?
    
    func resetFetchWish() {
        lastDocumentSnapshot = nil
        wishVMs = []
        isLoading = false
        canLoadMore = true
    }
    
    func fetchWishes() {
        guard let placeId = placeId else { return }
        
        if !isLoading, canLoadMore {
            isLoading = true
            
            let query = Queries.Wish.city(placeId: placeId, lastDocumentSnapshot: lastDocumentSnapshot)
            
            DB.fetchViewModels(model: Wish.self, viewModel: WishViewModel.self, query: query, limit: limit) { (result) in
                switch result {
                case .success((let wishVMs, let lastDocumentSnapshot, let canLoadMore)):
                    self.lastDocumentSnapshot = lastDocumentSnapshot
                    self.canLoadMore = canLoadMore
                    self.wishVMs += wishVMs
                case .failure(_):
                    self.canLoadMore = false
                }
                
                self.isNoWishes = self.wishVMs.isEmpty
                self.isLoading = false
            }
        }
    }
    
}
