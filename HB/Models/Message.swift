 
import MessageKit
import CoreLocation

class Message {
    var id: String
    
    var uid: String
    var username: String
    
    var date: Double
    var text: String
    var type: String
    var wishId: String
    var wishTitle: String
    var imageUrl: String
    var videoUrl: String
    
    init(id: String, uid: String, username: String, date: Double, text: String, type: String, wishTitle: String, wishId: String, imageUrl: String, videoUrl: String) {
        self.id = id
        self.uid = uid
        self.username = username
        self.date = date
        self.text = text
        self.type = type
        self.wishTitle = wishTitle
        self.wishId = wishId
        self.imageUrl = imageUrl
        self.videoUrl = videoUrl
    }
    
    static func transformMessage(dict: [String: Any], keyId: String) -> Message? {
//        guard let uid = dict[Ref.Message.uid] as? String,
//            let date = dict[Ref.Message.date] as? Double else {
//                return nil
//        }
        let uid = dict[Ref.Message.uid] as? String == nil ? "" : (dict[Ref.Message.uid]! as! String)
        let date = dict[Ref.Message.date] as? Double == nil ? 0 : (dict[Ref.Message.date]! as! Double)
        let username = (dict[Ref.Message.username] as? String) == nil ? "" : (dict[Ref.Message.username]! as! String)
        
        let text = (dict[Ref.Message.text] as? String) == nil ? "" : (dict[Ref.Message.text]! as! String)
        let type = (dict[Ref.Message.type] as? String) == nil ? "" : (dict[Ref.Message.type]! as! String)
        let wishId = (dict[Ref.Message.wishId] as? String) == nil ? "" : (dict[Ref.Message.wishId]! as! String)
        let wishTitle = (dict[Ref.Message.wishTitle] as? String) == nil ? "" : (dict[Ref.Message.wishTitle]! as! String)
        let imageUrl = (dict[Ref.Message.imageUrl] as? String) == nil ? "" : (dict[Ref.Message.imageUrl]! as! String)
        let videoUrl = (dict[Ref.Message.videoUrl] as? String) == nil ? "" : (dict[Ref.Message.videoUrl]! as! String)
        
        let message = Message(id: keyId, uid: uid, username: username, date: date, text: text, type: type, wishTitle: wishTitle, wishId: wishId, imageUrl: imageUrl, videoUrl: videoUrl)
        return message
    }
    
    static func hash(forMembers members: [String]) -> String {
        let hash = members[0].hashString ^ members[1].hashString
        let memberHash = String(hash)
        return memberHash
    }
}

extension Message: MessageType {
    
    var sender: SenderType {
        return MockSenderItem(senderId: uid, displayName: username)
    }
    
    var messageId: String {
        return id
    }
    
    var sentDate: Date {
        return Date(timeIntervalSince1970: Double(TimeZone.current.secondsFromGMT(for: Date(timeIntervalSince1970: 0))) + date / 1000 )
    }
    
    var kind: MessageKind {
        if type == "video" {
            if let imageUrl = URL(string: imageUrl), let videoUrl = URL(string: videoUrl) {
                return .video(MockMediaItem(url: imageUrl, videoUrl: videoUrl))
            } else {
                return .text("Video not found")
            }
        } else if type == "image" {
            if let imageUrl = URL(string: imageUrl) {
                return .photo(MockMediaItem(url: imageUrl))
            } else {
                return .text("Photo not found")
            }
        } else {
            return .text(text)
        }
    }
    
}

public struct MockSenderItem: SenderType {
    public var senderId: String
    public let displayName: String
}

struct MockMediaItem: MediaItem {
    var url: URL?
    var videoUrl: URL?
    var image: UIImage?
    var placeholderImage: UIImage
    var size: CGSize
    
    init(url: URL, videoUrl: URL? = nil) {
        self.url = url
        self.videoUrl = videoUrl
        self.size = CGSize(width: 100, height: 160)
        self.placeholderImage = UIImage()
    }
}

private struct MockLocationItem: LocationItem {
    var location: CLLocation
    var size: CGSize

    init(location: CLLocation) {
        self.location = location
        self.size = CGSize(width: 240, height: 240)
    }
}
