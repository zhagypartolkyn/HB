 

import SwiftUI

struct HomeTabBar: View {
    @Binding var isFirstActive: Bool
    @Binding var firstTitle: String
    @State var secondTitle: String
    
    var body: some View {
        HStack(spacing: 0) {
            button(title: firstTitle, isActive: isFirstActive)
            button(title: secondTitle, isActive: !isFirstActive)
        }
        .frame(maxWidth: .infinity)
        .padding(.top)
        .background(Color(UIColor.systemBackground))
    }
    
    private func button(title: String, isActive: Bool) -> some View {
        Button {
            if !isActive {
                isFirstActive.toggle()
            }
        } label: {
            VStack {
                Text(title)
                    .font(.body)
                    .fontWeight(.semibold)
                    .foregroundColor(isActive ? Color(red: 142/255, green: 41/255, blue: 18/255) : .gray)
                Rectangle()
                    .frame(height: 2)
                    .foregroundColor(isActive ?Color(red: 142/255, green: 41/255, blue: 18/255) : .clear)

            }
        }.frame(maxWidth: .infinity)
    }
}

struct HomeTabBar_Previews: PreviewProvider {
    static var previews: some View {
        HomeTabBar(isFirstActive: .constant(false), firstTitle: .constant("First"), secondTitle: "Second")
    }
}
