//
//  AuthenticationViewController.swift
//  HotChat
//
//  Created by 风起兮 on 2020/9/28.
//  Copyright © 2020 风起兮. All rights reserved.
//

import UIKit

class AuthenticationViewController: UITableViewController, IndicatorDisplay {
    

    @IBOutlet weak var realNameStatuaLabel: UILabel!
    
    let API = RequestAPI<UserAPI>()
    
    
    var authentication: Authentication! {
        didSet {
            refreshDisplay()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        requestData()
    }
    
    func refreshDisplay() {
        guard let authentication = self.authentication  else {
            return
        }
        
        realNameStatuaLabel.text = authentication.certificationStatus.description
        tableView.reloadData()
    }

    func requestData() {
        
        API.request(.userAttestationInfo, type: Response<Authentication>.self)
            .subscribe(onSuccess: { [weak self] response in
                if response.isSuccessd {
                    self?.authentication = response.data
                }
            }, onError: { [weak self] error in
                self?.show(error.localizedDescription)
            })
            .disposed(by: rx.disposeBag)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if authentication == nil {
            return 0
        }
        
        return super.tableView(tableView, numberOfRowsInSection: section)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let vc = segue.destination as? RealNameAuthenticationViewController {
            vc.authentication = authentication
        }
    }

}
