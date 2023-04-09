 

import SwiftUI

struct EditProfileView: View {
    @Binding var name: String
    @Binding var username: String
    @Binding var bio: String
    
    var body: some View {
        VStack(spacing: 16) {
            Image("")
                .frame(width: 100, height: 100, alignment: .center)
                .background(Color.red)
                .cornerRadius(50)
                .padding(.top, 16)
            
            customTextField(label: LocalizedText.profile.editProfile.NAME, binding: $name)
            customTextField(label: LocalizedText.registration.registerWithEmail.username, binding: $username)
            customTextField(label: LocalizedText.profile.editProfile.BIO, binding: $bio, isEditor: true)
                
            Spacer()
        }
        .padding(.horizontal, 16)
    }
    
    private func customTextField(label: String, binding: Binding<String>, isEditor: Bool = false) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.footnote)
                .foregroundColor(.gray)
            if isEditor {
                if #available(iOS 14.0, *) {
                    TextEditor(text: binding)
                        .foregroundColor(.secondary)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                } else {
                    TextField("", text: binding)
                        .frame(minWidth: 200, idealWidth: 200, maxWidth: .infinity, alignment: .center)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
            } else {
                TextField("", text: binding)
                    .frame(minWidth: 200, idealWidth: 200, maxWidth: .infinity, alignment: .center)
                    .foregroundColor(.blue)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
        }
    }
}

struct EditProfileView_Previews: PreviewProvider {
    static var previews: some View {
        EditProfileView(name: .constant("name"), username: .constant("username"), bio: .constant("bio"))
    }
}
