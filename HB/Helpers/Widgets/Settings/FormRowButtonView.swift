 

import SwiftUI

struct FormRowButtonView: View {
    var icon: String
    var color: Color
    var text: String
    var onTap: (() -> Void)
    
    var body: some View {
        Button(action: {
            onTap()
        }) {
            HStack {
                ZStack {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(color)
                    Image(systemName: icon)
                        .imageScale(.large)
                        .foregroundColor(.white)
                }
                .frame(width: 36, height: 36, alignment: .center)
                
                Text(text)
                    .lineLimit(1)
                    .foregroundColor(.gray)
                
                Spacer()
            }
        }
    }
}

struct FormRowButtonView_Previews: PreviewProvider {
    static var previews: some View {
        FormRowButtonView(icon: "arrow.backward.circle", color: Color.red, text: "Выйти", onTap: {
            
        })
        .previewLayout(.fixed(width: 375, height: 60))
        .padding()
    }
}
