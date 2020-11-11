//
//  PhoneSigninViewController.swift
//  HotChat
//
//  Created by 风起兮 on 2020/9/7.
//  Copyright © 2020 风起兮. All rights reserved.
//

import UIKit
import HBDNavigationBar
import RxSwift
import RxCocoa



class PhoneSigninViewController: LegalLiabilityViewController, IndicatorDisplay {
    
    @IBOutlet weak var phoneTextField: UITextField!
    
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    
    @IBOutlet weak var signInButton: UIButton!
    
    
    @IBOutlet weak var signInActivityIndicatorView: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    NotificationCenter.default.rx.notification(.userDidResetPassword)
        .subscribe(onNext: { [weak self] _ in
            guard let self = self else {
                return
            }
            self.navigationController?.popToViewController(self, animated: true)
        })
        .disposed(by: rx.disposeBag)
        
        let viewModel = SigninViewModel(
            input: (
                phone: phoneTextField.rx.text.orEmpty.asDriver(),
                password: passwordTextField.rx.text.orEmpty.asDriver(),
                signInTaps: signInButton.rx.tap.asSignal()
            ),
            dependency: (
                API: SigninDefaultAPI.share,
                validationService: DefaultValidationService.share,
                wireframe: self
            )
        )
        
        viewModel.signingIn
            .toggle()
            .drive(signInActivityIndicatorView.rx.isHidden)
            .disposed(by: rx.disposeBag)
        
        viewModel.signinEnabled
            .drive(onNext: { [weak self] isEnabled in
                self?.signInButton.isEnabled = isEnabled
                self?.signInButton.backgroundColor = isEnabled ? .theme : .disabledGray
            })
            .disposed(by: rx.disposeBag)
        
        viewModel.signedIn
            .drive(onNext: { isSignin in
                Log.print(isSignin)
            })
            .disposed(by: rx.disposeBag)
        
    }
}


extension SharedSequenceConvertibleType where Self.Element == Bool {
    
    func toggle() -> RxCocoa.SharedSequence<Self.SharingStrategy, Element> {
        return map { !$0 }
    }

}


