 

import Foundation
import Firebase
import FirebaseFirestore

class PeopleViewModel {
    
    // MARK: - Binding
    var navigateProfile: ((_ uid: String) -> Void)?
    var navigateSearch: (() -> Void)?
    
    
    let numberOfRows = 3
    var currentMiddle = 1
    var models = [UserViewModel]()
    var lastDocumentSnapshot: DocumentSnapshot?
    var performingRequest = false
    var batchSize: Int
    var lastPage = false
    var reloadDataCallback: (() -> Void)?
    var refreshCallback: (() -> Void)?
    var placeId: String
    var refreshed: Bool = false
    var hideSkeleton: (() -> Void)!
    
    init(placeId: String) {
        self.placeId = placeId
        self.batchSize = 18
    }
    
    func getUsers() {
        if !performingRequest {
            performingRequest = true
            if self.refreshed {
                self.lastDocumentSnapshot = nil
                self.lastPage = false
            }
            
            
            let query = Queries.User.placeId(placeId: placeId, lastDocumentSnapshot: lastDocumentSnapshot, limit: batchSize)
            DB.fetchViewModels(model: User.self, viewModel: UserViewModel.self, query: query) { [self] (result) in
                switch result {
                case .success((let models, let snapshot, _)):
                    print("DEBUG: User count \(models.count)")
                    self.models += models
                    if self.refreshed {
                        self.models = models
                    }
                    self.currentMiddle = 1
                    self.lastDocumentSnapshot = snapshot
                    if models.count < self.batchSize {
                        self.lastPage = true
                    }
                    self.refreshCallback?()
                    self.reloadDataCallback?()
                    self.hideSkeleton()
                    self.performingRequest = false
                    self.refreshed = false
                case .failure(let error):
                    refreshCallback?()
                    debugPrint(error)
                }
            }
            
        } else {
            refreshCallback?()
        }
    }
    
    func nextMiddle() {
        currentMiddle+=3
    }
    
}
