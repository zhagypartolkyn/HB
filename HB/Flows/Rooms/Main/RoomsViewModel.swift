 

import Foundation
import Firebase
import FirebaseFirestore

class RoomsViewModel {
    
    // MARK: - Binding
    var navigateMessage: ((_ roomId: String) -> Void)!
    
    // MARK: - Variables
    var isLoading = false
    var canLoadMore = true
    
    var batchSize: Int = 15
    var increasingConstant: Int = 15
    
    var roomVMs: [RoomViewModel] = []
    var wishVM: WishViewModel?
    var currentListener: ListenerRegistration?
    
    var reloadWithData: ((_ roomVMs: [RoomViewModel]) -> Void)?
    var showPlaceholderView: ((Bool) -> Void)?
    
    // MARK: - LifeCycle
    init(wishVM: WishViewModel?) {
        self.wishVM = wishVM
    }
    
    // MARK: - Methods
    func loadMore() {
        if !isLoading, canLoadMore {
            roomVMs = []
            if let listener = currentListener {
                listener.remove()
            }
            loadRooms()
        }
    }
    
    func loadRooms() {
        if !isLoading {
            isLoading = true
            
            let query = Queries.Room.myRooms(wishId: wishVM?.id)
            DB.listenViewModels(model: Room.self, viewModel: RoomViewModel.self, query: query, limit: batchSize) { [self] (result) in
                switch result {
                case .success((let viewModels, _, let canLoadMore)):
                    // Less than requested  - it's last page
                    self.canLoadMore = canLoadMore
                    if canLoadMore {
                        batchSize += increasingConstant
                    }
                    
                    roomVMs = viewModels
                    reloadWithData?(viewModels)
                    showPlaceholderView?(false)
                case .failure(_):
                    canLoadMore = false
                    showPlaceholderView?(true)
                }
                isLoading = false
            } captureListener: { [self] (listener) in
                currentListener = listener
            }
        }
    }
    
    func deleteSingleWishRoom(roomVM: RoomViewModel ,completion: @escaping(Result<Bool, Error>)-> Void) {
        
        let batch = Ref.Fire.root.batch()
        
        batch.deleteDocument(Ref.Fire.room(id: roomVM.id))
        batch.deleteDocument(Ref.Fire.notify(id: roomVM.id))
        
        if (roomVM.participants.count < 2) {
            batch.commit() { error in
                if let error = error {
                    completion(.failure(error))
                }
            }
        } else {
            let query = Ref.Fire.requests
                .whereField("wish.id", isEqualTo: roomVM.wishId)
                .whereField("author.uid", isEqualTo: roomVM.partnerUid)
            DB.fetchModels(model: Request.self, query: query, completion: { (result) in
                switch result {
                case .success((let requests, _, _)):
                    if let request = requests.first {
                        batch.updateData(["status.accept" : false, "status.decline": true], forDocument: Ref.Fire.request(id: request.id))
                        batch.updateData(["participants" : FieldValue.arrayRemove([roomVM.partnerUid])], forDocument: Ref.Fire.wish(id: roomVM.wishId))
                        batch.commit() { error in
                            if let error = error {
                                completion(.failure(error))
                            }
                        }
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            })
        }
        
    }
}
