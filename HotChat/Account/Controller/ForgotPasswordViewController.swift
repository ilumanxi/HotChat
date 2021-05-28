//
//  ForgotPasswordViewController.swift
//  HotChat
//
//  Created by 风起兮 on 2020/9/17.
//  Copyright © 2020 风起兮. All rights reserved.
//

import UIKit

class ForgotPasswordViewController: LegalLiabilityViewController, IndicatorDisplay {
    
    
    @IBOutlet weak var phoneTextField: UITextField!
    
    @IBOutlet weak var codeTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var repeatedPasswordTextField: UITextField!
    
    
    @IBOutlet weak var codeActivityIndicatorView: UIActivityIndicatorView!
    
    @IBOutlet weak var resetActivityIndicatorView: UIActivityIndicatorView!
    
    @IBOutlet weak var codeButton: GradientButton!
    
    @IBOutlet weak var resetButton: GradientButton!
    
    static let codeTitle: String = "获取"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let viewModel = ForgotPasswordViewModel(
            input: (
                phone: phoneTextField.rx.text.orEmpty.asDriver(),
                password: passwordTextField.rx.text.orEmpty.asDriver(),
                repeatedPassword: repeatedPasswordTextField.rx.text.orEmpty.asDriver(),
                code: codeTextField.rx.text.orEmpty.asDriver(),
                codeTaps: codeButton.rx.tap.asSignal(),
                resetTaps: resetButton.rx.tap.asSignal()
            ),
            dependency: (
                API: ForgotPasswordDefaultAPI.share,
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
                self?.codeButton.colorsString = isEnabled ? "#FF6A2F,#FF3F3F" : "#BDBDBD,#BDBDBD"
            })
            .disposed(by: rx.disposeBag)
        
        viewModel.code
            .drive(onNext: { isSuccessed in
            })
            .disposed(by: rx.disposeBag)
        

        viewModel.reseting
            .toggle()
            .drive(resetActivityIndicatorView.rx.isHidden)
            .disposed(by: rx.disposeBag)
        
        viewModel.resetEnabled
            .drive(onNext: { [weak self] isEnabled in
                self?.resetButton.isEnabled = isEnabled
                
                self?.resetButton.colorsString = isEnabled ? "#FF6A2F,#FF3F3F" : "#BDBDBD,#BDBDBD"
            })
            .disposed(by: rx.disposeBag)
        
         viewModel.reseted
            .drive(onNext: { [weak self] isSuccessed in
                if isSuccessed {
                    self?.performSegue(withIdentifier: "ResetPasswordViewController", sender: nil)
                }
            })
            .disposed(by: rx.disposeBag)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
