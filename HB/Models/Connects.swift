 

import Foundation

struct Connects: Codable {
    var uid: String
    var connects: [Connect]
    
    init(uid: String) {
        self.uid = uid
        connects = []
    }
}
