//
 

import Foundation
import Firebase
import FirebaseFirestore

class PeopleSearchViewModel {
    
    // MARK: - Binding
    var navigateProfile: ((_ uid: String) -> Void)?
    
    // MARK: - Search
    var userVMs = [UserViewModel]()
    var isLoading = false
    
    func searchUsers(query: String, completion: @escaping((_ userVMs: [UserViewModel]) -> Void)){
        
        if !isLoading {
            isLoading = true
            
            print("load more")
            
            Functions.functions().httpsCallable("userSearch").call(["query": query.trimmingCharacters(in: .whitespacesAndNewlines),
                                                                    "offset": userVMs.count,
                                                                    "perPage": 10]) { [self] (result, error) in
                
                if let error = error {
                    print(error)
                    isLoading = false
                } else if let data = result?.data as? String, let parsedData = data.data(using: .utf8) {
                    
                    do {
                        let usersModels = try JSONDecoder().decode(UserJsonWelcome.self, from: parsedData).hits?.hits
                        
                        usersModels?.forEach { (userModel) in
                            guard let source = userModel.source else { return }
                            
                            let timestamp = Timestamp()
                            var avatar = UserAvatar()
                            avatar.thumb = source.avatar?.thumb
                            let user = User(uid: source.uid,
                                            username: source.username,
                                            gender: source.gender,
                                            birthday: timestamp,
                                            email: source.email,
                                            following: source.following,
                                            counters: UserCounters(),
                                            avatar: avatar,
                                            location: Location(),
                                            status: UserStatus(),
                                            ban: UserBan(),
                                            online: UserOnline(),
                                            accounts: UserAccounts(),
                                            date: UserDate())
                            
                            let userVM = UserViewModel(value: user)
                            
                            self.userVMs.append(userVM)
                        }
                        print("1")
                        completion(self.userVMs)
                        isLoading = false
                    } catch {
                        print("2")
                        debugPrint(error)
                        print("DEBUG: User not found :\(error)")
                        isLoading = false
                    }
                
                
                } else {
                    print("no")
                }
                
            }
        
        }
    }

}
