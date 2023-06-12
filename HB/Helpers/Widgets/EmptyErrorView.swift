 

import SwiftUI

struct EmptyErrorView: View {
    var title: String
    
    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            Spacer()
            Image(uiImage: Icons.Error.city!)
                .resizable()
                .aspectRatio(contentMode: .fit)
            Text(title)
                .font(.body)
                .fontWeight(.semibold)
                .lineLimit(nil)
            Spacer()
        }
        .padding(.all, 32)
    }
}

struct EmptyErrorView_Previews: PreviewProvider {
    static var previews: some View {
        EmptyErrorView(title: "В этом городе\nпока нет желаний")
    }
}
