//
//  DynamicDetailViewController.swift
//  HotChat
//
//  Created by 风起兮 on 2020/10/12.
//  Copyright © 2020 风起兮. All rights reserved.
//

import UIKit

class DynamicDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    let dynamicAPI = Request<DynamicAPI>()
    
    var dynamics: [Dynamic] = [] {
        didSet {
            if isViewLoaded {
                tableView.reloadData()
            }
        }
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    var user: User!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let parameters: [String : Any] = [
            "userId" : user.userId
        ]
        
        dynamicAPI.request(.dynamicList(parameters), type:Response<Pagination<Dynamic>>.self)
            .subscribe(onSuccess: { [weak self] response in
                self?.dynamics = response.data?.list ?? []
                Log.print(response)
            }, onError: { error in
                Log.print(error)
            })
            .disposed(by: rx.disposeBag)
    }
    
    func like(_ dynamic: Dynamic)  {
        
        dynamicAPI.request(.zan(dynamic.dynamicId), type: Response<[String : Any]>.self)
            .subscribe(onSuccess: {[weak self] response in
               
                guard let index = self?.dynamics.lastIndex(where: { $0.dynamicId == dynamic.dynamicId }),
                      let zanNum = response.data?["zanNum"] as? Int,
                      let isSelfZan = response.data?["type"] as? Bool else {
                    return
                }
                
                self?.dynamics.modifyElement(at: index, { element in
                    element.zanNum = zanNum
                    element.isSelfZan = isSelfZan
                })
                self?.tableView.reloadData()
                
                Log.print(response)
            }, onError: { error in
                Log.print(error)
            })
            .disposed(by: rx.disposeBag)
        
    }
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dynamics.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(for: indexPath, cellType: DynamicDetailViewCell.self)
        cell.dynamic = dynamics[indexPath.item]
        
        cell.onAvatarTapped.delegate(on: self) { (self, sender) in
            let vc = UserInfoViewController()
            vc.user  = sender.dynamic.userInfo
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        cell.onLikeTapped.delegate(on: self) { (self, sender) in
            self.like(sender.dynamic)
        }
        
        return cell
    }

}
