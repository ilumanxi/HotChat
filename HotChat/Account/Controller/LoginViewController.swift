//
//  LoginViewController.swift
//  HotChat
//
//  Created by 风起兮 on 2020/9/7.
//  Copyright © 2020 风起兮. All rights reserved.
//

import UIKit
import ActiveLabel
import AuthenticationServices
import RxSwift
import RxCocoa
import MBProgressHUD

extension Notification.Name {
    
    static let userDidLogin = NSNotification.Name("com.friday.Chat.userDidLogin")
    
    static let userDidLogout = NSNotification.Name("com.friday.Chat.userDidLogout")
    
    static let userDidSignedUp = NSNotification.Name("com.friday.Chat.userDidSignedUp")
    
    static let userDidBanned = NSNotification.Name("com.friday.Chat.userDidBanned")
    
    static let userDidDestroy = NSNotification.Name("com.friday.Chat.userDidDestroy")
    
}

class LoginViewController: UIViewController, IndicatorDisplay {
    
    @IBOutlet weak var loginProviderStackView: UIStackView!
    
    
    @IBOutlet weak var toolBar: LegalLiabilityToolBar! {
        didSet {
            toolBar.onPushing.delegate(on: self) { (self, _) -> UINavigationController in
                return self.navigationController!
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 13.0, *) {
            setupProviderLoginView()
        }
        
        observeAccountState()
        
    }
    
    
    func observeAccountState() {
        
        NotificationCenter.default.rx.notification(.userDidSignedUp)
            .subscribe(onNext: { [weak self] _ in
                let vc = UserInformationViewController.loadFromStoryboard()
                self?.navigationController?.pushViewController(vc, animated: true)
            })
            .disposed(by: rx.disposeBag)
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        if #available(iOS 13.0, *) {
//            performExistingAccountSetupFlows()
//        }
    }
    
    /// - Tag: add_wechat_login
    
    
    @IBAction func weChatDidLogin(_ sender: Any) {
        
        PlatformAuthorization.login(.wechat) { [weak self] _, result in
            switch result {
            case .success(let userIdentifier):
                self?.login(userIdentifier, tokenType: .weChat)
            case .failure(let error):
                Log.print(error)
            }
        }
    }
    
    func login(_ userIdentifier: String, tokenType: TokenType) {
        
        showIndicator("登录中...")
        SigninDefaultAPI.share.signin(userIdentifier, type: tokenType.rawValue)
            .verifyResponse()
            .subscribe(onSuccess:{  [weak self] result in
                Log.print(result)
                self?.hideIndicator()
            }, onError: { [weak self] error in
                self?.hideIndicator()
                self?.show(error)
            })
            .disposed(by: self.rx.disposeBag)
    }
    
    /// - Tag: add_appleid_button
    
    @available(iOS 13.0, *)
    func setupProviderLoginView() {
        let authorizationButton = ASAuthorizationAppleIDButton(type: .signIn, style: .black)
        authorizationButton.translatesAutoresizingMaskIntoConstraints = false
//        authorizationButton.cornerRadius = 25
        authorizationButton.addTarget(self, action: #selector(handleAuthorizationAppleIDButtonPress), for: .touchUpInside)
        self.loginProviderStackView.addArrangedSubview(authorizationButton)
        authorizationButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    // - Tag: perform_appleid_password_request
    /// Prompts the user if an existing iCloud Keychain credential or Apple ID credential is found.
    @available(iOS 13.0, *)
    func performExistingAccountSetupFlows() {
        // Prepare requests for both Apple ID and password providers.
        let requests = [ASAuthorizationAppleIDProvider().createRequest(),
                        ASAuthorizationPasswordProvider().createRequest()]
        
        // Create an authorization controller with the given requests.
        let authorizationController = ASAuthorizationController(authorizationRequests: requests)
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    /// - Tag: perform_appleid_request
    @available(iOS 13.0, *)
    @objc
    func handleAuthorizationAppleIDButtonPress() {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
}

@available(iOS 13.0, *)
extension LoginViewController: ASAuthorizationControllerDelegate {
    /// - Tag: did_complete_authorization
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        switch authorization.credential {
        case let appleIDCredential as ASAuthorizationAppleIDCredential:
            
            // Create an account in your system.
            let userIdentifier = appleIDCredential.user
            // let fullName = appleIDCredential.fullName
            // let email = appleIDCredential.email
            
            // For the purpose of this demo app, store the `userIdentifier` in the keychain.
            self.saveUserInKeychain(userIdentifier)
            
            // For the purpose of this demo app, show the Apple ID credential information in the `ResultViewController`.
//            self.showResultViewController(userIdentifier: userIdentifier, fullName: fullName, email: email)
            login(userIdentifier, tokenType: .apple)
        
        case let passwordCredential as ASPasswordCredential:
        
            // Sign in using an existing iCloud Keychain credential.
            let username = passwordCredential.user
            let password = passwordCredential.password
            
            // For the purpose of this demo app, show the password credential as an alert.
            DispatchQueue.main.async {
                self.showPasswordCredentialAlert(username: username, password: password)
            }
            
        default:
            break
        }
    }
    
    private func saveUserInKeychain(_ userIdentifier: String) {
        do {
            try KeychainItem(service: "com.friday.Chat", account: "userIdentifier").saveItem(userIdentifier)
        } catch {
            print("Unable to save userIdentifier to keychain.")
        }
    }
    
    private func showResultViewController(userIdentifier: String, fullName: PersonNameComponents?, email: String?) {
//        guard let viewController = self.presentingViewController as? ResultViewController
//            else { return }
//
//        DispatchQueue.main.async {
//            viewController.userIdentifierLabel.text = userIdentifier
//            if let givenName = fullName?.givenName {
//                viewController.givenNameLabel.text = givenName
//            }
//            if let familyName = fullName?.familyName {
//                viewController.familyNameLabel.text = familyName
//            }
//            if let email = email {
//                viewController.emailLabel.text = email
//            }
//            self.dismiss(animated: true, completion: nil)
//        }
        
            dismiss(animated: true, completion: nil)
    }
    
    private func showPasswordCredentialAlert(username: String, password: String) {
        let message = "The app has received your selected credential from the keychain. \n\n Username: \(username)\n Password: \(password)"
        let alertController = UIAlertController(title: "Keychain Credential Received",
                                                message: message,
                                                preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    /// - Tag: did_complete_error
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // Handle error.
        debugPrint(error)
    }
}

@available(iOS 13.0, *)
extension LoginViewController: ASAuthorizationControllerPresentationContextProviding {
    /// - Tag: provide_presentation_anchor
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}


extension UIViewController {
    
    func showLoginViewController(_ animated: Bool = true) {
        let storyboard = UIStoryboard(name: "Account", bundle: nil)
        if let loginViewController = storyboard.instantiateInitialViewController() as? UINavigationController {
            loginViewController.modalPresentationStyle = .fullScreen
            self.present(loginViewController, animated: animated, completion: nil)
        }
    }
}

extension UIWindow {
    
    func setLoginViewController() {
        let storyboard = UIStoryboard(name: "Account", bundle: nil)
        if let loginViewController = storyboard.instantiateInitialViewController() as? UINavigationController {
            rootViewController = loginViewController
        }
    }
}
