 

import FirebaseStorage
import AVFoundation
import FirebaseFirestore

struct HistoryURls {
    var imageURL: String
    var thumbURL: String
    var videoURL: String?
}

enum StorageHelpers {
    
    static func saveHistoryMedia(image: UIImage, thumb: UIImage, video: URL?, wishId: String, historyId: String, onSuccess: @escaping (_ urls: HistoryURls) -> Void, onError: @escaping () -> Void) {
        var videoRef: StorageReference?
        let imageRef = Ref.Store.history(wishId: wishId, historyId: historyId, name: "image", isVideo: false)
        let thumbRef = Ref.Store.history(wishId: wishId, historyId: historyId, name: "thumb", isVideo: false)
        if video != nil {
            videoRef = Ref.Store.history(wishId: wishId, historyId: historyId, name: "video", isVideo: true)
        }
        guard let imageCompressed = image.jpegData(compressionQuality: 0.4), let thumbCompressed = image.jpegData(compressionQuality: 0.4) else {
            return
        }
        var urls = HistoryURls(imageURL: "", thumbURL: "", videoURL: nil)
        let group = DispatchGroup()
        let enterImage = {
            group.enter()
            savePhoto(imageData: imageCompressed, storageRef: imageRef) { (result) in
                switch result {
                case .success(let url):
                    urls.imageURL = url
                    group.leave()
                case .failure(let error):
                    debugPrint(error)
                    group.leave()
                }
            }
        }
        let enterThumb = {
            group.enter()
            savePhoto(imageData: thumbCompressed, storageRef: thumbRef) { (result) in
                switch result {
                case .success(let url):
                    urls.thumbURL = url
                    group.leave()
                case .failure(let error):
                    debugPrint(error)
                    group.leave()
                }
            }
        }
        var enterVideo: (() -> Void)?
        if let video = video, let vRef = videoRef {
            enterVideo = {
                group.enter()
                
                compressVideo(withUrl: video) { (url) in
                    self.saveVideo(url: url, storageRef: vRef) { (result) in
                        switch result {
                        case .success(let videoUrl):
                            urls.videoURL = videoUrl
                            group.leave()
                        case .failure(let error):
                            debugPrint(error)
                            group.leave()
                        }
                    }
                }
            }
        }
        var items = [enterImage, enterThumb]
        if let enterVideo = enterVideo {
            items.append(enterVideo)
        }
        items.forEach { $0() }
        group.notify(queue: .main) {
            if !urls.imageURL.isEmpty, !urls.thumbURL.isEmpty {
                onSuccess(urls)
            }
        }
        
    }
    
    private func saveHistoryMediaHelper(id: String, data: [[String : String]], onSuccess: @escaping() -> Void, onError: @escaping(_ errorMessage: String) -> Void) {
        Ref.Fire.history(id: id).updateData(["media" : data]) { (error) in
            if let error = error {
                onError(error.localizedDescription)
                return
            }
            onSuccess()
        }
    }
    
    // Save user avatar in two size -> Avatar 1080x1080 and Avatar Thumb 200x200
    static func saveAvatar(thumb: UIImage, large: UIImage, completion: @escaping(Result<(String, String), Error>) -> Void) {

        guard let largeCompressed = large.jpegData(compressionQuality: 0.4), let thumbCompressed = thumb.jpegData(compressionQuality: 0.4) else { return }

        savePhoto(imageData: largeCompressed, storageRef: Ref.Store.avatar(uid: DB.Helper.uid, name: Ref.Image.large)) { (largeResult) in
            switch largeResult {
            case .success(let largeUrl):
                savePhoto(imageData: thumbCompressed, storageRef: Ref.Store.avatar(uid: DB.Helper.uid, name: Ref.Image.thumb)) { (thumbResult) in
                    switch thumbResult {
                    case .success(let thumbUrl): completion(.success((largeUrl, thumbUrl)))
                    case .failure(let error): completion(.failure(error))
                    }
                }
            case .failure(let error): completion(.failure(error))
            }
        }
    }
    
    // Save user avatar in two size -> Avatar 1080x1080 and Avatar Thumb 200x200
    static func saveWishImage(image: UIImage, wishId: String, completion: @escaping(Result<String, Error>) -> Void) {

        guard let imageCompressed = image.jpegData(compressionQuality: 0.4) else { return }
        let imageRef = Ref.Store.wish(id: wishId, name: Ref.Wish.image)
        
        savePhoto(imageData: imageCompressed, storageRef: imageRef) { (result) in
            switch result {
            case .success(let url):
                Ref.Fire.wish(id: wishId).updateData([ Ref.Wish.image: url ]) { (error) in
                    if let error = error {
                        completion(.failure(error))
                        return
                    }
                    completion(.success(url))
                }
            case .failure(let error): completion(.failure(error))
            }
        }
    }
    
    // Save history images
    
    // Just load image to storage
    static func savePhoto(imageData: Data, storageRef: StorageReference, completion: @escaping(Result<String, Error>) -> Void) {
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpg"
        
        storageRef.putData(imageData, metadata: metadata, completion: { (_, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            storageRef.downloadURL(completion: { (url, _) in
                if let url = url?.absoluteString {
                    completion(.success(url))
                }
            })
        })
    }
    
    // Thumb for video
    static func thumbnailImageForFileUrl(_ url: URL) -> UIImage? {
        let asset = AVAsset(url: url)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        var time = asset.duration
        time.value = min(time.value, 2)
        do {
            let imageRef = try imageGenerator.copyCGImage(at: time, actualTime: nil)
            return UIImage(cgImage: imageRef)
        } catch let error as NSError {
            debugPrint(error)
            return nil
        }
    }
    
    // Save video
    static func saveVideo(url: URL, storageRef: StorageReference, completion: @escaping((Result<String, Error>) -> Void)) {
        
        guard let videoData = NSData(contentsOf: url) as Data? else {
            completion(.failure(NSError(domain: "", code: 403, userInfo: [NSLocalizedDescriptionKey: "Video by local URL not found"])))
            return
        }
        
        let metadata = StorageMetadata()
        metadata.contentType = "video/quicktime"
        
        storageRef.putData(videoData, metadata: metadata) { (_, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            storageRef.downloadURL(completion: { (videoUrl, _) in
                if let videoUrl = videoUrl {
                    completion(.success(videoUrl.absoluteString))
                } else {
                    completion(.failure(NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: "Firebase not return video url"])))
                }
            })
        }
    }
    
}
