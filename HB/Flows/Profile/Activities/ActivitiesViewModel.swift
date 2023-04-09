 
import Foundation
import FirebaseFirestore

class ActivitiesViewModel: ObservableObject {
    
    // MARK: - Binding
    var navigateProfile: ((_ uid: String) -> Void)?
    var navigateRequests: ((_ wishId: String) -> Void)?
    
    // MARK: - Variables
    private var limit: Int = 30
    private var lastDocumentSnapshot: DocumentSnapshot?
    var isHide: Bool = false
    
    private var canLoadMore = true
    private var isLoading = false
    
    @Published var activityVMs: [ActivityViewModel] = []
    
    // MARK: - Public Methods
    func fetchNotifications() {
        if activityVMs.isEmpty {
            // Show skeleton
        }
        if !isLoading && canLoadMore {
            isLoading = true
            
            let query = Queries.Notification.fetch(lastDocumentSnapshot: lastDocumentSnapshot)
            
            DB.fetchViewModels(model: Activity.self, viewModel: ActivityViewModel.self, query: query, limit: limit) { (result) in
                switch result {
                case .success((let activityVMs, let lastDocumentSnapshot, let canLoadMore)):
                    self.lastDocumentSnapshot = lastDocumentSnapshot
                    self.canLoadMore = canLoadMore
                    self.activityVMs.append(contentsOf: activityVMs)
                    self.readNotifications(activityVMs)
                case .failure(_):
                    if self.activityVMs.isEmpty {
                        // self.showError?()
                    }
                    self.canLoadMore = false
                }
                self.isLoading = false
            }
            self.isHide = activityVMs.isEmpty
        } else {
            // self.endRefreshing?()
        }
    }
    
    // MARK: - Helpers
    private func readNotifications(_ viewModels: [ActivityViewModel]) {
        for viewModel in viewModels {
            if !viewModel.isRead {
                DB.update(data: ["status.read" : true], ref: Ref.Fire.notification(id: viewModel.id)) { (_) in }
            }
        }
    }
    
}
