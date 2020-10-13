//
//  UserInformationViewController.swift
//  HotChat
//
//  Created by 风起兮 on 2020/9/24.
//  Copyright © 2020 风起兮. All rights reserved.
//

import UIKit
import SwiftDate
import ZLPhotoBrowser
import Toast_Swift
import MBProgressHUD
import Kingfisher

class UserInformationViewController: UITableViewController, IndicatorDisplay {
    
    
    @IBOutlet weak var avatarImageView: UIImageView!
    
    
    @IBOutlet weak var maleButton: UIButton!
    
    @IBOutlet weak var femaleButton: UIButton!
    
    
    @IBOutlet weak var nicknameTextField: UITextField!
    
    
    @IBOutlet weak var birthdayLabel: UILabel!
    
    
    @IBOutlet weak var submitButton: UIButton!
    
    private var avatarURL: String?
    
    private var date: Date? {
        didSet {
            updateBirthdayDisplay()
        }
    }
    
    
    private var genderSeletctedButton: UIButton? {
        didSet {
            updateGenderSeletcted()
        }
    }
    
    private let API = Request<AccountAPI>()
    private let uploadAPI = Request<UploadFileAPI>()
    
    static func loadFromStoryboard() -> Self {
        
        let storyboard = UIStoryboard(name: "Account", bundle: nil)
        
        let identifier = String(describing: Self.self)
        
        return  storyboard.instantiateViewController(withIdentifier: identifier) as! Self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        updateBirthdayDisplay()
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        adjustFooterViewHeightToFillTableView()
    }
    
    private func adjustFooterViewHeightToFillTableView() {
        
         guard let tableFooterView = tableView.tableFooterView  else {
             return
         }
         
        let usableHeight = tableView.frame.height - tableView.contentSize.height + tableFooterView.frame.height - safeAreaTop
         
         if usableHeight != tableFooterView.frame.height {
            tableView.tableFooterView?.frame.size.height  = max(usableHeight, 100)
            tableView.tableFooterView = tableView.tableFooterView
         }
    }
    
    
    @IBAction func genderButtonDidTag(_ sender: UIButton) {
        genderSeletctedButton = sender
    }
    
    private func updateGenderSeletcted() {
        
        let buttons = [maleButton, femaleButton].compactMap { $0 }
        
        for button in buttons {
            let selected = button == genderSeletctedButton
            button.isSelected = selected
        }
    }


    @IBAction func photoButtonDidTap(_ sender: Any) {
        photoPicker()
    }
    
    
    func photoPicker() {
        
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
                        self.avatarURL = response.data!.first!.picUrl
                        self.avatarImageView.image = image
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
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let datePicker = segue.destination as? DatePickerViewController {
            
            datePicker.onDateUpdated.delegate(on: self) { (self, date) in
                self.date = date
            }
        }
        else if let vc = segue.destination as? UserInfoLikeObjectViewController {
            vc.onUpdated.delegate(on: self) { (self, _) in
                UIApplication.shared.keyWindow?.setMainViewController()
            }
        }
    }
    
    func updateBirthdayDisplay() {
        
        if let date = self.date {
            birthdayLabel.text = date.constellationFormat
        }
        else {
            birthdayLabel.text  = "请输入生日"
        }
    }
    
    var sex: Sex {
        return genderSeletctedButton! == maleButton ? .male : .female
    }

    
    @IBAction func submitButtonDidTap(_ sender: Any) {
        
        if !verification() {
            return
        }

        view.endEditing(true)
        
        let birthday =  Int(date!.timeIntervalSince1970)
        
        let hub = MBProgressHUD.showAdded(to: view.window!, animated: true)
        API.request(.editUser(headPic: avatarURL!, sex: sex.rawValue, nick: nicknameTextField.text!, birthday: birthday), type: Response<User>.self)
            .subscribe(onSuccess: {[weak self] response in
                if response.isSuccessd {
                    self?.performSegue(withIdentifier: "UserInfoLikeObjectViewController", sender: nil)
                }
                else {
                    self?.show(response.msg)
                }
                hub.hide(animated: true)
            }, onError: { [weak self] error in
                self?.view.makeToast(error.localizedDescription)
                hub.hide(animated: true)
            })
            .disposed(by: rx.disposeBag)
    }
    
    func verification() -> Bool {
        
        guard let _ = avatarURL else {
            show("请上传头像")
            return false
        }
        
        guard let _ = genderSeletctedButton else {
            show("请选择性别")
            return false
        }
        
        
        guard let text = nicknameTextField.text, !text.isEmpty  else {
            show("请输入昵称")
            return false
        }
        
        guard let _ = self.date else {
            show("请输入生日")
            return false
        }
        return true
    }
    
}



