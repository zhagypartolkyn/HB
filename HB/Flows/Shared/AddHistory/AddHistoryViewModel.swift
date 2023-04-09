 

import FirebaseFirestore

class AddHistoryViewModel {
    
    // MARK: - Binding
    var showHUD: ((_ type: AlertType, _ text: String) -> Void)?
    var navigateBack: (() -> Void)?
    var sendCreatedHistory: ((_ historyVMs: HistoryViewModel) -> Void)?
    
    // MARK: - Variables
    var largeImage: UIImage
    private var thumbImage: UIImage
    private var videoURL: URL?
    
    private var history: History
    private let wishVM: WishViewModel
    private let batchService = BatchService()
    private var myUser: UserViewModel?
    
    // MARK: - LifeCycle
    init(image: UIImage, url: URL? = nil, wish: WishViewModel) {
        largeImage = image
        videoURL = url
        thumbImage = image.sd_resizedImage(with: CGSize(width: 300, height: 300), scaleMode: .aspectFill)!
        
        let author = RealmHelper.getAuthor()
        let isPhoto = url == nil
        history = History(id: "", wish: WishInfo(), author: author, status: HistoryStatus(), date: MiniDate(), text: nil,
                          type: .init(photo: isPhoto, video: !isPhoto), location: Location(), thumb: nil, image: nil, video: url?.absoluteString)
        wishVM = wish
    }
    
    // MARK: - Public Methods
    private var createdHistoryVM: HistoryViewModel?
    
    public func createHistory(description: String?) {
        showHUD?(.loading, "")
        
        getMyUser { [self] (userVM) in
            history.date.publish = Timestamp(date: Date())
            history.wish.id = wishVM.id
            history.wish.title = wishVM.title
            history.author = Author(uid: userVM.uid, username: userVM.username, thumb: userVM.avatar, gender: userVM.gender, birthday: userVM.birthday)
            history.location = wishVM.location // BUG: Location current
            history.text = description == LocalizedText.addWish.ADD_DESCRIPTION_MINI ? "" : description
            
            batchService.performBatchOperation { [self] (batch, commit) in
                
                saveMedia(history: history, batch: batch, image: largeImage, video: videoURL, thumb: thumbImage) { [self] (result) in
                    switch result {
                    case .success(let historyVM):
                        commit()
                        createdHistoryVM = historyVM
                    case .failure(let error):
                        showHUD?(.error, error.localizedDescription)
                        navigateBack?()
                    }
                }
            } completionHandler: { [self] in
                sendPushNotification()
                showHUD?(.success, LocalizedText.wish.addHistory.HISTORY_ADDED_SUCCESS)
                navigateBack?()
                
                if let createdHistoryVM = createdHistoryVM {
                    sendCreatedHistory?(createdHistoryVM)
                }
                
            }
        }
    }
    
    // MARK: - Helpers
    private func sendPushNotification() {
        for uid in wishVM.participants {
            if uid != DB.Helper.uid {
                sendRequestNotification(
                    toUid: uid,
                    title: wishVM.title,
                    subtitle: String.localizedStringWithFormat(LocalizedText.wish.addHistory.ADDED_NEW_HISTORY, DB.Helper.username),
                    type: "wish",
                    linkId: wishVM.id,
                    badge: 1)
            }
        }
    }
    
    private func getMyUser(completion: @escaping((UserViewModel) -> Void)) {
        showHUD?(.loading, "")
        DB.fetchViewModel(model: User.self, viewModel: UserViewModel.self, ref: Ref.Fire.user(uid: DB.Helper.uid)) { [self] (result) in
            switch result {
            case .success(let model): completion(model)
            case .failure(let error): showHUD?(.error, error.localizedDescription)
            }
        }
    }
    
    private func saveMedia(history: History, batch: WriteBatch, image: UIImage, video: URL?, thumb: UIImage, completion: @escaping (Result<HistoryViewModel, Error>) -> Void) {
        let ref = Ref.Fire.histories.document()
        var historyWithId = history
        historyWithId.id = ref.documentID
        DB.Storage.saveHistoryMedia(image: image, thumb: thumb, video: video, wishId: history.wish.id!, historyId: ref.documentID) { (urls) in
            historyWithId.image = urls.imageURL
            historyWithId.thumb = urls.thumbURL
            historyWithId.video = urls.videoURL
            do {
                try batch.setData(from: historyWithId, forDocument: ref)
                batch.updateData([Ref.Wish.history : FieldValue.increment(Int64(1))], forDocument: Ref.Fire.wish(id: historyWithId.wish.id!))
                completion(.success(HistoryViewModel(value: historyWithId)))
            }
            catch {
                completion(.failure(error))
                return
            }
        } onError: {
            debugPrint("error while uploading")
        }
    }
    
}
