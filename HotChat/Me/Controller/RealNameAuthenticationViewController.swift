//
//  RealNameAuthenticationViewController.swift
//  HotChat
//
//  Created by 风起兮 on 2020/8/28.
//  Copyright © 2020 风起兮. All rights reserved.
//

import UIKit
import ZLPhotoBrowser
import MBProgressHUD
import Kingfisher



class RealNameAuthenticationViewController: UITableViewController, IndicatorDisplay, StoryboardCreate {
    
    
    static var storyboardNamed: String { return "Me"}
    
    
    @IBOutlet weak var nicknameTextField: UITextField!
    
    @IBOutlet weak var IDCardTexField: UITextField!
    
    
    
    
    var authentication: Authentication!
    
    let uploadAPI = Request<UploadFileAPI>()
    
    let userAPI = Request<UserAPI>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    func setupUI(){
        nicknameTextField.text = authentication.userName
        IDCardTexField.text = authentication.identityNum
    }
    
    
    @IBAction func submitAction(_ sender: Any) {
        
        let userName = nicknameTextField.text ?? ""
        let identityNum = IDCardTexField.text ?? ""
        
        if userName.isEmpty {
            show("姓名不能为空")
            return
        }
        
        if identityNum.isEmpty {
            show("身份证号不能为空")
            return
        }
        
        showIndicatorOnWindow()
        userAPI.request(
            .userEditAttestation(userName: userName, identityNum: identityNum, identityPicFront: authentication.identityPicFront, identityPicFan: authentication.identityPicFan),
            type: ResponseEmpty.self
        )
        .subscribe(onSuccess: { [weak self] response in
            self?.hideIndicatorFromWindow()
            if response.isSuccessd {
                self?.navigationController?.popViewController(animated: true)
            }
            else {
                self?.show(response.msg)
            }
        }, onError: { [weak self] error in
            self?.hideIndicatorFromWindow()
            self?.show(error.localizedDescription)
        })
        .disposed(by: rx.disposeBag)
    }
    

    
    func photoPicker(complete: @escaping (UIImage, String) -> Void) {
        
        let config = ZLPhotoConfiguration.default()
        config.maxSelectCount = 1
        config.allowSelectVideo = false
        
        let contoler = ZLPhotoPreviewSheet(selectedAssets: [])
        contoler.selectImageBlock = { [unowned self] (images, assets, isOriginal) in

            let image = images.first!
            
            let url = writeImage(image)
            
            let hub = MBProgressHUD.showAdded(to: UIApplication.shared.keyWindow!, animated: true)
            
            self.uploadAPI.request(.upload(url), type: Response<[RemoteFile]>.self)
                .subscribe(onSuccess: { response in
                    hub.hide(animated: true)
                    if response.isSuccessd {
                        complete(image, response.data!.first!.picUrl)
                    }
                    else {
                        self.show(response.msg)
                    }
                }, onError: { error in
                    hub.hide(animated: false)
                    self.show(error.localizedDescription)
                })
                .disposed(by: self.rx.disposeBag)
        }
        contoler.showPhotoLibrary(sender: self)
    }
    
    

}
