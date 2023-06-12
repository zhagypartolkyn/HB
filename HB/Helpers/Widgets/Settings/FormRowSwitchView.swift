 
 

import SwiftUI

struct FormRowSwitchView: View {
    @Binding var status: Bool
    var icon: String
    var color: Color
    var text: String
    
    var body: some View {
        HStack {
            ZStack {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(color)
                Image(systemName: icon)
                    .imageScale(.large)
                    .foregroundColor(.white)
            }
            .frame(width: 36, height: 36, alignment: .center)
            
            Toggle(isOn: $status, label: {
                Text(text).foregroundColor(.gray)
            })
        }
    }
}

struct FormRowSwitchView_Previews: PreviewProvider {
    static var previews: some View {
        FormRowSwitchView(status: .constant(true),icon: "globe", color: Color.pink, text: "Website")
            .previewLayout(.fixed(width: 375, height: 60))
            .padding()
    }
}
