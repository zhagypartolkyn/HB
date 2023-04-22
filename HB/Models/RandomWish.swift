 

import UIKit
import FirebaseFirestore
import FirebaseFirestoreSwift

struct RandomWish: Codable {
    var id: String
    var title: String
    var description: String?
    var images: [String] = []
}
