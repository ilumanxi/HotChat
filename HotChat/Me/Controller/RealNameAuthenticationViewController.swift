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

class RealNameAuthenticationViewController: UITableViewController, IndicatorDisplay {
    

    fileprivate var isShowUploadCard: Bool = false {
        didSet {
            handleUploadCardDisplayStatus()
        }
    }
    
    fileprivate let cardCellIndexPath: IndexPath = IndexPath(row: 3, section: .zero)
    
    @IBOutlet var cardHiddenShowViews: [UIView]!
    
    @IBOutlet var cardShowHiddenViews: [UIView]!
    
    
    @IBOutlet weak var nicknameTextField: UITextField!
    
    @IBOutlet weak var IDCardTexField: UITextField!
    
    
    @IBOutlet weak var frontImageView: UIImageView!
    
    
    @IBOutlet weak var backImgaeView: UIImageView!
    
    
    var authentication: Authentication!
    
    let uploadAPI = RequestAPI<UploadFileAPI>()
    
    let userAPI = RequestAPI<UserAPI>()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        isShowUploadCard = false
        
        setupUI()
    }
    
    func setupUI(){
        nicknameTextField.text = authentication.userName
        IDCardTexField.text = authentication.identityNum
        frontImageView.kf.setImage(with: URL(string: authentication.identityPicFront))
        backImgaeView.kf.setImage(with: URL(string: authentication.identityPicFan))
    }
    
    
    @IBAction func submitAction(_ sender: Any) {
        
        let userName = nicknameTextField.text ?? ""
        let identityNum = IDCardTexField.text ?? ""
        
        let hub = MBProgressHUD.showAdded(to: UIApplication.shared.keyWindow!, animated: true)
        userAPI.request(
            .userEditAttestation(userName: userName, identityNum: identityNum, identityPicFront: authentication.identityPicFront, identityPicFan: authentication.identityPicFan),
            type: ResponseEmpty.self
        )
        .subscribe(onSuccess: { [weak self] response in
            hub.hide(animated: false)
            if response.isSuccessd {
                self?.navigationController?.popViewController(animated: true)
            }
            else {
                self?.show(response.msg)
            }
        }, onError: { [weak self] error in
            hub.hide(animated: false)
            self?.show(error.localizedDescription)
        })
        .disposed(by: rx.disposeBag)
    }
    
    
    @IBAction func frontButtonDidTag(_ sender: Any) {
        
        photoPicker {[weak self] (image, url) in
            self?.frontImageView.image = image
            self?.authentication.identityPicFront = url
        }
    }
    
    @IBAction func backButtonDidTag(_ sender: Any) {
        photoPicker {[weak self] (image, url) in
            self?.backImgaeView.image = image
            self?.authentication.identityPicFan = url
        }
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
            
            self.uploadAPI.request(.upload(url!), type: Response<[RemoteFile]>.self)
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
    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if !isShowUploadCard  && indexPath == cardCellIndexPath {
            return .zero
        }
        return super.tableView(tableView, heightForRowAt: indexPath)
    }
    
    @IBAction func showUploadCardView(_ sender: Any) {
        isShowUploadCard = true
    }
    
    fileprivate func handleUploadCardDisplayStatus() {
                
        cardHiddenShowViews.forEach {
            $0.isHidden = !isShowUploadCard
        }
        
        cardShowHiddenViews.forEach {
            $0.isHidden = isShowUploadCard
        }
        
        tableView.reloadData()
    }

}
