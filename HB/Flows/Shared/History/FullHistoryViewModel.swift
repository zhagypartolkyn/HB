 

import FirebaseFirestore

class FullHistoryViewModel: ObservableObject {
    
    // MARK: - Binding
    var navigateProfile: ((_ uid: String) -> Void)?
    var navigateWish: ((_ wishVM: WishViewModel?, _ wishId: String?) -> Void)?
    var navigateReport: ((_ reportObject: ReportObject) -> Void)?
    var navigateHistory: ((_ currentIndexPath: IndexPath) -> Void)?
    var navigateBack: (() -> Void)?
    
    // MARK: - Variables
    @Published var historyVMs: [HistoryViewModel] = []
    @Published var isRefreshing = false
    @Published var isNoHistories = false
    var lastDocumentSnapshot: DocumentSnapshot?
    var isLoading: Bool = false
    var canLoadMore: Bool = true
    var reloadDataFullHistory: (() -> Void)?
    var reloadDataParent: (() -> Void)?
    var hasHistories: Bool = false
    
    var query: Query?
    private let limit = 30
    
    // MARK: - LifeCycle
    init(query: Query? = nil) {
        self.query = query
    }
    
    func resetAndFetch() {
        lastDocumentSnapshot = nil
        historyVMs = []
        isLoading = false
        canLoadMore = true
        
        fetchHistories()
    }
    
    func fetchHistories() {
        guard var query = query else { return }
        
        if let lastDocumentSnapshot = lastDocumentSnapshot {
            query = query.start(afterDocument: lastDocumentSnapshot)
        }
        
        if !isLoading && canLoadMore {
            isLoading = true
            
            DB.fetchViewModels(model: History.self, viewModel: HistoryViewModel.self, query: query, limit: limit) { (result) in
                switch result {
                case .success((let historyVMs, let lastDocumentSnapshot, let canLoadMore)):
                    self.historyVMs.append(contentsOf: historyVMs)
                    self.lastDocumentSnapshot = lastDocumentSnapshot
                    self.canLoadMore = canLoadMore
                case .failure(_):
                    self.canLoadMore = false
                }
                self.isNoHistories = self.historyVMs.isEmpty
                self.hasHistories = !self.historyVMs.isEmpty
                self.reloadDataFullHistory?()
                self.reloadDataParent?()
                self.isLoading = false
            }
        }
    }
    
    func deleteHistory(id: String, wishId: String, completion: @escaping(Result<Bool, Error>) -> Void) {
        let batchService = BatchService()
        
        batchService.performBatchOperation(operation: { (batch, commit) in
            let updateData: [String: Any] = [Ref.History.status.delete: true, Ref.History.date.delete: Timestamp(date: Date())]
            batch.updateData(updateData, forDocument: Ref.Fire.history(id: id))
            batch.updateData([Ref.Wish.history: FieldValue.increment(Int64(-1))], forDocument: Ref.Fire.wish(id: wishId))
            commit()
        }, completionHandler: {
            completion(.success(true))
        })
    }
    
}
