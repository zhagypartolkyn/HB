 

import Foundation
import SwiftUI
import FirebaseFirestore

class FollowViewModel: ObservableObject {
    
    // MARK: - Binding
    var navigateProfile: ((_ uid: String) -> Void)?
    
    // MARK: - Variables
    let userVM: UserViewModel
    var followingUsersUid: [String]
    @Published var isFirstActive = true
    private var limit: Int = 15
    
    // MARK: - LifeCycle
    init(userVM: UserViewModel, isFirstActive: Bool) {
        self.userVM = userVM
        self.followingUsersUid = userVM.following
        self.isFirstActive = isFirstActive
        
        fetchFollowings()
        fetchFollowers()
    }
    
    
    // MARK: - Followings
    @Published var followingUsers = [UserViewModel]()
    private var followingsLastDocument: DocumentSnapshot?
    private var canLoadMoreFollowings = true
    private var isLoadingFollowings = false
    
    func fetchFollowings() {
        if followingUsers.isEmpty {
            // Show skeleton
        }
        
        if !isLoadingFollowings && canLoadMoreFollowings {
            isLoadingFollowings = true
            
            var batchFollowingUsersUid: [String] = []

            if followingUsersUid.count > limit {
                batchFollowingUsersUid = Array(followingUsersUid[..<limit])
                followingUsersUid = Array(followingUsersUid[limit..<followingUsersUid.count])
            } else {
                batchFollowingUsersUid = followingUsersUid
                canLoadMoreFollowings = false
            }
            
            for uid in batchFollowingUsersUid {
                DB.fetchViewModel(model: User.self, viewModel: UserViewModel.self, ref: Ref.Fire.user(uid: uid)) { [self] (result) in
                    switch result {
                    case .failure(let error):
                        debugPrint(error.localizedDescription)
                    case .success(let userVM):
                        self.followingUsers.append(userVM)
                        print(self.followingUsers.count)
                    }
                }
            }
        
            isLoadingFollowings = false
        }
    }
    
    // MARK: - Followers
    @Published var followerUsers = [UserViewModel]()
    private var followersLastDocument: DocumentSnapshot?
    private var canLoadMoreFollowers = true
    private var isLoadingFollowers = false
    
    func fetchFollowers() {
        if followerUsers.isEmpty {
            // Show skeleton
        }
        
        if !self.isLoadingFollowers && self.canLoadMoreFollowers {
            self.isLoadingFollowers = true
            
            var query = Ref.Fire.users.whereField(Ref.User.following, arrayContains: userVM.uid)
            
            if let lastDocumentSnapshot = followersLastDocument {
                query = query.start(afterDocument: lastDocumentSnapshot)
            }
            
            DB.fetchViewModels(model: User.self, viewModel: UserViewModel.self, query: query, limit: limit) { (result) in
                switch result {
                case .success((let userVMs, let lastDocumentSnapshot, let canLoadMore)):
                    self.followerUsers.append(contentsOf: userVMs)
                    self.followersLastDocument = lastDocumentSnapshot
                    self.canLoadMoreFollowers = canLoadMore
                case .failure(_):
                    if self.followerUsers.isEmpty {
                        // self.showError?()
                    }
                    self.canLoadMoreFollowers = false
                }
                
                self.isLoadingFollowers = false
            }
        }
    }
    
}
