//
//  PhoneBindingController.swift
//  HotChat
//
//  Created by 风起兮 on 2020/11/6.
//  Copyright © 2020 风起兮. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxCocoa
import RxSwiftUtilities

class PhoneBindingController: UIViewController, IndicatorDisplay {
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    
    @IBOutlet weak var phoneTextField: UITextField!
    
    
    @IBOutlet weak var codeTextField: UITextField!
    
    @IBOutlet weak var codeButton: UIButton!
    
    @IBOutlet weak var codeIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var passwordButton: UIButton!
    
    let accountAPI  = Request<AccountAPI>()
    let userSettingsAPI = Request<UserSettingsAPI>()
    
    @objc dynamic var isCoding: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
    }
    
    func setupView() {
        title = "绑定手机"
        scrollView.contentInset = UIEdgeInsets(top: 50, left: 0, bottom: 0, right: 0)
        
        self.rx.observe(Bool.self, #keyPath(isCoding))
            .debug()
            .compactMap{ !$0! }
            .bind(to: codeIndicator.rx.isHidden)
            .disposed(by: rx.disposeBag)
    }
    
    @IBAction func codeButtonTapped(_ sender: Any) {
        
        let phone = phoneTextField.text ?? ""
        isCoding = true
        codeButton.setTitle("", for: .normal)
        accountAPI.request(.sendCode(phone: phone, type: .phoneBinding), type: ResponseEmpty.self)
            .verifyResponse()
            .subscribe(onSuccess: { [weak self] _ in
                self?.isCoding = false
                self?.startCountdown()
            }, onError: { [weak self] error in
                self?.isCoding = false
                self?.codeButton.setTitle("获取", for: .normal)
                self?.show(error.localizedDescription)
            })
            .disposed(by: rx.disposeBag)
        
    }
    
    
    @IBAction func passwordButtonTapped(_ sender: Any) {
        
        passwordButton.isSelected = !passwordButton.isSelected
        passwordTextField.isSecureTextEntry = !passwordTextField.isSecureTextEntry
    }
    
    
    func startCountdown() {
        let countdown = Observable<Int>.countdown(60).share(replay: 1)
        
        countdown
            .subscribe(onNext: { [weak self] seconds in
                self?.codeButton.setTitle(seconds.description, for: .normal)
                self?.codeButton.isEnabled = false
            }, onCompleted: { [weak self] in
                self?.codeButton.setTitle("获取", for: .normal)
                self?.codeButton.isEnabled = true
            })
            .disposed(by: rx.disposeBag)
    }
    
    @IBAction func submitButtonTapped(_ sender: Any) {
        
        let phone = phoneTextField.text ?? ""
        
        let code = codeTextField.text ?? ""
        
        let password = passwordTextField.text ?? ""
        
        showIndicator()
        userSettingsAPI.request(.bindPhone(phone: phone, verifyCode: code, password: password.md5()), type: Response<User>.self)
            .verifyResponse()
            .subscribe(onSuccess: { [weak self] response in
                let user = response.data!
                user.token = LoginManager.shared.user!.token
                LoginManager.shared.update(user: user)
                self?.hideIndicator()
                self?.navigationController?.popViewController(animated: true)
            }, onError: { [weak self] error in
                self?.hideIndicator()
                self?.show(error.localizedDescription)
            })
            .disposed(by: rx.disposeBag)
        
        
    }
    

}
