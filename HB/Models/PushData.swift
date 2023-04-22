 

enum PushType: String {
    case follow = "follow"
    case request = "request"
    case chat = "chat"
    case wish = "wish"
}

struct PushData {
    let type: PushType
    let linkId: String
}
