//
//  InviteViewController.swift
//  HotChat
//
//  Created by 风起兮 on 2020/10/23.
//  Copyright © 2020 风起兮. All rights reserved.
//

import UIKit

class InviteViewController: UIViewController, LoadingStateType, IndicatorDisplay {
    
    var state: LoadingState = .initial {
        didSet {
            showOrHideIndicator(loadingState: state)
        }
    }
    
    @IBOutlet weak var textField: UITextField!
    
    
    @IBOutlet weak var messageLabel: UILabel!
    
    
    @IBOutlet weak var messageImageView: UIImageView!
    
    
    @IBOutlet weak var stackView: UIStackView!
    
    @IBOutlet weak var hintView: UIView!
    
    let userAPI = Request<UserAPI>()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        stackView.isHidden = true
        refreshData()
    }
    
    func refreshData() {
        
        state = .refreshingContent
        
        userAPI.request(.infoInvite, type: Response<[String : Any]>.self)
            .checkResponse()
            .subscribe(onSuccess: { [weak self] response in
                if let phone = response.data?["phone"] as? String, !phone.isEmpty {
                    self?.hintView.isHidden = false
                }
                else {
                    self?.hintView.isHidden = true
                }
                self?.state = .contentLoaded
                
            }, onError: { [weak self] error in
                self?.state = .error
            })
            .disposed(by: rx.disposeBag)
    }
    
    
    @IBAction func submitButtonTapped(_ sender: Any) {
        
        self.showIndicator()
        userAPI.request(.editInvite(phone: textField.text ?? ""), type: ResponseEmpty.self)
            .checkResponse()
            .subscribe(onSuccess:{ [weak self] _ in
                self?.messageLabel.text = "提交成功、奖励会在24小时内发放到账户"
                self?.messageImageView.isHighlighted = true
                self?.stackView.isHidden = false
                self?.hideIndicator()
                
            }, onError: { [weak self]  _ in
                self?.messageLabel.text = "提交失败、请填写邀请人正确的手机号"
                self?.messageImageView.isHighlighted = false
                self?.stackView.isHidden = false
                self?.hideIndicator()
            })
            .disposed(by: rx.disposeBag)
    }
    

}
