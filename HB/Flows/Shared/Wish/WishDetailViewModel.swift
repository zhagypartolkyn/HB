 

import Foundation
import UIKit
import FirebaseFirestore

class WishDetailViewModel: ObservableObject {

    func completeGroupWish(id: String, generalCompletion: @escaping (_ completionText: String) -> Void) {
        let batchService = BatchService()

        DB.fetchViewModel(model: Wish.self, viewModel: WishViewModel.self, ref: Ref.Fire.wish(id: id)) { (result) in
            switch result {
            case .success(let wishVM):
                
                DB.fetchViewModels(model: Room.self, viewModel: RoomViewModel.self, query: Queries.Room.wish(id: id), completion: { (result) in
                    switch result {
                    case .success((let roomVMs, _, _)):
                        let roomVM = roomVMs[0]
                        
                        DB.Helper.createMessage(roomId: roomVM.id, value: [
                            Ref.Message.text: LocalizedText.wish.WISH_COMPLETED,
                            Ref.Message.type: "info",
                            Ref.Message.date: Date().timeIntervalSince1970 * 1000
                        ])
                        
                        batchService.performBatchOperation { (batch, commit) in
                            
                            batch.updateData([Ref.Wish.status.complete: true,
                                              Ref.Wish.date.complete: Timestamp(date: Date()),
                                              Ref.Wish.date.update: Timestamp(date: Date())
                            ], forDocument: Ref.Fire.wish(id: id))
                            
                            batch.updateData([Ref.Room.status.complete: true],forDocument: Ref.Fire.room(id: roomVM.id))
                            
                            var participants = wishVM.participants
                            participants.append(DB.Helper.uid)
                            for uid in participants {
                                var userConnects = [[AnyHashable: Any]]()
                                for otherUid in participants where otherUid != uid {
                                    userConnects.append([
                                            Ref.Connect.uid: otherUid,
                                            Ref.Connect.visible: true,
                                            Ref.Connect.wishId: id
                                    ])
                                }
                                batch.updateData([Ref.Connect.connects : FieldValue.arrayUnion(userConnects)], forDocument: Ref.Fire.connect(uid: uid))
                                batch.updateData([Ref.User.counters.connects : FieldValue.increment(Int64(userConnects.count))], forDocument: Ref.Fire.user(uid: uid))
                            }
                            
                            commit()
                        } completionHandler: {
                            generalCompletion(LocalizedText.wish.CONNECTS_CREATED)
                        } onError: { (error) in
                            debugPrint(error)
                        }
                    case .failure(let error):
                        debugPrint(error)
                    }
                })
                
            case .failure(let error):
                debugPrint(error)
            }
        }
        
    }
    
    func exitWish(id: String, completion: @escaping(Result<Bool, Error>) -> Void) {
        let batchService = BatchService()
        batchService.performBatchOperation(operation: { (batch, commit) in
            
            let myGroup = DispatchGroup()
        
            batch.updateData([Ref.Wish.participants: FieldValue.arrayRemove([DB.Helper.uid])], forDocument: Ref.Fire.wish(id: id))
            
            myGroup.enter()
            DB.fetchModels(model: Room.self, query: Queries.onDelete.rooms(wishId: id, uid: DB.Helper.uid)) { (result) in
                switch result {
                case .success((let rooms, _, _)):
                    for room in rooms {
                        batch.updateData([Ref.Room.participants: FieldValue.arrayRemove([DB.Helper.uid])], forDocument: Ref.Fire.room(id: room.id))
                        batch.updateData(["\(Ref.Room.users).\(DB.Helper.uid).isDeleted": true], forDocument: Ref.Fire.room(id: room.id))
                        
                        let text = "\(DB.Helper.username) \(LocalizedText.messages.leftChat)"
                        DB.Helper.createMessage(roomId: room.id, value: [
                            Ref.Message.text: text,
                            Ref.Message.type: "text",
                            Ref.Message.uid: DB.Helper.uid,
                            Ref.Message.date: Date().timeIntervalSince1970 * 1000
                        ])
                    }
                    myGroup.leave()
                case .failure(let error):
                    debugPrint(error)
                    myGroup.leave()
                }
            }
            
            myGroup.enter()
            DB.fetchModels(model: Request.self, query: Queries.onDelete.myRequestsBy(wishId: id)) { (result) in
                switch result {
                case .success((let requests, _, _)):
                    for request in requests {
                        batch.deleteDocument(Ref.Fire.request(id: request.id))
                    }
                    myGroup.leave()
                case .failure(let error):
                    debugPrint(error)
                    myGroup.leave()
                }
            }
            
            myGroup.notify(queue: .main) {
                commit()
            }
    
        }, completionHandler: {
            completion(.success(true))
        })
    }
    
