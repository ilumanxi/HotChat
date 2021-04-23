//
//  UserInformationViewController.swift
//  HotChat
//
//  Created by 风起兮 on 2020/9/24.
//  Copyright © 2020 风起兮. All rights reserved.
//

import UIKit
import SwiftDate
import Kingfisher
import TZImagePickerController
import RangersAppLog

class UserInformationViewController: UIViewController, IndicatorDisplay {
   
    
    @IBOutlet var maleButtons: [UIButton]!
    
    @IBOutlet weak var maleButton: UIButton!
    
    @IBOutlet var femaleButtons: [UIButton]!
    
    @IBOutlet weak var femaleButton: UIButton!
    
    @IBOutlet weak var submitButton: UIButton!
    
    
    private var sex: Sex = .empty {
        didSet {
            setupSexViews()
        }
    }
    
    
    private let API = Request<AccountAPI>()
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.hidesBackButton = true
        setupViews()
    }
       
    
    func setupViews() {
        
        let size = CGSize(width: 58, height: 22)
        
        maleButton.setBackgroundImage(UIImage(color: .disabledGray, size: size), for: .normal)
        maleButton.setBackgroundImage(UIImage(color: .theme, size: size), for: .selected)
        
        femaleButton.setBackgroundImage(UIImage(color: .disabledGray, size: size), for: .normal)
        femaleButton.setBackgroundImage(UIImage(color: .theme, size: size), for: .selected)
        
    }
    
    func setupSexViews()  {
        maleButtons.forEach { [unowned self] btn in
            btn.isSelected = self.sex == .male
        }
        femaleButtons.forEach { [unowned self] btn in
            btn.isSelected = self.sex == .female
        }
    }
    
    
    @IBAction func maleButtonDidTag(_ sender: UIButton) {
        sex = .male
        
    }
    
    @IBAction func femaleButtonDidTag(_ sender: UIButton) {
        sex = .female
    }
        
    @IBAction func submitButtonDidTap(_ sender: Any) {
        
        if !verification() {
            return
        }

        view.endEditing(true)
        showIndicatorOnWindow()
        
        API.request(.createUserAccount(sex: sex), type: Response<User>.self)
            .verifyResponse()
            .subscribe(onSuccess: {[unowned self] response in
                LoginManager.shared.update(user: response.data!)
                if self.sex == .male {
                    self.pushForYouViewController()
                }
                else {
                    self.pushUserInfoLikeObject()
                }
                BDAutoTrack.registerEvent(byMethod: "normal", isSuccess: true)
                self.hideIndicatorFromWindow()
            }, onError: { [weak self] error in
                self?.hideIndicatorFromWindow()
                self?.showMessageOnWindow(error)
            })
            .disposed(by: rx.disposeBag)
    }
    
    private func pushUserInfoLikeObject() {
        
        let vc = UserInfoLikeObjectViewController.loadFromStoryboard()
        vc.title = nil
        vc.navigationItem.title = nil
        vc.navigationItem.hidesBackButton = true
        vc.sex = sex
        vc.onUpdated.delegate(on: self) { (self, _) in
            let vc = ForYouViewController.loadFromStoryboard()
            vc.sex = self.sex
            self.navigationController?.pushViewController(vc, animated: true)
        }
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func pushForYouViewController() {
        
        let vc = ForYouViewController.loadFromStoryboard()
        vc.sex = self.sex
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func verification() -> Bool {
        if sex == .empty {
            show("请选择性别")
            return false
        }
        return true
    }
    
}



