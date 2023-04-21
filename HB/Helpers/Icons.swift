 

import UIKit

let iconConfiguration = UIImage.SymbolConfiguration(weight: .semibold)

enum Icons {
    
    enum General {
        static let wanty = UIImage(named: "wanty")
        static let logo = UIImage(named: "logo")
        static let logoTitle = UIImage(named: "logo_title")
        static let splash = UIImage(named: "splash")
        static let avatar = UIImage(systemName: "person.circle", withConfiguration: iconConfiguration)
        static let camera = UIImage(systemName: "camera.fill", withConfiguration: iconConfiguration)
        static let more = UIImage(systemName: "ellipsis", withConfiguration: iconConfiguration)
        static let share = UIImage(systemName: "share", withConfiguration: iconConfiguration)
        static let add = UIImage(systemName: "plus", withConfiguration: iconConfiguration)
        static let arrow_back = UIImage(systemName: "chevron.left", withConfiguration: iconConfiguration)
        static let arrow_next = UIImage(systemName: "chevron.right", withConfiguration: iconConfiguration)
        static let cancel = UIImage(systemName: "xmark", withConfiguration: iconConfiguration)
        static let map = UIImage(systemName: "map", withConfiguration: iconConfiguration)
        static let pin = UIImage(systemName: "mappin.and.ellipse", withConfiguration: iconConfiguration)
        static let connect = UIImage(systemName: "personalhotspot", withConfiguration: iconConfiguration)
        
        static let settings = UIImage(systemName: "gear", withConfiguration: iconConfiguration)
        static let search = UIImage(systemName: "magnifyingglass", withConfiguration: iconConfiguration)
    }
    
    enum Onboarding {
        static let _1 = UIImage(named: "onboarding1")
        static let _2 = UIImage(named: "onboarding2")
        static let _3 = UIImage(named: "onboarding3")
    }
    
    enum Welcome {
        static let background = UIImage(named: "welcomeBackground")
        enum Avatar {
            static let _1 = UIImage(named: "welcomeAvatar1")
            static let _2 = UIImage(named: "welcomeAvatar2")
            static let _3 = UIImage(named: "welcomeAvatar3")
            static let _4 = UIImage(named: "welcomeAvatar4")
            static let _5 = UIImage(named: "welcomeAvatar5")
            static let _6 = UIImage(named: "welcomeAvatar6")
            static let _7 = UIImage(named: "welcomeAvatar7")
            static let _8 = UIImage(named: "welcomeAvatar8")
        }
    }
    
    enum Sign {
        static let google = UIImage(named: "google")
        static let facebook = UIImage(named: "facebook")
        static let email = UIImage(systemName: "envelope", withConfiguration: iconConfiguration)
        static let phone = UIImage(systemName: "phone", withConfiguration: iconConfiguration)
        static let passwordHide = UIImage(systemName: "eye", withConfiguration: iconConfiguration)
        static let passwordShow = UIImage(systemName: "eye.slash", withConfiguration: iconConfiguration)
    }
    
    enum TabBar {
        static let home = UIImage(systemName: "house", withConfiguration: iconConfiguration)
        static let homeActive = UIImage(systemName: "house.fill", withConfiguration: iconConfiguration)
        static let interesting = UIImage(systemName: "flame", withConfiguration: iconConfiguration)
        static let interestingActive = UIImage(systemName: "flame.fill", withConfiguration: iconConfiguration)
        static let add = UIImage(systemName: "plus.rectangle.fill", withConfiguration: iconConfiguration)
        static let addActive = UIImage(systemName: "plus.rectangle.fill", withConfiguration: iconConfiguration)
        static let messages = UIImage(systemName: "bubble.left.and.bubble.right", withConfiguration: iconConfiguration)
        static let messagesActive = UIImage(systemName: "bubble.left.and.bubble.right.fill", withConfiguration: iconConfiguration)
        static let profile = UIImage(systemName: "person", withConfiguration: iconConfiguration)
        static let profileActive = UIImage(systemName: "person.fill", withConfiguration: iconConfiguration)
    }
    
    enum Add {
        static let group = UIImage(named: "group")
        static let single = UIImage(named: "single")
    }
    
    enum Notification {
        static let off = UIImage(systemName: "bell", withConfiguration: iconConfiguration)
        static let on = UIImage(systemName: "bell.fill", withConfiguration: iconConfiguration)
    }
    
    enum Camera {
        static let gallery = UIImage(systemName: "photo", withConfiguration: iconConfiguration)
        static let shootButton = UIImage(systemName: "smallcircle.fill.circle", withConfiguration: iconConfiguration)
        static let recordButton = UIImage(systemName: "largecircle.fill.circle", withConfiguration: iconConfiguration)
        static let switchCamera = UIImage(systemName: "arrow.3.trianglepath", withConfiguration: iconConfiguration)
    }

    enum Chat {
        static let send = UIImage(systemName: "paperplane.fill", withConfiguration: iconConfiguration)
        static let attach = UIImage(systemName: "paperclip", withConfiguration: iconConfiguration)
    }
    
    enum Profile {
        static let activeRadiobutton = UIImage(named: "activeRadiobutton")
        static let radiobutton = UIImage(named: "radiobutton")
        static let verifiedSign = UIImage(named: "verified")
    }
    
    enum Wish {
        static let active = UIImage(systemName: "bolt.fill", withConfiguration: iconConfiguration)
        static let complete = UIImage(systemName: "flag.fill", withConfiguration: iconConfiguration)
        static let group = UIImage(systemName: "person.2.fill", withConfiguration: iconConfiguration)
        static let single = UIImage(systemName: "person.fill", withConfiguration: iconConfiguration)
        static let history = UIImage(systemName: "photo.on.rectangle", withConfiguration: iconConfiguration)
        
        static let play = UIImage(systemName: "play", withConfiguration: iconConfiguration)
        static let refresh = UIImage(systemName: "arrow.clockwise", withConfiguration: iconConfiguration)
        
        static let upVote = UIImage(systemName: "arrow.up.circle", withConfiguration: iconConfiguration)
        static let downVote = UIImage(systemName: "arrow.down.circle", withConfiguration: iconConfiguration)
        static let arrowUp = UIImage(named: "arrowUp")
        static let arrowDown = UIImage(named: "arrowDown")
    }
    
    enum Error {
        static let feed = UIImage(named: "feed")
        static let city = UIImage(named: "City-1")
        static let moments = UIImage(named: "Moments")
        static let requests = UIImage(named: "Requests")
        static let activities = UIImage(named: "Activities")
        static let search = UIImage(named: "Search")
        static let connects = UIImage(named: "Connects")
        static let room = UIImage(named: "Rooms")
    }

}