    func deleteWish(id: String, completion: @escaping(Result<Bool, Error>) -> Void) {
        let batchService = BatchService()
        
        batchService.performBatchOperation(operation: { (batch, commit) in
            let updateData: [String: Any] = ["status.delete": true, "date.delete": Timestamp(date: Date())]
            
            let myGroup = DispatchGroup()
            
            batch.updateData(updateData, forDocument: Ref.Fire.wish(id: id))
            
            batch.updateData([Ref.User.counters.wishes : FieldValue.increment(Int64(-1))], forDocument: Ref.Fire.user(uid: DB.Helper.uid))
            
            myGroup.enter()
            DB.fetchModels(model: History.self, query: Queries.onDelete.histories(wishId: id)) { (result) in
                switch result {
                case .success((let histories, _, _)):
                    histories.forEach {
                        guard let historyId = $0.id else { return }
                        batch.updateData(updateData, forDocument: Ref.Fire.history(id: historyId))
                    }
                    myGroup.leave()
                case .failure(let error):
                    // completion(.failure(error))
                    myGroup.leave()
                    debugPrint(error)
                }
            }
            
            myGroup.enter()
            DB.fetchModels(model: Room.self, query: Queries.onDelete.rooms(wishId: id)) { (result) in
                switch result {
                case .success((let rooms, _, _)):
                    rooms.forEach{
                        batch.updateData(updateData, forDocument: Ref.Fire.room(id: $0.id))
                    }
                    myGroup.leave()
                case .failure(let error):
                    // completion(.failure(error))
                    myGroup.leave()
                    debugPrint(error)
                }
            }
            
            myGroup.enter()
            DB.fetchModels(model: Request.self, query: Queries.onDelete.requests(wishId: id)) { (result) in
                switch result {
                case .success((let requests, _, _)):
                    requests.forEach{
                        batch.updateData(updateData, forDocument: Ref.Fire.request(id: $0.id))
                    }
                    myGroup.leave()
                case .failure(let error):
                    // completion(.failure(error))
                    myGroup.leave()
                    debugPrint(error)
                }
            }
            
            myGroup.notify(queue: .main) {
                commit()
            }
            
        }, completionHandler: {
            completion(.success(true))
        })
        
    }
    
    
    func upVote(viewModel: WishViewModel, userUid: String, completion: @escaping(Result<Bool, Error>) -> Void) {
        
        let batchService = BatchService()
        
        let updateDataForStatus: [String: Any] = ["upVote": true]
        let updateDataForVotes: [String: Any] = ["top.votes" : FieldValue.increment(Int64(1))]
        
        self.checkForSevenDays(viewModel: viewModel)
        
        let refForVotes = Ref.Fire.votes(id: viewModel.id).document(userUid)
        
        refForVotes.getDocument { (document, error) in
            if let document = document, document.exists {
                guard let upVote = document.get("upVote") as? Bool else { return }
                if upVote == true {
                    completion(.success(false))
                } else {
                    batchService.performBatchOperation { (batch, commit) in
                        batch.updateData(updateDataForStatus, forDocument: refForVotes)
                        batch.updateData(updateDataForVotes, forDocument: Ref.Fire.wish(id: viewModel.id))
                        completion(.success(true))
                        batch.commit()
                    } completionHandler: {
                        completion(.success(true))
                    }
                }
            } else {
                batchService.performBatchOperation { (batch, commit) in
                    batch.updateData(updateDataForVotes, forDocument: Ref.Fire.wish(id: viewModel.id))
                    
                    let vote = Vote(wishId: viewModel.id, uid: userUid, upVote: true)
                    
                    DB.create(model: vote, ref: refForVotes) { (result) in
                        switch result {
                        case .success(_): print("Successfully created model")
                        case .failure(let error ): print("DEBUG: Error is \(error.localizedDescription)")
                        }
                    }
                    completion(.success(true))
                    batch.commit()
                } completionHandler: {
                    completion(.success(true))
                }
            }
        }
        
    }
    
    func downVote(viewModel: WishViewModel,userUid: String, completion: @escaping(Result<Bool, Error>) -> Void) {
        
        let batchService = BatchService()
        
        let updateDataForStatus: [String: Any] = ["upVote": false]
        let updateDataForVotes: [String: Any] = ["top.votes" : FieldValue.increment(Int64(-1))]
        
        self.checkForSevenDays(viewModel: viewModel)
        let refForVotes = Ref.Fire.votes(id: viewModel.id).document(userUid)
        
        refForVotes.getDocument { (document, error) in
            
            if let document = document, document.exists {
                guard let upVote = document.get("upVote") as? Bool else { return }
                if upVote == false {
                    completion(.success(false))
                } else {
                    batchService.performBatchOperation { (batch, commit) in
                        batch.updateData(updateDataForStatus, forDocument: refForVotes)
                        batch.updateData(updateDataForVotes, forDocument: Ref.Fire.wish(id: viewModel.id))
                        completion(.success(true))
                        batch.commit()
                    } completionHandler: {
                        completion(.success(true))
                    }
                }
            } else {
                batchService.performBatchOperation { (batch, commit) in
                    batch.updateData(updateDataForVotes, forDocument: Ref.Fire.wish(id: viewModel.id))
                    
                    let vote = Vote(wishId: viewModel.id, uid: userUid, upVote: false)
                    
                    DB.create(model: vote, ref: refForVotes) { (result) in
                        switch result {
                        case .success(_): print("Successfully created model")
                        case .failure(let error ): print("DEBUG: Error is \(error.localizedDescription)")
                        }
                    }
                    completion(.success(true))
                    
                    batch.commit()
                } completionHandler: {
                    completion(.success(true))
                }
            }
        }
        
    }
    
    
    
    private func checkForSevenDays(viewModel: WishViewModel) {
        let delta = Calendar.current.dateComponents([.day], from: viewModel.publishInDate, to: Date()).day!
        
        if delta > 7 {
            Ref.Fire.wish(id: viewModel.id).updateData(["top.status" : false])
        } else {
            
        }
    }
    
    
}
