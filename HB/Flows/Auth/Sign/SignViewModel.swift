

import UIKit
import FirebaseAuth
import GoogleSignIn
import FirebaseFirestore
import CryptoKit
import FBSDKLoginKit
import AuthenticationServices

class SignViewModel: NSObject, ObservableObject {
    
    // MARK: - Binding
    var navigateRoot: (() -> Void)?
    var navigateSignUp: ((_ userVM: User) -> Void)?
    var navigateSignEmail: ((_ isSignIn: Bool) -> Void)?
    var navigateSignPhone: (() -> Void)?
    var navigateBack: (() -> Void)?
    var showHUD: ((_ type: AlertType, _ text: String) -> Void)?
    
    // MARK: - Variables
    @Published var isSignIn: Bool = false
    
    private var user = User(following: [], counters: UserCounters(), avatar: UserAvatar(),
                            location: Location(), status: UserStatus(socialCorrect: true), ban: UserBan(),
                            online: UserOnline(), accounts: UserAccounts(),
                            date: UserDate(publish: Timestamp(date: Date()), update: Timestamp(date: Date())))
    
    fileprivate var currentNonce: String?
    
    enum SignType {
        case facebook
        case google
        case apple
        case phone
        case email
    }
    
    func sign(credentials: AuthCredential, type: SignType) {
        showHUD?(.loading, "")
        Auth.auth().signIn(with: credentials) { (authResult, error) in
            if let error = error {
                self.showHUD?(.error, error.localizedDescription)
                return
            }
            guard let authData = authResult else { return }
            
            DB.fetchViewModel(model: User.self, viewModel: UserViewModel.self, ref: Ref.Fire.user(uid: authData.user.uid)) { [weak self] (result) in
                guard let strongSelf = self else { return }
                switch result {
                case .success(let userVM):
                    if userVM.isRegistered {
                        strongSelf.showHUD?(.dismiss, "")
                        strongSelf.navigateRoot?()
                    } else {
                        strongSelf.signUp(type: type, authData: authData)
                    }
                case .failure(_):
                    strongSelf.signUp(type: type, authData: authData)
                }
            }
        }
    }
    
    private func signUp(type: SignType, authData: AuthDataResult) {
        user.uid = authData.user.uid
        
        switch type {
        case .facebook:
            user.accounts.facebook = true
        case .google:
            guard let sharedInstance = GIDSignIn.sharedInstance(), let googleUser = sharedInstance.currentUser else { return }
            user.accounts.google = true
            user.name = googleUser.profile.name
            user.email = googleUser.profile.email
        case .apple:
            user.accounts.apple = true
            user.name = authData.user.displayName ?? ""
            user.email = authData.user.email ?? ""
        case .phone:
            guard let phoneNumber = authData.user.phoneNumber else { return }
            user.accounts.phone = true
            user.phone = phoneNumber
        case .email:
            user.accounts.password = true
            user.email = authData.user.email ?? ""
        }
        showHUD?(.dismiss, "")
        navigateSignUp?(user)
    }
    
    // Sign Email
    public func signEmailOrUsername(emailOrUsername: String, password: String, isSignIn: Bool) {
        showHUD?(.loading, "")
        if isSignIn {
            if emailOrUsername.isValidEmail {
                signInWithEmail(emailOrUsername: emailOrUsername, password: password, isSignIn: isSignIn)
            } else if emailOrUsername.isValidUsername {
                getEmailBy(emailOrUsername) { (email) in
                    self.signInWithEmail(emailOrUsername: email, password: password, isSignIn: isSignIn)
                }
            } else {
                print("signEmailOrUsername error")
            }
        } else {
            signUpWithEmail(emailOrUsername: emailOrUsername, password: password, isSignIn: isSignIn)
        }
    }
    
    private func getEmailBy(_ username: String, completion: @escaping((String) -> ())) {
        DB.fetchModels(model: User.self, query: Queries.User.username(username)) { [self] (result) in
            switch result {
            case .success((let users, _, _)): completion(users[0].email!)
            case .failure(let error): self.showHUD?(.error, error.localizedDescription)
            }
        }
    }
    
    private func signInWithEmail(emailOrUsername: String, password: String, isSignIn: Bool) {
        Auth.auth().signIn(withEmail: emailOrUsername, password: password) { [self] (authResult, error) in
            if let error = error {
                self.showHUD?(.error, error.localizedDescription)
                return
            }
            guard let authData = authResult else { return }
            
            DB.fetchViewModel(model: User.self, viewModel: UserViewModel.self, ref: Ref.Fire.user(uid: authData.user.uid)) { (result) in
                switch result {
                case .success(let userVM):
                    if userVM.isRegistered {
                        navigateRoot?()
                    } else {
                        signUp(type: .email, authData: authData)
                    }
                case .failure(_):
                    signUp(type: .email, authData: authData)
                }
            }
            
            self.showHUD?(.dismiss, "")
        }
    }
    
    private func signUpWithEmail(emailOrUsername: String, password: String, isSignIn: Bool) {
        Auth.auth().createUser(withEmail: emailOrUsername, password: password) { [self] (authResult, error) in
            if let error = error {
                showHUD?(.error, error.localizedDescription)
                return
            }
            guard let authData = authResult else { return }
            signUp(type: .email, authData: authData)
        }
    }
    
}

// MARK: - Facebook
extension SignViewModel {
    func facebookButtonActionHelper() {
        LoginManager().logIn(permissions: [], from: nil) { (result, error) in
            if let error = error {
                self.showHUD?(.error, error.localizedDescription)
                return
            }
            if let result = result, result.isCancelled {
                self.showHUD?(.dismiss, "")
                return
            }
            let credential = FacebookAuthProvider.credential(withAccessToken: AccessToken.current!.tokenString)
            self.sign(credentials: credential, type: .facebook)
        }
    }
}

// MARK: - Google
extension SignViewModel: GIDSignInDelegate {
    func googleButtonActionHelper(vc: UIViewController) {
        GIDSignIn.sharedInstance()?.presentingViewController = vc
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance()?.signIn()
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        self.showHUD?(.loading, "")
        if let _ = error {
            self.showHUD?(.dismiss, "")
            return
        }
        guard let auth = user.authentication else { return }
        let credentials = GoogleAuthProvider.credential(withIDToken: auth.idToken, accessToken: auth.accessToken)
        self.sign(credentials: credentials, type: .google)
    }
}

// MARK: - Apple
extension SignViewModel: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    func appleButtonActionHelper() {
        let nonce = randomNonceString()
        currentNonce = nonce
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let nonce = currentNonce else {
                fatalError("Invalid state: A login callback was received, but no login request was sent.")
            }
            guard let appleIDToken = appleIDCredential.identityToken else {
                print("Unable to fetch identity token")
                return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                return
            }
            let credentials = OAuthProvider.credential(withProviderID: "apple.com",
                                                      idToken: idTokenString,
                                                      rawNonce: nonce)
            
            self.sign(credentials: credentials, type: .apple)
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // Handle error.
        print("Sign in with Apple errored: \(error)")
    }
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.appCoordinator.navigationController.presentingViewController?.view.window ?? UIWindow(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
    }
}
