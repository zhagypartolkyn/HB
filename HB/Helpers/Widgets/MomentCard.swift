 
import SwiftUI
import SDWebImageSwiftUI

struct MomentCard: View {
    var historyVM: HistoryViewModel
    var height: CGFloat
    var width: CGFloat
    
    var body: some View {
        
            ZStack {
                WebImage(url: URL(string: historyVM.thumb))
                    .resizable()
                    .placeholder {
                        PlaceholderWebImage(size: 32, imageName: "photo")
                    }
                    .aspectRatio(contentMode: .fill)
                    .frame(minWidth: width, idealWidth: width, maxWidth: width, minHeight: height, idealHeight: height, maxHeight: height, alignment: .center)
                    .clipped()
                    .cornerRadius(0)
                VStack(alignment: .center) {
                    Spacer()
                    AvatarCircle(imageUrl: historyVM.avatar, size: 50)
                    Spacer().frame(height: 32)
                }
                if historyVM.mediaType == .video {
                    VStack(alignment: .center) {
                        Spacer()
                        Image(systemName: "play.fill")
                            .resizable()
                            .frame(width: 24, height: 24)
                            .foregroundColor(.white)
                            .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0.0, y: 0.0)
                        Spacer()
                    }
                }
            }
            .frame(minWidth: width, idealWidth: width, maxWidth: width, minHeight: height, idealHeight: height, maxHeight: height, alignment: .center)
            .contentShape(Rectangle())
        
    }
}

struct MomentCard_Previews: PreviewProvider {
    static var previews: some View {
        MomentCard(historyVM: HistoryViewModel(value: historyExample), height: 120, width: 250)
    }
}
