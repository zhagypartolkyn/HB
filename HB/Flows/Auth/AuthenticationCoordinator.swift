 
        
import UIKit

class AuthenticationCoordinator : BaseCoordinator, SharedCoordinatorProtocol {

    // MARK: - Start
    override func start() {
        navigateOnboarding()
    }
    
    // MARK: - Onboarding
    func navigateOnboarding() {
        let vm = OnboardingViewModel()
        let vc = OnboardingViewController(viewModel: vm)
        
        vm.navigateSign = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.navigateSign()
        }
        
        navigationController.pushViewController(vc, animated: true)
    }
    
    // MARK: - Sign Up
    private func navigateSign() {
        let vm = SignViewModel()
        let vc = SignViewController(viewModel: vm)
        
        vm.navigateSignEmail = { [weak self] (isSignIn) in
            guard let strongSelf = self else { return }
            strongSelf.navigateSignUpEmail(isSignIn: isSignIn)
        }
        
        vm.navigateSignPhone = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.navigateSignPhone()
        }
        
        vm.navigateSignUp = { [weak self] (user) in
            guard let strongSelf = self else { return }
            strongSelf.navigateSignUp(user: user)
        }
        
        vm.navigateRoot = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.isCompleted?()
        }
        
        navigationController.pushViewController(vc, animated: true)
    }
    
    // MARK: - Sign Phone
    private func navigateSignPhone() {
        let vm = SignPhoneViewModel()
        let vc = SignPhoneViewController(viewModel: vm)
        
        vm.navigateVerifyPhone = { [weak self] (phoneNumber) in
            guard let strongSelf = self else { return }
            strongSelf.navigateSignPhoneVerify(phoneNumber: phoneNumber)
        }
        
        vm.navigateBack = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.navigationController.popViewController(animated: true)
        }
        
        navigationController.pushViewController(vc, animated: true)
    }
    
    // MARK: - SignUp Phone Verify
    private func navigateSignPhoneVerify(phoneNumber: String) {
        let vm = SignViewModel()
        let vc = VerifyPhoneViewController(viewModel: vm, phoneNumber: phoneNumber)
        
        vm.navigateSignUp = { [weak self] (user) in
            guard let strongSelf = self else { return }
            strongSelf.navigateSignUp(user: user)
        }
        
        vm.navigateRoot = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.isCompleted?()
        }
        
        vm.navigateBack = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.navigationController.popViewController(animated: true)
        }
        
        navigationController.pushViewController(vc, animated: true)
    }
    
    // MARK: - Sign Up
    private func navigateSignUp(user: User) {
        let vm = SignUpViewModel(user: user)
        let vc = SignUpViewController(viewModel: vm)
        
        vm.navigateRoot = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.isCompleted?()
        }
        
        navigationController.pushViewController(vc, animated: true)
    }
    
    // MARK: - Onboarding
    func navigateSignUpEmail(isSignIn: Bool) {
        let vm = SignViewModel()
        let vc = SignEmailViewController(viewModel: vm, isSignIn: isSignIn)
        
        vm.navigateSignUp = { [weak self] (user) in
            guard let strongSelf = self else { return }
            strongSelf.navigateSignUp(user: user)
        }
        
        vm.navigateRoot = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.navigationController.dismiss(animated: true)
            strongSelf.isCompleted?()
        }
        
        vm.navigateBack = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.navigationController.popViewController(animated: true)
        }
        
        navigationController.pushViewController(vc, animated: true)
    }
    
}
