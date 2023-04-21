 

import UIKit

struct ReservedUsername : Codable {
    let type: String
    let username: String
}

class JsonViewController: UIViewController {
    
    var success = 0
    var error = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let usernames = loadJson(fileName: "data") {
            usernames.all.forEach { (usernameObj) in
                DB.create(
                    model: ReservedUsername(type: usernameObj.type, username: usernameObj.username),
                    ref: Ref.Fire.reservedUsernames.document()) { (result) in
                    switch result {
                    case .success(_):
                        self.success += 1
                        print("success \(self.success)")
                    case .failure(_):
                        self.error += 1
                        print("error \(self.error) \(usernameObj.type) \(usernameObj.username)")
                    }
                }
            }
        }
    }
    
    
    struct ReservedUsernames : Codable {
        let all: [ReservedUsername]
    }
    
    func loadJson(fileName: String) -> ReservedUsernames? {
        let decoder = JSONDecoder()
        guard
            let url = Bundle.main.url(forResource: fileName, withExtension: "json"),
            let data = try? Data(contentsOf: url),
            let usernames = try? decoder.decode(ReservedUsernames.self, from: data) else { return nil }
        return usernames
    }
}
