 

import UIKit

enum Fonts {
    static let Heading1 = UIFont.preferredFont(forTextStyle: .largeTitle).with(weight: .bold) // 36
    static let Heading2 = UIFont.preferredFont(forTextStyle: .title1).with(weight: .bold) // 24
    static let Heading3 = UIFont.preferredFont(forTextStyle: .title3).with(weight: .bold) // 20
    
    static let Paragraph = UIFont.preferredFont(forTextStyle: .body) // 15
    static let Secondary = UIFont.preferredFont(forTextStyle: .subheadline) // 14
    static let Tertiary = UIFont.preferredFont(forTextStyle: .footnote) // 13
    
    enum Semibold {
        static let Paragraph = UIFont.preferredFont(forTextStyle: .body).with(weight: .semibold) // 15
        static let Secondary = UIFont.preferredFont(forTextStyle: .subheadline).with(weight: .semibold) // 14
        static let Tertiary = UIFont.preferredFont(forTextStyle: .footnote).with(weight: .semibold) // 13
    }
    
    static let Small = UIFont.preferredFont(forTextStyle: .caption2) // 10
}
