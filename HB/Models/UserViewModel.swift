 
import UIKit
import FirebaseFirestore

final class UserViewModel: DefaultConstructible {
    let uid: String
    let username: String
    let name: String
    let email: String
    let avatar: String
    let largeAvatar: String
    let gender: String
    let birthday: Timestamp
    let bio: String
    
    var following: [String]
    var counters: UserCounters
    
    var isRegistered: Bool
    var isNeedSocialRegistration: Bool
    var isMe: Bool
    var verified:  Bool
    
    var information: String
    var cityWithCountryCode: String
    var attributedText: NSMutableAttributedString
    let isOnline: Bool
    var activeCount = 0
    var completeCount = 0
    var participantCount = 0
    
    init(value: Codable) {
        let user = value as! User
        
        self.uid = user.uid ?? "1"
        self.username = user.username ?? "Имя пользователя"
        
        if user.name != nil && user.name != "" {
            name = user.name ?? "Имя"
        } else {
            name = self.username
        }
        self.email = user.email ?? ""
        self.cityWithCountryCode = "\(user.location.countryCode?.uppercased() ?? "NA"), \(user.location.city ?? "NA")"
        self.avatar = user.avatar.thumb ?? ""
        self.largeAvatar = user.avatar.large ?? ""
        self.gender = user.gender ?? "male"
        self.birthday = user.birthday ?? Timestamp(date: Date())
        self.bio = user.bio ?? ""
        
        self.following = user.following
        self.counters = user.counters
        self.isRegistered = user.status.correct
        self.isNeedSocialRegistration = !user.status.socialCorrect
        self.isMe = DB.Helper.uid == user.uid ? true : false
        self.verified = user.verified ?? false
        
        let birthdayDate = user.birthday?.dateValue()
        let age = Calendar.current.dateComponents([.year], from: birthdayDate ?? Date(), to: Date()).year
        information = "\(age!) лет, \(user.gender == "male" ? "Муж" : "Жен")"
        if let city = user.location.city {
            information = "\(city), " + information
        }
        
        attributedText = NSMutableAttributedString(string: self.username, attributes: [.font : Fonts.Paragraph, .foregroundColor : UIColor.appColor(.textPrimary)])
        attributedText.append(NSAttributedString(string: "\n \(information)", attributes: [.font : Fonts.Tertiary, .foregroundColor : UIColor.appColor(.textPrimary)]))
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 4
        paragraphStyle.alignment = .center
        attributedText.addAttributes([NSAttributedString.Key.paragraphStyle : paragraphStyle], range: NSRange(location: 0, length: attributedText.length))
        
        self.isOnline = user.online.status
        
    }
}
