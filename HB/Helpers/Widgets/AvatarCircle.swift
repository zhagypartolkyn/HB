 

import SwiftUI
import SDWebImageSwiftUI

struct AvatarCircle: View {
    var imageUrl: String
    var size: CGFloat
    
    var body: some View {
        WebImage(url: URL(string: imageUrl))
            .resizable()
            .placeholder {
                PlaceholderWebImage(size: size / 2, imageName: "person")
            }
            .scaledToFit()
            .frame(width: size, height: size, alignment: .center)
            .cornerRadius(size / 2)
            .foregroundColor(.blue)
    }
}

struct AvatarCircle_Previews: PreviewProvider {
    static var previews: some View {
        AvatarCircle(imageUrl: "https://firebasestorage.googleapis.com/v0/b/wanti-299809.appspot.com/o/users%2F00GBXtGWKiNoyYmsoOVnXZfiqFM2%2Favatar%2Flarge.jpg?alt=media&token=4df2fe2c-fec1-483e-a951-9329135dc2d1", size: 100)
    }
}
