//
//  BlacklistController.swift
//  HotChat
//
//  Created by 风起兮 on 2020/11/11.
//  Copyright © 2020 风起兮. All rights reserved.
//

import UIKit
import Kingfisher
 
class BlacklistController: UIViewController, LoadingStateType, IndicatorDisplay {
    
    
    var state: LoadingState = .initial {
        didSet {
            showOrHideIndicator(loadingState: state)
        }
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    let uesrAPI = Request<UserAPI>()
    
    var data: [User] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        refreshData()
    }
    
    func refreshData() {
        state = .refreshingContent
        uesrAPI.request(.blackList, type: Response<[User]>.self)
            .verifyResponse()
            .subscribe(onSuccess: { [weak self] response in
                self?.data = response.data!
                self?.tableView.reloadData()
                self?.state = response.data!.isEmpty ? .noContent : .contentLoaded
                
            }, onError: {[weak self] error in
                self?.state = .error
            })
            .disposed(by: rx.disposeBag)
    }
    
    func setupViews() {
        title = "黑名单管理"
        tableView.rowHeight = 70
        tableView.estimatedRowHeight = 0
        tableView.register(UINib(nibName: "BlacklistCell", bundle: nil), forCellReuseIdentifier: "BlacklistCell")
    }
    
    func editDefriend(_ user: User) {
        showIndicator()
        uesrAPI.request(.editDefriend(userId: user.userId), type: ResponseEmpty.self)
            .verifyResponse()
            .subscribe(onSuccess: { [weak self] _ in
                guard let self = self else { return }
                let index = self.data.firstIndex(of: user)!
                self.data.remove(at: index)
                self.tableView.reloadData()
                self.hideIndicator()
            }, onError: { [weak self] error in
                self?.hideIndicator()
                self?.show(error.localizedDescription)
            })
            .disposed(by: rx.disposeBag)
    }

}



extension BlacklistController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let model = data[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(for: indexPath, cellType: BlacklistCell.self)
        cell.avatarImageView.kf.setImage(with: URL(string: model.headPic))
        cell.nicknameLabel.text = model.nick
        
        cell.onRemoveButtonTapped.delegate(on: self) { (self, sender) in
            self.editDefriend(model)
        }
        
        return cell
    }
    
}
