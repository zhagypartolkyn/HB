

import SwiftUI

struct SignView: View {
    @ObservedObject var viewModel: SignViewModel
    var vc: UIViewController
    
    var body: some View {
        VStack(spacing: 24) {
            logo
                .padding(.top, 64)
            buttons
            signToggleButton
            Spacer()
        }
        .padding(.horizontal, 32)
        .navigationBarHidden(true)
    }
    
    // MARK: - Widgets
    private var logo: some View {
        VStack(spacing: 8) {
            Image("logo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 90, height: 90, alignment: .center)
                .cornerRadius(45, style: .circular)
//            Image("logo_title")
            Text(viewModel.isSignIn ? LocalizedText.registration.logInWith : LocalizedText.registration.signUpWith)
                .foregroundColor(.gray)
                .padding(.top)
        }
    }
    
    private var buttons: some View {
        VStack(spacing: 16) {
            
//            signButton(title: LocalizedText.registration.google, imageName: "google", action: {
//                viewModel.googleButtonActionHelper(vc: vc)
//            })
            
            SignInWithApple()
                .frame(minWidth: 200, idealWidth: 200, maxWidth: .infinity, minHeight: 50, idealHeight: 50, maxHeight: 50, alignment: .leading)
                .onTapGesture {
                    viewModel.appleButtonActionHelper()
                }
            
//            signButton(title: LocalizedText.registration.phone, imageName: "phone", system: true, action: {
//                viewModel.navigateSignPhone?()
//            })
            
            signButton(title: viewModel.isSignIn ? LocalizedText.logInPage.email.emailOrUsername : LocalizedText.registration.email,
                       imageName: "envelope", system: true, action: {
                viewModel.navigateSignEmail?(viewModel.isSignIn)
            })
        }
    }
    
    private func signButton(
        title: String,
        imageName: String,
        system: Bool = false,
        action: @escaping () -> Void) -> some View {
        
        return Button(action: action, label: {
            HStack(spacing: 24) {
                if system {
                    Image(systemName: imageName)
                        .font(Font.headline.weight(.bold))
                        .frame(width: 34, height: 34, alignment: .center)
                        .background(Color.white)
                        .cornerRadius(10)
                        .padding(.leading, 8)
                } else {
                    Image(imageName)
                        .frame(width: 34, height: 34, alignment: .center)
                        .background(Color.white)
                        .cornerRadius(10)
                        .padding(.leading, 8)
                }
                Text(title)
                    .foregroundColor(Color.white)
                    .font(.subheadline).bold()
            }
            .frame(minWidth: 200, idealWidth: 200, maxWidth: .infinity, minHeight: 50, idealHeight: 50, maxHeight: 50, alignment: .leading)
            .background(Color(red: 142/255, green: 41/255, blue: 18/255))
            .cornerRadius(14)
        })
    }
    
    private var signToggleButton: some View {
        Button(action: {
            viewModel.isSignIn.toggle()
        }, label: {
            HStack(spacing: 4) {
                Text(viewModel.isSignIn ? LocalizedText.registration.dontHaveAccount : LocalizedText.registration.haveAccount)
                    .foregroundColor(.gray)
                Text(viewModel.isSignIn ? LocalizedText.General.signUp : LocalizedText.registration.logIn)
                    .foregroundColor(Color(red: 142/255, green: 41/255, blue: 18/255))
                    .bold()
            }
            .font(.subheadline)
        })
    }
    
}

struct SignViewNew_Previews: PreviewProvider {
    static var previews: some View {
        let vm = SignViewModel()
        return SignView(viewModel: vm, vc: SignViewController(viewModel: vm))
    }
}

import AuthenticationServices
struct SignInWithApple: UIViewRepresentable {
    func makeUIView(context: Context) -> ASAuthorizationAppleIDButton {
        let button = ASAuthorizationAppleIDButton(type: .signIn, style: UITraitCollection.current.userInterfaceStyle == .dark ? .white : .black)
        button.cornerRadius = 14
        return button
    }
    
    func updateUIView(_ uiView: ASAuthorizationAppleIDButton, context: Context) {
    }
}
