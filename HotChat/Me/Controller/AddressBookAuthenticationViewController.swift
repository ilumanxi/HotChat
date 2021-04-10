//
//  AddressBookAuthenticationViewController.swift
//  HotChat
//
//  Created by 风起兮 on 2021/4/8.
//  Copyright © 2021 风起兮. All rights reserved.
//

import UIKit

class AddressBookAuthenticationViewController: UIViewController, IndicatorDisplay, LoadingStateType {
    
    
    var state: LoadingState = .initial {
        didSet {
            showOrHideIndicator(loadingState: state)
        }
    }
    
    
    @IBOutlet weak var qqTextField: UITextField!
    
    @IBOutlet weak var qqStatusLabel: UILabel!
    
    
    @IBOutlet weak var wechatTextField: UITextField!
    
    @IBOutlet weak var wechatStatusLabel: UILabel!
    
    
    @IBOutlet weak var phoneTextField: UITextField!
    
    
    @IBOutlet weak var phoneStatusLabel: UILabel!
    
    
    @IBOutlet weak var submitButton: GradientButton!
    
    let API = Request<UserAPI>()
    
    fileprivate var contactInfo: ContactInfo!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        navigationItem.title = "联系方式认证"
        refreshData()
        
    }

    func refreshData() {
        state = .refreshingContent
        API.request(.userContactInfo, type: Response<ContactInfo>.self)
            .verifyResponse()
            .subscribe(onSuccess: { [weak self] response in
                self?.contactInfo = response.data!
                self?.set(contactInfo: response.data!)
                self?.state = .contentLoaded
                
            }, onError: { [weak self] error in
                self?.state = .error
            })
            .disposed(by: rx.disposeBag)
    }

    
    func set(contactInfo: ContactInfo)  {
        
        qqTextField.text = contactInfo.qq?.value
        qqStatusLabel.text = contactInfo.qq?.status.description
        qqStatusLabel.textColor = contactInfo.qq?.status.textColor
        qqStatusLabel.alpha = contactInfo.qq!.status == .empty ? 0 : 1
        
        wechatTextField.text = contactInfo.weixin?.value
        wechatStatusLabel.text = contactInfo.weixin?.status.description
        wechatStatusLabel.textColor = contactInfo.weixin?.status.textColor
        wechatStatusLabel.alpha = contactInfo.weixin!.status == .empty ? 0 : 1
        
        phoneTextField.text = contactInfo.contactPhone?.value
        phoneStatusLabel.text = contactInfo.contactPhone?.status.description
        phoneStatusLabel.textColor = contactInfo.contactPhone?.status.textColor
        phoneStatusLabel.alpha = contactInfo.contactPhone!.status == .empty ? 0 : 1
        
    }
    
    @IBAction func submitButtonTapped(_ sender: Any) {
        
        let qq = qqTextField.text ?? ""
        let wechat = wechatTextField.text ?? ""
        let phone = phoneTextField.text ?? ""
        
        var params: [String : Any] = [:]
        if contactInfo.qq!.value !=  qq {
            params["qq"] = qq
        }
        
        if contactInfo.weixin!.value !=  wechat {
            params["weixin"] = wechat
        }
        
        if contactInfo.contactPhone!.value !=  phone {
            params["contactPhone"] = phone
        }
        
        showIndicator()
        
        API.request(.editUserContact(params), type: ResponseEmpty.self)
            .verifyResponse()
            .subscribe(onSuccess: { [weak self] _ in
                self?.hideIndicator()
                self?.showMessageOnWindow("提交成功")
                self?.navigationController?.popViewController(animated: true)
            }, onError: { [weak self] error in
                self?.hideIndicator()
                self?.show(error)
            })
            .disposed(by: rx.disposeBag)
    }
    
}
