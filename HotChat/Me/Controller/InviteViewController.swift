//
//  InviteViewController.swift
//  HotChat
//
//  Created by 风起兮 on 2020/10/23.
//  Copyright © 2020 风起兮. All rights reserved.
//

import UIKit

class InviteViewController: UIViewController, LoadingStateType, IndicatorDisplay, StoryboardCreate {
    
    static var storyboardNamed: String { return "Me" }
    
    
    var state: LoadingState = .initial {
        didSet {
            showOrHideIndicator(loadingState: state)
        }
    }
    
    @IBOutlet weak var textField: UITextField!

    
    @IBOutlet weak var hintView: UIView!
    
    let userAPI = Request<UserAPI>()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    @IBAction func submitButtonTapped(_ sender: Any) {
        
        let phone = textField.text ?? ""
        
        if phone.isEmpty {
            show("手机号不能为空")
            return
        }
        
        view.endEditing(true)
        self.showIndicator()
        userAPI.request(.editInvite(phone: phone), type: ResponseEmpty.self)
            .checkResponse()
            .subscribe(onSuccess:{ [weak self] response in
                self?.show(response.msg)
                self?.hideIndicator()
                
            }, onError: { [weak self]  error in
                self?.show(error.localizedDescription)
                self?.hideIndicator()
            })
            .disposed(by: rx.disposeBag)
    }
    

}
