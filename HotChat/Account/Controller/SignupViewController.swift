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

class SignupViewController: LegalLiabilityViewController, IndicatorDisplay {

    @IBOutlet weak var phoneTextField: UITextField!
    
    @IBOutlet weak var codeTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var codeButton: UIButton!
    
    @IBOutlet weak var signUpButton: UIButton!
    
    @IBOutlet weak var codeActivityIndicatorView: UIActivityIndicatorView! 
    
    @IBOutlet weak var signUpActivityIndicatorView: UIActivityIndicatorView!
    
    private let requestCode = BehaviorRelay(value: true)
    
    private let timing = BehaviorRelay(value: true)
    
    private var codeActivity: ActivityIndicator!
    
    private let countdownSeconds: Int = 6
    
    static let codeTitle: String = "获取"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        
        let viewModel = SignupViewModel(
            input: (
                phone: phoneTextField.rx.text.orEmpty.asDriver(),
                password: passwordTextField.rx.text.orEmpty.asDriver(),
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
                self?.codeActivityIndicatorView.isHidden = !isLoading
                let title = isLoading ? "" : Self.codeTitle
                self?.codeButton.setTitle(title, for: .normal)
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
                self?.codeButton.backgroundColor = isEnabled ? .theme : .disabledGray
            })
            .disposed(by: rx.disposeBag)
        
        viewModel.code
            .drive(onNext: { isSuccessed in
            })
            .disposed(by: rx.disposeBag)
        

        viewModel.signingUp
            .toggle()
            .drive(signUpActivityIndicatorView.rx.isHidden)
            .disposed(by: rx.disposeBag)
        
        viewModel.signupEnabled
            .drive(onNext: { [weak self] isEnabled in
                self?.signUpButton.isEnabled = isEnabled
                self?.signUpButton.backgroundColor = isEnabled ? .theme : .disabledGray
            })
            .disposed(by: rx.disposeBag)
        
         viewModel.signedUp
            .drive(onNext: {  isSucceed in
                Log.print("signedUp \(isSucceed)")
            })
            .disposed(by: rx.disposeBag)
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
            .take(Int(seconds))
    }
}
