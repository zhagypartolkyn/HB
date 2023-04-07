 

import FirebaseFunctions
import FirebaseFirestore
import MapKit

class MapViewModel {
    
    // MARK: - Binding
    var navigateProfile: ((_ uid: String) -> Void)?
    var navigateWish: ((_ wishVM: WishViewModel?, _ wishId: String?) -> Void)?
    
    var reloadMapWithData: (([MKAnnotation])->())?
    var showHUD: ((_ type: AlertType, _ text: String) -> Void)?
    
    // MARK: - Variables
    var placeId: String? = nil
    var limit: Int = 20
    var isLoading = false
    var canLoadMore = true
    var lastDocumentSnapshot: DocumentSnapshot?
    var wishVMs: [WishViewModel] = []
    
    init(placeId: String? = nil) {
        self.placeId = placeId
    }
    
    // MARK: - List Wish
    func fetchWishes() {
        guard let placeId = placeId else { return }
        showHUD?(.loading, "")
        
        if !canLoadMore {
            fetchWishesForMap()
        }
        
        if !isLoading, canLoadMore {
            isLoading = true
            
            let query = Queries.Wish.map(placeId: placeId, lastDocumentSnapshot: lastDocumentSnapshot)
            
            DB.fetchViewModels(model: Wish.self, viewModel: WishViewModel.self, query: query, limit: limit) { (result) in
                switch result {
                case .success((let wishVMs, let lastDocumentSnapshot, let canLoadMore)):
                    self.lastDocumentSnapshot = lastDocumentSnapshot
                    self.canLoadMore = canLoadMore
                    self.wishVMs += wishVMs
                    self.fetchWishesForMap()
                case .failure(_):
                    self.canLoadMore = false
                    self.showHUD?(.dismiss, "")
                }
                
                self.isLoading = false
            }
        }
    }
    
    // MARK: - MAP
    var nearByAnnotations: [MKAnnotation] = []
    private var mapPage: Int = 1
    var currentShowWishVMs: [WishViewModel] = []
    
    func fetchWishesForMap() {
        let max = mapPage * limit
        let min = max - limit
        
        if wishVMs.count < (min + 1) {
            if canLoadMore {
                fetchWishes()
            } else {
                mapPage = 1
                fetchWishesForMap()
            }
        } else {
            let currentMapWishVMs = (wishVMs.count >= max) ? Array(wishVMs[min..<max]) : Array(wishVMs[min...])
            createAndShowAnnotations(wishVMs: currentMapWishVMs)
            mapPage += 1
        }
    }
    
    func createAndShowAnnotations(wishVMs: [WishViewModel]) {
        currentShowWishVMs = wishVMs
        nearByAnnotations = []
        
        for wishVM in wishVMs {
            guard let geoPoint = wishVM.location.geoPoint else { return }
            
            let annotation = WishAnnotation( id: wishVM.id, type: wishVM.type,
                                             title: wishVM.title, subtitle: wishVM.username,
                                             coordinate: CLLocationCoordinate2D(latitude: geoPoint.latitude, longitude: geoPoint.longitude),
                                             viewModel: wishVM)
            
            annotation.cover.kf.setImage(with: URL(string: wishVM.avatar), completionHandler:  { [weak self] _ in
                self?.nearByAnnotations.append(annotation)
            })
        }
        reloadMapWithData?(self.nearByAnnotations)
    }
    
    // MARK: - Search
    var searchWishVMs: [WishViewModel] = []
    var isLoadingSearch = false
    
    func cancelSearch() {
        createAndShowAnnotations(wishVMs: wishVMs)
        searchWishVMs = []
    }
    
    func searchWishes(onPage page: Int, query: String, onPlace place: String) {
        if !isLoading {
            isLoading = true
            
            showHUD?(.loading, "")
            Functions.functions().httpsCallable("wishSearch").call(["query": query,
                                                                    "offset": searchWishVMs.count,
                                                                    "perPage": limit,
                                                                    "placeId": place]) { [self] (result, error) in
                
                if let error = error {
                    print(error)
                    isLoading = false
                } else if let data = result?.data as? String, let parsedData = data.data(using: .utf8) {
                    do {
                        let wishSearchResultModels = try JSONDecoder().decode(WishSearch.self, from: parsedData).hits?.hits
                        
                        var wishVMs: [WishViewModel] = []
                        
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
                            
                            guard let geoPoint = wishSearch.source.geoPoint else { return }
                            geo.geoPoint = GeoPoint(latitude: geoPoint.lat, longitude: geoPoint.lon)
                            
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
                            
                            wishVMs.append(wishVM)
                        }
                        
                        self.createAndShowAnnotations(wishVMs: wishVMs)
                        self.showHUD?(.dismiss, "")
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
