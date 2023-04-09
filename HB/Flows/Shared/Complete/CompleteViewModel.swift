 

import Foundation
import FirebaseFirestore

class CompleteViewModel {
    
    //
    var navigateBack: (() -> Void)?
    
    var showHUD: ((_ type: AlertType, _ text: String) -> Void)?
    var reloadData: (() -> Void)?
    
    let wishVM: WishViewModel
    var wishParticipants = [UserViewModel]()
    
    var markedCells = [String?]()
    var createConnectsCompletion: (() -> Void)!
    
    init(wishVM: WishViewModel) {
        self.wishVM = wishVM
    }
    
    func createConnects() {
        let connects = markedCells.filter { $0 != nil }
        
        self.completeSingleWish(id: wishVM.id, with: connects) {
            self.showHUD?(.success, LocalizedText.wish.CONNECTS_CREATED)
            self.navigateBack?()
        }
    }
    
    private func completeSingleWish(id: String, with users: [String?], completionHandler: @escaping () -> Void) {
        let batchService = BatchService()
        
        DB.fetchViewModel(model: Wish.self, viewModel: WishViewModel.self, ref: Ref.Fire.wish(id: id)) { (result) in
            switch result {
            case .success(_):
                batchService.performBatchOperation { (batch, commit) in
                    
                    batch.updateData([Ref.Wish.status.complete: true,
                                      Ref.Wish.date.complete: Timestamp(date: Date()),
                                      Ref.Wish.date.update: Timestamp(date: Date())
                    ], forDocument: Ref.Fire.wish(id: id))
                    
                    for uid in users {
                        guard let uid = uid else { return }
                        
                        var userConnects = [[AnyHashable: Any]]()
                        userConnects.append([
                            Ref.Connect.uid: DB.Helper.uid,
                            Ref.Connect.visible: true,
                            Ref.Connect.wishId: id
                        ])
                        
                        var myConnects = [[AnyHashable: Any]]()
                        myConnects.append([
                            Ref.Connect.uid: uid,
                            Ref.Connect.visible: true,
                            Ref.Connect.wishId: id
                        ])
                        
                        batch.updateData([Ref.Connect.connects : FieldValue.arrayUnion(userConnects)], forDocument: Ref.Fire.connect(uid: uid))
                        batch.updateData([Ref.User.counters.connects : FieldValue.increment(Int64(1))], forDocument: Ref.Fire.user(uid: uid))
                        
                        batch.updateData([Ref.Connect.connects : FieldValue.arrayUnion(myConnects)], forDocument: Ref.Fire.connect(uid: DB.Helper.uid))
                        batch.updateData([Ref.User.counters.connects : FieldValue.increment(Int64(1))], forDocument: Ref.Fire.user(uid: DB.Helper.uid))
                    }
                    
                    commit()
                } completionHandler: {
                    completionHandler()
                }
                
            case .failure(let error):
                debugPrint(error)
            }
        }
        
    }
    
    func loadParticipants() {
        for uid in wishVM.participants {
            
            DB.fetchViewModel(model: User.self, viewModel: UserViewModel.self, ref: Ref.Fire.user(uid: uid)) { (result) in
                switch result {
                case .success(let userVM):
                    self.wishParticipants.append(userVM)
                    if self.wishParticipants.count == self.wishVM.participants.count {
                        self.markedCells = Array(repeating: nil, count: self.wishParticipants.count)
                        self.reloadData!()
                    }
                case .failure(let error):
                    debugPrint(error)
                }
            }
        }
    }
}
