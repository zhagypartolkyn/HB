 

import SwiftUI

struct PlaceholderWebImage: View {
    var size: CGFloat
    var imageName: String
    var body: some View {
        ZStack{
            Rectangle().foregroundColor(.gray)
            Image(systemName: imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundColor(.white)
                .opacity(0.5)
                .frame(width: size, height: size)
        }
    }
}

struct DefaultEmptyImage_Previews: PreviewProvider {
    static var previews: some View {
        PlaceholderWebImage(size: 32, imageName: "photo")
    }
}
