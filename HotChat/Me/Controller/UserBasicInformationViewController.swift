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
    
    var user: User!
    
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
        print(Date(timeIntervalSinceNow: user.birthday))
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
        
        let hub = MBProgressHUD.showAdded(to: view.window!, animated: true)
        
        user.nick = nicknameTextField.text ?? ""
        
        let params: [String : Any] = [
            "type" : 1,
            "nick" : user.nick,
            "birthday" : user.birthday
        ]
        
        userAPI.request(.editUser(value: params), type: Response<User>.self)
            .subscribe(onSuccess: { [weak self] response in
                hub.hide(animated: true)
                guard let self = self else {
                    return
                }
                if response.isSuccessd {
                    self.onUpdated.call(self.user)
                    self.navigationController?.popViewController(animated: true)
                }
                else {
                    self.show(response.msg)
                }
               
            }, onError: { [weak self] error in
                hub.hide(animated: true)
                self?.show(error.localizedDescription)
               
            })
            .disposed(by: rx.disposeBag)
    }
    
}
