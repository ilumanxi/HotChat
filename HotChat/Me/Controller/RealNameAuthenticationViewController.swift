//
//  RealNameAuthenticationViewController.swift
//  HotChat
//
//  Created by 风起兮 on 2020/8/28.
//  Copyright © 2020 风起兮. All rights reserved.
//

import UIKit
import Kingfisher
import TZImagePickerController



class RealNameAuthenticationViewController: UITableViewController, IndicatorDisplay, StoryboardCreate {
    
    
    static var storyboardNamed: String { return "Me"}
    
    
    @IBOutlet weak var nicknameTextField: UITextField!
    
    @IBOutlet weak var IDCardTexField: UITextField!
    
    
    let uploadAPI = Request<UploadFileAPI>()
    
    let userAPI = Request<UserAPI>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        nicknameTextField.becomeFirstResponder()
        super.viewWillAppear(animated)
    }
    
    func setupUI(){

        let textFields = [nicknameTextField, IDCardTexField]
        
        textFields.forEach {
            $0?.attributedPlaceholder = NSAttributedString(string: $0?.placeholder ?? "", attributes: [NSAttributedString.Key.foregroundColor : UIColor.placeholderRed])
        }
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
            .userEditAttestation(userName: userName, identityNum: identityNum, identityPicFront: nil, identityPicFan: nil),
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
            self?.show(error)
        })
        .disposed(by: rx.disposeBag)
    }
    

    
    func photoPicker(complete: @escaping (UIImage, String) -> Void) {
        
        let imagePickerController = TZImagePickerController(maxImagesCount: 1, delegate: nil)!
        imagePickerController.allowPickingVideo = false
        imagePickerController.allowPickingImage = true
        
        imagePickerController.didFinishPickingPhotosHandle = { [unowned self] (images, _, _) in
            let image = images!.first!
            let url = writeImage(image)
            showIndicatorOnWindow()
            self.uploadAPI.request(.upload(url), type: Response<[RemoteFile]>.self)
                .verifyResponse()
                .subscribe(onSuccess: { [weak self] response in
                    LoginManager.shared.refresh()
                    self?.hideIndicatorFromWindow()
                    complete(image, response.data!.first!.picUrl)
                }, onError: { [weak self] error in
                    self?.hideIndicatorFromWindow()
                    self?.showMessageOnWindow(error)
                })
                .disposed(by: self.rx.disposeBag)
        }
            
        imagePickerController.modalPresentationStyle = .fullScreen
        present(imagePickerController, animated: true, completion: nil)
    }
    
    

}
