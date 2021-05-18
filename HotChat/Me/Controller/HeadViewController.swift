//
//  HeadViewController.swift
//  HotChat
//
//  Created by 风起兮 on 2021/5/18.
//  Copyright © 2021 风起兮. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import TZImagePickerController

class HeadViewController: UIViewController, IndicatorDisplay {
    
    let userAPI = Request<UserAPI>()
    let uploadAPI = Request<UploadFileAPI>()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "头像认证"

        // Do any additional setup after loading the view.
    }


    @IBAction func faceButtonTapped(_ sender: Any) {
        
        let vc = BDFaceDetectionViewController()
        
        var viewControllers =  navigationController?.viewControllers ?? []
        
        viewControllers.removeAll { [unowned self] in
            $0 == self
        }
        viewControllers.append(vc)
        navigationController?.setViewControllers(viewControllers, animated: true)
    }
    
    @IBAction func avatarButtonTapped(_ sender: Any) {
        imagePicker()
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

}
