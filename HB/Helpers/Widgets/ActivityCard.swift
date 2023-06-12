 

import SwiftUI

struct ActivityCard: View {
    let activity: ActivityViewModel
    
    var body: some View {
        HStack(alignment: .center, spacing: 8) {
            AvatarCircle(imageUrl: activity.author.thumb, size: 50)

            VStack (alignment: .leading, spacing: 4) {
                HStack (spacing: 4) {
                    Text(activity.author.username)
                        .font(.body)
                        .fontWeight(.semibold)
                        .foregroundColor(Color(UIColor.appColor(.textPrimary)))
                    
                    Spacer()
                    
                    Text(activity.publishDate)
                        .font(.footnote)
                        .foregroundColor(.gray)
                }
                HStack (spacing: 4) {
                    Text(activity.text)
                        .font(.footnote)
                        .foregroundColor(.gray)
                    
                    Spacer()
                    
                    if !activity.isRead {
                        Circle()
                            .frame(width: 8, height: 8, alignment: .center)
                            .cornerRadius(4)
                            .foregroundColor(.blue)
                    }
                }
            }
        }
        .contentShape(Rectangle())
        .padding(.vertical, 4)
    }
}

struct ActivityCard_Previews: PreviewProvider {
    static var previews: some View {
        ActivityCard(activity: ActivityViewModel(value: activityExample))
    }
}
