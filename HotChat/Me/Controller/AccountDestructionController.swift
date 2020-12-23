//
//  AccountDestructionController.swift
//  HotChat
//
//  Created by 风起兮 on 2020/12/23.
//  Copyright © 2020 风起兮. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa


class TextFiled: UITextField {
    
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        
        return super.textRect(forBounds: bounds).insetBy(dx: 12, dy: 0)
    }
    
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return super.placeholderRect(forBounds: bounds).insetBy(dx: 12, dy: 0)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return super.editingRect(forBounds: bounds).insetBy(dx: 12, dy: 0)
    }
}

extension UIButton {
    
    func showLoader() {
        
        if subviews.contains(where: { $0 is UIActivityIndicatorView }) {
            return
        }
        isUserInteractionEnabled = false
        subviews.forEach {
            $0.alpha = 0
        }
        
        let indicator: UIActivityIndicatorView = UIActivityIndicatorView(style: .white)
        indicator.sizeToFit()
        addSubview(indicator)
        
        let size = indicator.bounds.size
        indicator.frame = CGRect(
            x: (bounds.width - size.width) / 2.0,
            y: (bounds.height - size.height) / 2.0,
            width: size.width,
            height: size.height
        )
        
        indicator.startAnimating()
    }
    
    
    func hideLoader()  {
        guard let indicator = subviews.first(where: { $0 is UIActivityIndicatorView }) as? UIActivityIndicatorView  else {
            return
        }
        isUserInteractionEnabled = true
        indicator.stopAnimating()
        indicator.removeFromSuperview()
        subviews.forEach {
            $0.alpha = 1
        }
    }
}

class AccountDestructionController: UIViewController, IndicatorDisplay {
    
    
    enum Style {
        case password
        case  code
    }
    
    let API = Request<LogoutAPI>()
    
    let accountAPI = Request<AccountAPI>()
    
    @IBOutlet weak var textLabel: UILabel!
    
    @IBOutlet weak var textField: UITextField!
    
    @IBOutlet weak var button: UIButton!
    
    private lazy var codeButton: UIButton = {
        let button = UIButton(type: .custom)
        button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
        button.setTitle("获取", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14)
        button.backgroundColor = .theme
        button.layer.cornerRadius = 4
        button.frame = CGRect(x: 0, y: 0, width: 48, height: 30)
        return button
    }()
    
    let style: Style
    
    init(style: Style) {
        self.style = style
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupViews()
        bindingAction()
    }
    
    func bindingAction() {
        textField.rx.text.orEmpty
            .map{ $0.isEmpty }
            .subscribe(onNext: { [unowned self] isEmpty in
                self.button.backgroundColor = isEmpty ? .disabledGray : .theme
            })
            .disposed(by: rx.disposeBag)
        
        
        codeButton.rx.tap
            .do(onNext: { [unowned self] _ in
                self.codeButton.showLoader()
            })
            .flatMapLatest {  [unowned self] _ in
                return self.accountAPI.request(.sendCode(phone: LoginManager.shared.user?.phone ?? "", type: CodeType.accountDestroy), type: ResponseEmpty.self).verifyResponse()
            }
            .verifyResponse()
            .subscribe(onNext: { [unowned self] _ in
                self.codeButton.hideLoader()
                self.startCountdown()
            }, onError: { [unowned self] error in
                self.codeButton.hideLoader()
                self.show(error.localizedDescription)
            })
            .disposed(by: rx.disposeBag)
    }
    
    func startCountdown() {
        let countdown =  Observable<Int>.countdown(60).share(replay: 1)
        
        countdown
            .subscribe(
                onNext: { [unowned self] seconds in
                    self.codeButton.isEnabled = false
                    self.codeButton.setTitle("\(seconds)s", for: .disabled)
                    self.codeButton.backgroundColor = .disabledGray
                },
                onCompleted: {
                    self.codeButton.isEnabled = true
                    self.codeButton.setTitle("获取", for: .normal)
                    self.codeButton.backgroundColor = .theme
            })
            .disposed(by: rx.disposeBag)
    }

    func setupViews() {
        
        title = "账号注销"
        
        textField.setValue(NSNumber(value: 120), forKey: "labelOffset")
        
        switch style {
        case .password:
            textLabel.text = "验证您的登录密码"
            textField.placeholder = "请输入密码"
            textField.isSecureTextEntry = true
            button.setTitle("下一步", for: .normal)
        case .code:
            textLabel.text = "请输入绑定手机号\(LoginManager.shared.user?.phone.privacyPhone ?? "")接收的验证码"
            textField.placeholder = "请输入验证码"
            textField.setValue(NSValue(cgSize: CGSize(width: -20, height: 0)), forKey: "rightViewOffset")
            textField.rightView = codeButton
            textField.rightViewMode = .always
            button.setTitle("确定注销", for: .normal)
        }
       
    }


    
    @IBAction func actionButtonTapped(_ sender: Any) {
        
        switch style {
        case .password:
            checkPassword()
        case .code:
            checkCode()
        }
    }
    
    func checkPassword() {
        
        API.request(.checkPassword(password: textField.text ?? ""), type: ResponseEmpty.self)
            .verifyResponse()
            .subscribe(onSuccess: { [unowned self] _ in
                let vc = AccountDestructionController(style: .code)
                self.navigationController?.pushViewController(vc, animated: true)
            }, onError: { [unowned self] error in
                self.show(error.localizedDescription)
            })
            .disposed(by: rx.disposeBag)
    }
    
    
    func checkCode() {
        API.request(.checkCodes(verifyCode: textField.text ?? ""), type: ResponseEmpty.self)
            .verifyResponse()
            .subscribe(onSuccess: { [unowned self] response in
                UIApplication.shared.keyWindow?.setLoginViewController()
                self.showMessageOnWindow(response.msg)
            }, onError: { [unowned self] error in
                self.show(error.localizedDescription)
            })
            .disposed(by: rx.disposeBag)
    }
    
}
