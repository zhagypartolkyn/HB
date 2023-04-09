 

import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: SettingsViewModel
    
    var body: some View {
        NavigationView {
            VStack(alignment: .center, spacing: 0) {
                Spacer().frame(height: 20)
                
                Form {
                    Section(header: Text("Общие")) {
                        FormRowSwitchView(status: $viewModel.push, icon: "bell", color: Color.orange, text: "Пуш уведомления")
                    }
                    .padding(.vertical, 3)
                    
                    Section(header: Text("Поддержка")) {
                        FormRowLinkView(icon: "envelope.open", color: Color.green, text: "https://t.me/tony_wavy", link: "https://t.me/tony_wavy")
                        FormRowLinkView(icon: "globe", color: Color.pink, text: "Пользовательское соглашение", link: "https://www.notion.so/04ed16da2699424e8bc773e81e4f72a9")
                        FormRowLinkView(icon: "globe", color: Color.pink, text: "Политика конфиденциальности", link: "https://www.notion.so/979d17338a94480f8b6a25bc966beeac")
                    }
                    .padding(.vertical, 3)
                    
//                    Section(header: Text("Ссылки")) {
//                        FormRowLinkView(icon: "globe", color: Color.pink, text: "Веб-сайт", link: "https://wanty.io")
//                        FormRowLinkView(icon: "link", color: Color.blue, text: "Твиттер", link: "https://wanty.io")
//                        FormRowLinkView(icon: "link", color: Color.blue, text: "Instagram", link: "https://wanty.io")
//                        FormRowLinkView(icon: "play.rectangle", color: Color.green, text: "YouTube", link: "https://wanty.io")
//                    }
//                    .padding(.vertical, 3)
                    
                    Section(header: Text("Информация о приложении")) {
                        FormRowStaticView(icon: "gear", firstText: "Приложение", secondText: "Hobby-Buddy")
                        FormRowStaticView(icon: "keyboard", firstText: "Создатели", secondText: "Totally Spice")
                        FormRowStaticView(icon: "flag", firstText: "Версии", secondText: "0.0.7")
                    }
                    .padding(.vertical, 3)
                    
                    Section(header: Text("Еще")) {
                        FormRowButtonView(icon: "arrow.left.circle", color: Color.red, text: "Выйти") {
                            viewModel.logOut()
                        }
                    }
                    .padding(.vertical, 3)
                }
                
                Text("Copyright @ All rights reserved.\n With ♡ from Almaty")
                    .multilineTextAlignment(.center)
                    .font(.footnote)
                    .padding(.top, 6)
                    .padding(.bottom, 8)
                    .foregroundColor(.secondary)
            }
            .background(Color("ColorBackground").edgesIgnoringSafeArea(.all))
            .navigationBarTitle("Settings", displayMode: .inline)
            .navigationBarItems(trailing: Button(action:{
                viewModel.navigateBack?()
            }) {
                Image(systemName: "xmark").frame(width: 44, height: 44, alignment: .center)
            })
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(viewModel: SettingsViewModel())
    }
}
