 

import SwiftUI

struct FollowCard: View {
    let userVM: UserViewModel
    
    var body: some View {
        HStack(alignment: .center, spacing: 8) {
            AvatarCircle(imageUrl: userVM.avatar, size: 50)

            VStack (alignment: .leading, spacing: 4) {
                HStack (spacing: 4) {
                    Text(userVM.username)
                        .font(.body)
                        .fontWeight(.semibold)
                        .foregroundColor(Color(UIColor.appColor(.textPrimary)))
                    
                }
                HStack (spacing: 4) {
                    Text(userVM.information)
                        .font(.footnote)
                        .foregroundColor(.gray)
                    
                }
            }
            
            Spacer()
        }
        .contentShape(Rectangle())
        .padding(.vertical, 4)
    }
}

struct FollowCard_Previews: PreviewProvider {
    static var previews: some View {
        FollowCard(userVM: UserViewModel(value: userExample))
    }
}
