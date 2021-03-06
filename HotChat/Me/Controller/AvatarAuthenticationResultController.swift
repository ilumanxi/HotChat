//
//  AvatarAuthenticationResultController.swift
//  HotChat
//
//  Created by 风起兮 on 2020/11/6.
//  Copyright © 2020 风起兮. All rights reserved.
//

import UIKit
import Kingfisher
import RxSwift
import RxCocoa
import TZImagePickerController

class AvatarAuthenticationResultController: UIViewController, IndicatorDisplay {
    
    let isVerify: Bool
    let originalImage: UIImage
    let remoteURLString: String
    
    @IBOutlet weak var verifyTextLabel: UILabel!
    
    @IBOutlet weak var verifyDetailTextLabel: UILabel!
    
    @IBOutlet weak var verifyImageView: UIImageView!
    
    
    @IBOutlet weak var avatarImageView: UIImageView!
    
    @IBOutlet weak var originalImageView: UIImageView!
    
    
    
    @IBOutlet weak var auditButton: UIButton!
    @IBOutlet weak var avatarButton: UIButton!
    
    let userAPI = Request<UserAPI>()
    let uploadAPI = Request<UploadFileAPI>()
    let authenticationAPI = Request<AuthenticationAPI>()
    
    @objc init(verify: Bool, originalImage: UIImage, remoteURLString: String) {
        self.isVerify = verify
        self.originalImage = originalImage
        self.remoteURLString = remoteURLString
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "头像认证"
        setupViews()
    }

    
    func setupViews() {
        
        if isVerify {
            verifyTextLabel.text = "头像认证成功"
            verifyDetailTextLabel.text = "系统将通过人脸识别来确定你的头像是否为本人\n（请保证你当前头像为本人）"
            verifyImageView.image = UIImage(named: "verification-successful")
            auditButton.isHidden = true
            avatarButton.isHidden = true
        }
        else {
            verifyTextLabel.text = "抱歉，头像认证失败"
            verifyDetailTextLabel.text = "(人脸信息与头像相似度低，请更换你的头像)"
            verifyImageView.image = UIImage(named: "verification-failed")
        }
        
        avatarImageView.kf.setImage(with: URL(string: LoginManager.shared.user!.headPic))
        originalImageView.image = originalImage
    }
    
    @IBAction func avatarButtonTapped(_ sender: Any) {
        imagePicker()
    }
    
    @IBAction func auditButtonTapped(_ sender: Any) {
        
       let alertController =  MessageAlertController(message: "提交人工审核前，请确保头像和人脸识别图像为同一人，否则将会驳回！", leftButtonTitle: "取消", rightButtonTitle: "提交审核")
        alertController.onRightDidClick.delegate(on: self) { (self, _)  in
            self.editFacePic()
        }
        
        present(alertController, animated: true, completion: nil)
    }
    
    
    func editFacePic()  {
        
        showIndicator()
        authenticationAPI.request(.editFacePic(imgFace: remoteURLString), type: ResponseEmpty.self)
            .verifyResponse()
            .subscribe(onSuccess: { [weak self] response in
                self?.hideIndicator()
                self?.show(response.msg)
            }, onError: { [weak self] error in
                self?.hideIndicator()
                self?.show(error)
            })
            .disposed(by: rx.disposeBag)
    }
    
    
    func editUserInfo(_ parameters: [String : Any]) -> Single<Response<User>> {
        return userAPI.request(.editUser(value: parameters))
            .verifyResponse()
            .do(onSuccess: { response in
                LoginManager.shared.update(user: response.data!)
            })
    }
    
    func upload(_ url: URL) -> Single<Response<[RemoteFile]>> {
        return uploadAPI.request(.upload(url)).verifyResponse()
    }
    
    func uploadImage(_ image: UIImage)  {
        showIndicator()
       let url =  writeImage(image)
        self.upload(url)
            .map{ response -> [String : Any] in
                return [
                    "type" : 3,
                    "headPic" : response.data!.first!.picUrl
                ]
            }
            .flatMap { [unowned self] in
                return self.editUserInfo($0)
            }
            .subscribe(onSuccess: { [weak self] response in
                guard let self = self else { return }
                
                var viewContollers = self.navigationController!.viewControllers
                viewContollers.removeLast()
                let vc = BDFaceDetectionViewController()
                viewContollers.append(vc)
                self.navigationController?.setViewControllers(viewContollers, animated: true)
                self.hideIndicator()
            }, onError: { [weak self]  error in
                self?.hideIndicator()
                self?.show(error)
            })
            .disposed(by: self.rx.disposeBag)
    }
    
    func editFacePic(imgFace: String) -> Single<ResponseEmpty> {
        
        return authenticationAPI.request(.editFacePic(imgFace: imgFace))
    }
    
    private func imagePicker()  {
        
        let imagePickerController = TZImagePickerController(maxImagesCount: 1, delegate: nil)!
        imagePickerController.allowPickingVideo = false
        imagePickerController.allowPickingImage = true
        imagePickerController.allowCrop = true
        
        let size = UIScreen.main.bounds.width

        let v = (UIScreen.main.bounds.height - size) / 2.0
        
        imagePickerController.cropRect = CGRect(x: 0, y: v, width: size, height: size)
        imagePickerController.scaleAspectFillCrop = true
        imagePickerController.didFinishPickingPhotosHandle = { [weak self] (images, _, _) in
            if let image = images?.first {
                self?.uploadImage(image)
            }
        }
            
        imagePickerController.modalPresentationStyle = .fullScreen
        present(imagePickerController, animated: true, completion: nil)
    }
}
