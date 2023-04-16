 

import SwiftUI
import SDWebImageSwiftUI

struct WishCard: View {
    var wishVM: WishViewModel
    var imageHeight: CGFloat
    var textWidth: CGFloat
    @ObservedObject var viewModel: HouseViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            
            header
            
            if !wishVM.image.isEmpty { image }
            
            Text(wishVM.title)
                .fontWeight(.semibold)
                .font(.body)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true) //** It keeps 'width size' and expands 'height size'
                .frame(width: textWidth, alignment: .leading)
                .foregroundColor(Color(UIColor.label))
            
            buttom
        }
        .padding(.all, 16)
        .background(Color.init(UIColor.systemBackground))
        .cornerRadius(20)
        .shadow(color: Color(UIColor.appColor(.primary)).opacity(0.1), radius: 20, x: 0, y: 10)
        .onTapGesture {
            viewModel.navigateWish?(wishVM, nil)
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
        
    }
    
    private var header: some View {
        HStack(spacing: 8) {
            AvatarCircle(imageUrl: wishVM.avatar, size: 40)
                .onTapGesture {
                    viewModel.navigateProfile?(wishVM.author.uid)
                }
            
            VStack(alignment: .leading, spacing: 0) {
                Text(wishVM.username)
                    .font(.body)
                    .fontWeight(.semibold)
                    .foregroundColor(Color(UIColor.label))
                    .onTapGesture {
                        viewModel.navigateProfile?(wishVM.author.uid)
                    }
            
                HStack(spacing: 4) {
                    Text(wishVM.publishDate)
                        .font(.footnote)
                        .fontWeight(.semibold)
                        .foregroundColor(.gray)
                    
                    Image(systemName: wishVM.isComplete ? "flag.fill" : "bolt.fill")
                        .font(.caption)
                        .foregroundColor(wishVM.isComplete ? .gray : .green)
                
                    Text(wishVM.isComplete ? LocalizedText.wish.COMPLETED : LocalizedText.wish.ACTIVE)
                        .font(.footnote)
                        .fontWeight(.semibold)
                        .foregroundColor(wishVM.isComplete ? .gray : .green)
                }
            }
            
            Spacer()
            
            Button(action: {
                viewModel.showMore?(wishVM)
            }, label: {
                Image(systemName: "ellipsis")
                    .foregroundColor(.gray)
                    .frame(width: 40, height: 40, alignment: .center)
            })
        }
    }
    
    private var image: some View {
        WebImage(url: URL(string: wishVM.image))
            .resizable()
            .placeholder {
                PlaceholderWebImage(size: 32, imageName: "photo")
            }
            .scaledToFill()
            .frame(minWidth: 200, idealWidth: 200, maxWidth: .infinity, minHeight: imageHeight, idealHeight: imageHeight, maxHeight: imageHeight, alignment: .center)
            .cornerRadius(14)
            .foregroundColor(.gray)
    }
    
    private var buttom: some View {
        HStack {
            HStack(alignment: .center, spacing: 4) {
                Image(systemName: wishVM.isGroupWish ? "person.2.fill" : "person.fill")
                    .font(.caption)
                Text(wishVM.isGroupWish ? LocalizedText.addWish.GROUP : LocalizedText.addWish.SINGLE)
                    .font(.footnote)
                    .fontWeight(.semibold)
                Image(systemName: "photo.on.rectangle")
                    .font(.caption)
                Text("\(wishVM.numberOfHistories)")
                    .font(.footnote)
                    .fontWeight(.semibold)
            }
            .foregroundColor(.gray)
            
            Spacer()
            
            Button(action: {
                viewModel.navigateWish?(wishVM, nil)
            }, label: {
                Text(LocalizedText.General.more)
                    .font(.footnote)
                    .fontWeight(.semibold)
                    .foregroundColor(Color(UIColor.appColor(.primary)))
            })
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color.init(UIColor.appColor(.secondary)))
            .cornerRadius(100)
        }
    }
    
}

struct WishCard_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Spacer()
            WishCard(wishVM: WishViewModel(value: wishExample), imageHeight: 200, textWidth: 200, viewModel: HouseViewModel())
                .padding(.horizontal, 16)
            Spacer()
        }
        .background(Color(UIColor.appColor(.backgroundSecondary)))
    }
}
