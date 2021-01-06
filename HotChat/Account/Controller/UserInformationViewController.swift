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

class UserInformationViewController: UITableViewController, IndicatorDisplay, StoryboardCreate {
   
    
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
    
    static var storyboardNamed: String { return "Account" }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.hidesBackButton = true
        hbd_backInteractive = false
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
        let imagePickerController = TZImagePickerController(maxImagesCount: 1, delegate: nil)!
        imagePickerController.allowPickingVideo = false
        imagePickerController.allowPickingImage = true
        imagePickerController.allowCrop = true
        
        let size = UIScreen.main.bounds.width

        let v = (UIScreen.main.bounds.height - size) / 2.0
        
        imagePickerController.cropRect = CGRect(x: 0, y: v, width: size, height: size)
        imagePickerController.scaleAspectFillCrop = true
        imagePickerController.didFinishPickingPhotosHandle = { [weak self] (photos,assets, isSelectOriginalPhoto) in
            let image = photos!.first!
            self?.uploadImage(image)
        }
        
        imagePickerController.modalPresentationStyle = .fullScreen
        present(imagePickerController, animated: true, completion: nil)
    }
    
    
    func uploadImage(_ image: UIImage) {
        let url = writeImage(image)
        showIndicatorOnWindow("上传中")
        self.uploadAPI.request(.upload(url), type: Response<[RemoteFile]>.self)
            .verifyResponse()
            .subscribe(onSuccess: {[weak self] response in
                self?.avatarURL = response.data!.first!.picUrl
                self?.avatarImageView.image = image
                self?.hideIndicatorFromWindow()
            }, onError: { [weak self] error in
                self?.hideIndicatorFromWindow()
                self?.showMessageOnWindow(error)
            })
            .disposed(by: self.rx.disposeBag)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let datePicker = segue.destination as? DatePickerViewController {
            
            datePicker.onDateUpdated.delegate(on: self) { (self, date) in
                self.date = date
            }
        }
        else if let vc = segue.destination as? UserInfoLikeObjectViewController {
            vc.title = nil
            vc.navigationItem.title = nil
            vc.navigationItem.hidesBackButton = true
            vc.hbd_backInteractive = false
            vc.sex = sex
            vc.onUpdated.delegate(on: self) { (self, _) in
                let vc = ForYouViewController.loadFromStoryboard()
                vc.sex = self.sex
                self.navigationController?.pushViewController(vc, animated: true)
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
        
        showIndicatorOnWindow()
        API.request(.editUser(headPic: avatarURL!, sex: sex.rawValue, nick: nicknameTextField.text!, birthday: birthday), type: Response<User>.self)
            .verifyResponse()
            .subscribe(onSuccess: {[weak self] response in
                self?.performSegue(withIdentifier: "UserInfoLikeObjectViewController", sender: nil)
                self?.hideIndicatorFromWindow()
            }, onError: { [weak self] error in
                self?.hideIndicatorFromWindow()
                self?.showMessageOnWindow(error)
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



