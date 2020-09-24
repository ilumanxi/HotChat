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

class UserInformationViewController: UITableViewController, Wireframe {
    
    
    @IBOutlet weak var avatarImageView: UIImageView!
    
    
    @IBOutlet weak var maleButton: UIButton!
    
    @IBOutlet weak var femaleButton: UIButton!
    
    
    @IBOutlet weak var nicknameTextField: UITextField!
    
    
    @IBOutlet weak var birthdayLabel: UILabel!
    
    
    @IBOutlet weak var submitButton: UIButton!
    
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
    
    private let API = RequestAPI<Account>()
    
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
        contoler.selectImageBlock = { [weak self] (images, assets, isOriginal) in

            self?.avatarImageView.image = images.first!
        }
        contoler.showPhotoLibrary(sender: self)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let datePicker = segue.destination as? DatePickerViewController {
            
            datePicker.delegate.delegate(on: self) { (self, date) in
                self.date = date
            }
        }
    }
    
    func updateBirthdayDisplay() {
        
        if let date = self.date {
            birthdayLabel.text = "\(date.toFormat("yyyy/MM/dd"))(\(date.constellation))"
        }
        else {
            birthdayLabel.text  = "请输入生日"
        }
    }
    
    var sex: User.Sex {
        return genderSeletctedButton! == maleButton ? .male : .female
    }

    
    @IBAction func submitButtonDidTap(_ sender: Any) {
        
        if !verification() {
            return
        }

        view.endEditing(true)
        
        let headPic = "https://www.wind.com/images/user/icon.jpg"
        
        let birthday =  Int(date!.timeIntervalSince1970)
        
        let hub = MBProgressHUD.showAdded(to: view.window!, animated: true)
        API.request(.editUser(headPic: headPic, sex: sex.rawValue, nick: nicknameTextField.text!, birthday: birthday), type: HotChatResponse<User>.self)
            .subscribe(onSuccess: {[weak self] response in
                if !response.isSuccessd {
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
        
        guard let _ = avatarImageView.image else {
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



