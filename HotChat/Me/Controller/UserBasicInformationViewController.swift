//
//  UserBasicInformationViewController.swift
//  HotChat
//
//  Created by 风起兮 on 2020/9/25.
//  Copyright © 2020 风起兮. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import MBProgressHUD

class UserBasicInformationViewController: UITableViewController, IndicatorDisplay {
    
    
    @IBOutlet weak var nicknameTextField: UITextField!
    
    
    @IBOutlet weak var sexLabel: UILabel!
    
    @IBOutlet weak var birthdayLabel: UILabel!
    
    @IBOutlet weak var userIDLabel: UILabel!
    
    
    @IBOutlet weak var regionLabel: UILabel!
    
    @IBOutlet weak var heightTextField: UITextField!
    
    @IBOutlet weak var homeTextField: UITextField!
    
    @IBOutlet weak var educationTextField: UITextField!
    
    @IBOutlet weak var industryTextField: UITextField!
    
    
    @IBOutlet weak var incomeTextField: UITextField!
    
    var user: User!
    
    var region: (province: Region, city: Region)?
    var birthday: Date?
    
    let onUpdated = Delegate<User, Void>()
    
    let userAPI = Request<UserAPI>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        refreshDisplay()
    }

    func refreshDisplay() {
        nicknameTextField.text = user.nick
        sexLabel.text = user.sex.description
        birthdayLabel.text = Date(timeIntervalSince1970: user.birthday).constellationFormat
        userIDLabel.text = user.userId.description
        regionLabel.text = user.region
        
        if heightTextField.text?.isEmpty ?? true {
            heightTextField.text =  user.height
        }
        
        if homeTextField.text?.isEmpty ?? true {
            homeTextField.text =  "\(user.homeProvince)\(user.homeCity)"
        }
       
        if educationTextField.text?.isEmpty ?? true {
            educationTextField.text = user.education
        }
        
        if industryTextField.text?.isEmpty ?? true {
            industryTextField.text = user.industryList.first?.label
        }
       
        if incomeTextField.text?.isEmpty ?? true {
            incomeTextField.text =  user.income
        }
    }
    
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        if indexPath.row ==  5 { //身高
            
            let heights = 150...200
            let content = heights.compactMap {
                "\($0)cm"
            }
            
            presentPicker(contents: content, selectRow: 10) { [unowned self]  text in
                self.heightTextField.text = text
            }
        }
       else if indexPath.row == 6 { // 家乡
            
            let vc = RegionPickerViewController()
            vc.onPickered.delegate(on: self) { (self, region) in
                self.region = region
                self.homeTextField.text = "\(self.region!.province.label)\(self.region!.city.label)"
            }
            present(vc, animated: true, completion: nil)
        }
        else if indexPath.row ==  7 { //学历
            
            let contents = ["初中", "中专", "高中", "大专", "本科", "硕士", "博士"]
            
            presentPicker(contents: contents, selectRow: 2) { [unowned self]  text in
                self.educationTextField.text = text
            }
        }
        else if indexPath.row ==  8 { //行业
            
            let contents = UserConfig.share.industry.map { $0.label }
            
            presentPicker(contents: contents, selectRow: 0) { [unowned self]  text in
                self.industryTextField.text = text
            }
        }
        else if indexPath.row ==  9 { //年收入
            
            let contents = ["5万以下", "5万~10万", "10万~20万", "20万~30万", "30万~50万", "50万~100万", "100万以上"]
            
            presentPicker(contents: contents, selectRow: 0) { [unowned self]  text in
                self.incomeTextField.text = text
            }
        }
       
    }
    
    func presentPicker(contents: [String], selectRow: Int, block: @escaping (String) -> Void )  {
        let vc = PickerViewController(conents: contents, selectRow: selectRow)
        vc.onPickered.delegate(on: self) { (self, content) in
            block(content)
        }
        present(vc, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let vc = segue.destination as? DatePickerViewController {
            vc.onDateUpdated.delegate(on: self) { (self, date) in
                self.user.birthday = date.timeIntervalSince1970
                self.refreshDisplay()
            }
        }
    }
    
    
    @IBAction func doneAction(_ sender: Any) {
        
    
        
        user.nick = nicknameTextField.text ?? ""
        
        var params: [String : Any] = [
            "type" : 4,
            "nick" :nicknameTextField.text ?? user.nick,
            "birthday" : birthday?.timeIntervalSince1970 ?? user.birthday
        ]
        
        if let height = heightTextField.text, !height.isEmpty {
            params["height"] = height
        }
        if let region = self.region  {
            params["homeProvince"] = region.province.label
            params["homeCity"] = region.city.label
        }
        
        if let education = educationTextField.text, !education.isEmpty {
            params["education"] = education
        }
        if let industry = industryTextField.text, !industry.isEmpty {
            params["industry"] = industry
        }
        if let income = incomeTextField.text, !income.isEmpty {
            params["income"] = income
        }
        
        showIndicatorOnWindow()
        
        userAPI.request(.editUserDispose(params), type: Response<User>.self)
            .verifyResponse()
            .subscribe(onSuccess: { [weak self] response in
                self?.hideIndicatorFromWindow()
                guard let self = self else {
                    return
                }
                if response.isSuccessd {
                    self.onUpdated.call(response.data!)
                    self.navigationController?.popViewController(animated: true)
                }
                else {
                    self.show(response.msg)
                }
               
            }, onError: { [weak self] error in
                self?.hideIndicatorFromWindow()
                self?.show(error)
               
            })
            .disposed(by: rx.disposeBag)
    }
    
}
