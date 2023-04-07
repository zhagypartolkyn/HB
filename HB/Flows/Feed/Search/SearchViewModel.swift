 

import Foundation
import FirebaseFunctions
import FirebaseFirestore

class SearchViewModel {
    
    // MARK: - Binding
    var navigateProfile: ((_ uid: String) -> Void)?
    var navigateWish: ((_ wishVM: WishViewModel?, _ wishId: String?) -> Void)?
    var navigateReport: ((_ reportObject: ReportObject) -> Void)?
    var navigateComplete: ((_ wishVM: WishViewModel) -> Void)?
    
    // MARK: - Search
    var searchWishVMs: [WishViewModel] = []
    var isLoading = false
    
    func searchWishes(query: String, placeId: String, completion: @escaping((_ wishVMs: [WishViewModel]) -> Void)) {
        if !isLoading {
            isLoading = true
            
            Functions.functions().httpsCallable("wishSearch").call(["query": query,
                                                                    "offset": searchWishVMs.count,
                                                                    "perPage": 10,
                                                                    "placeId": placeId]) { [self] (result, error) in
                
                if let error = error {
                    print(error)
                    isLoading = false
                } else if let data = result?.data as? String, let parsedData = data.data(using: .utf8) {
                    do {
                        let wishSearchResultModels = try JSONDecoder().decode(WishSearch.self, from: parsedData).hits?.hits
                        
                        wishSearchResultModels?.forEach { (wishSearch) in
                            
                            let birthday = Timestamp(seconds: wishSearch.source.author.birthday.seconds,
                                                      nanoseconds: wishSearch.source.author.birthday.nanoseconds)
                            
                            let author = Author(uid: wishSearch.source.author.uid,
                                                username: wishSearch.source.author.username,
                                                thumb: wishSearch.source.author.thumb,
                                                gender: wishSearch.source.author.gender,
                                                birthday: birthday)
                            
                            let publish = Timestamp(seconds: wishSearch.source.date.publish.seconds,
                                                      nanoseconds: wishSearch.source.date.publish.nanoseconds)
                            
                            var wishDate = WishDate()
                            wishDate.publish = publish
                            
                            var geo = Location()
                            if let geoPoint = wishSearch.source.geoPoint {
                                geo.geoPoint = GeoPoint(latitude: geoPoint.lat, longitude: geoPoint.lon)
                            }
                            
                            let wish = Wish(
                                id: wishSearch.id,
                                title: wishSearch.source.title,
                                description: wishSearch.source.sourceDescription,
                                image: wishSearch.source.image,
                                type: wishSearch.source.type,
                                status: WishStatus(),
                                location: geo,
                                date: wishDate,
                                likes: wishSearch.source.likes,
                                participants: wishSearch.source.likes,
                                refused: wishSearch.source.likes,
                                history: wishSearch.source.history,
                                author: author)
                            
                            let wishVM = WishViewModel(value: wish)
                            
                            self.searchWishVMs.append(wishVM)
                        }
                        
                        completion(self.searchWishVMs)
                        isLoading = false
                    } catch {
                        debugPrint(error)
                        isLoading = false
                    }
                    
                }
            }
            
            
        }
        
    }
    
}
