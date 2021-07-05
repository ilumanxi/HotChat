//
//  SignupViewController.swift
//  HotChat
//
//  Created by 风起兮 on 2020/9/8.
//  Copyright © 2020 风起兮. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx
import RxSwiftUtilities
import Moya
import AuthenticationServices

class SignupViewController: UIViewController, IndicatorDisplay {
    
    
    @IBOutlet weak var phoneTextField: UITextField!
    
    @IBOutlet weak var codeTextField: UITextField!
    
    @IBOutlet weak var codeButton: UIButton!
    
    @IBOutlet weak var signUpButton: GradientButton!
    
    
    
    private let requestCode = BehaviorRelay(value: true)
    
    private let timing = BehaviorRelay(value: true)
    
    private var codeActivity: ActivityIndicator!
    
    private let countdownSeconds: Int = 6
    
    static let codeTitle: String = "获取验证码"
    
    @IBOutlet weak var playerView: PlayerView!
    
    @IBOutlet weak var loginProviderStackView: UIStackView!
    
    @IBOutlet weak var loginButton: GradientButton!
    
    
    @IBOutlet weak var stackView: UIStackView!
    
    @IBOutlet weak var toolBar: LegalLiabilityToolBar! {
        didSet {
            toolBar.backgroundColor = .clear
            toolBar.onPushing.delegate(on: self) { (self, _) -> UINavigationController in
                return self.navigationController!
            }
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        navigationBarAlpha = 0
        navigationBarTintColor = UIColor(hexString: "#C5C5C5")
        navigationBarTitleColor = UIColor(hexString: "#C5C5C5")
        
        codeButton.setImage(UIImage(color: UIColor(hexString: "#999999"), size: CGSize(width: 0.6, height: 16)), for: .normal)
        
        stackView.setCustomSpacing(37, after: stackView.arrangedSubviews[1])
        
        loginButton.colors = [UIColor(hexString: "#FF3F3F").withAlphaComponent(0.6), UIColor(hexString: "#FF6A2F").withAlphaComponent(0.5)]
        
        [phoneTextField, codeTextField].forEach { textFiled in
            textFiled?.attributedPlaceholder = NSAttributedString(string: textFiled?.placeholder ?? "", attributes: [NSAttributedString.Key.foregroundColor : UIColor(hexString: "#C5C5C5")])
        }
        
        title = "手机登录"
        
        setupPlayer()
        
        if #available(iOS 13.0, *) {
            setupProviderLoginView()
        }
        
        let viewModel = SignupViewModel(
            input: (
                phone: phoneTextField.rx.text.orEmpty.asDriver(),
                code: codeTextField.rx.text.orEmpty.asDriver(),
                codeTaps: codeButton.rx.tap.asSignal(),
                signUpTaps: signUpButton.rx.tap.asSignal()
            ),
            dependency: (
                API: SignupDefaultAPI.share,
                validationService: DefaultValidationService.share,
                wireframe: self
            )
        )
        
        viewModel.coding
            .drive(onNext: { [weak self] isLoading in
                if isLoading {
                    self?.codeButton.showLoader()
                }
                else {
                    self?.codeButton.hideLoader()
                }
            })
            .disposed(by: rx.disposeBag)
        
        viewModel.countdowning
            .map { $0.description }
            .drive(codeButton.rx.title(for: .normal))
            .disposed(by: rx.disposeBag)
        
        viewModel.countdown
            .drive(onNext: { [weak self] _ in
                self?.codeButton.setTitle(Self.codeTitle, for: .normal)
            })
            .disposed(by: rx.disposeBag)
        
        viewModel.countdownEnabled
            .drive(onNext: { _ in
            })
            .disposed(by: rx.disposeBag)
        
        viewModel.codeEnabled
            .drive(onNext: { [weak self] isEnabled in
                self?.codeButton.isEnabled = isEnabled
            })
            .disposed(by: rx.disposeBag)
        
        viewModel.code
            .drive(onNext: { isSuccessed in
            })
            .disposed(by: rx.disposeBag)
        

//        viewModel.signingUp
//            .toggle()
//            .drive(signUpActivityIndicatorView.rx.isHidden)
//            .disposed(by: rx.disposeBag)
        
        viewModel.signupEnabled
            .drive(onNext: { [weak self] isEnabled in
                self?.signUpButton.isEnabled = isEnabled
                if isEnabled {
                    self?.signUpButton.colors = [UIColor(hexString: "#FF3F3F").withAlphaComponent(0.6), UIColor(hexString: "#FF6A2F").withAlphaComponent(0.5)]
                }
                else {
                    self?.signUpButton.colors = [.disabledGray.withAlphaComponent(0.5), .disabledGray.withAlphaComponent(0.5)]
                }
            })
            .disposed(by: rx.disposeBag)
        
         viewModel.signedUp
            .drive(onNext: {  isSucceed in
            })
            .disposed(by: rx.disposeBag)
    }
    
    
    @IBAction func editingDidEnd(_ sender: UITextField) {
        sender.endEditing(true)
    }
    
    private func setupPlayer() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback)
            try AVAudioSession.sharedInstance().setActive(true, options: [])
        } catch let e {
            print(e)
        }
        
        let url = Bundle.main.url(forResource: "login", withExtension: "mov")!
        let player = AVPlayer(url: url)
        playerView.player = player
        playerView.playerLayer.videoGravity = .resizeAspectFill
        player.play()
        
        NotificationCenter.default.addObserver(self, selector: #selector(loopPlay), name: .AVPlayerItemDidPlayToEndTime, object: playerView.player?.currentItem)
        NotificationCenter.default.addObserver(self, selector: #selector(continuePlay), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(pause), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
    
    
    @objc func continuePlay() {
        self.playerView.player?.play()
    }
    
    @objc func pause() {
        self.playerView.player?.pause()
    }
    
    @objc func loopPlay() {
        playerView.player?.seek(to: .zero)
        playerView.player?.play()
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
}



extension SignupViewController {
    
    /// - Tag: add_appleid_button

    @available(iOS 13.0, *)
    func setupProviderLoginView() {
        let authorizationButton = ASAuthorizationAppleIDButton(type: .signIn, style: .black)
        authorizationButton.translatesAutoresizingMaskIntoConstraints = false
        authorizationButton.cornerRadius = 45.0 / 2
        authorizationButton.addTarget(self, action: #selector(handleAuthorizationAppleIDButtonPress), for: .touchUpInside)

        self.loginProviderStackView.insertArrangedSubview(authorizationButton, at: 0)
        authorizationButton.heightAnchor.constraint(equalToConstant: 45).isActive = true
        authorizationButton.widthAnchor.constraint(equalToConstant: 45).isActive = true
        
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
extension SignupViewController: ASAuthorizationControllerDelegate {
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
extension SignupViewController: ASAuthorizationControllerPresentationContextProviding {
/// - Tag: provide_presentation_anchor
func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
    return self.view.window!
}
}


extension ObservableType where Element : RxAbstractInteger {

    public static func countdown(_ seconds: Element, scheduler: RxSwift.SchedulerType = RxSwift.MainScheduler.instance) -> RxSwift.Observable<Self.Element> {
        
        if seconds == 0 {
            return .empty()
        }
        
        return timer(.milliseconds(0), period: .seconds(1), scheduler: scheduler)
            .map{
                seconds - $0
            }
            .take(Int(seconds + 1))
    }
}
