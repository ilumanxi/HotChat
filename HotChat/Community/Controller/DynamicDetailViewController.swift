//
//  DynamicDetailViewController.swift
//  HotChat
//
//  Created by 风起兮 on 2020/10/12.
//  Copyright © 2020 风起兮. All rights reserved.
//

import UIKit
import GKPhotoBrowser
import SPAlertController

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
        
        let dynamic = dynamics[indexPath.item]
        
        let cell = tableView.dequeueReusableCell(for: indexPath, cellType: DynamicDetailViewCell.self)
        cell.dynamic = dynamic
        
        cell.onAvatarTapped.delegate(on: self) { (self, sender) in
            let vc = UserInfoViewController()
            vc.user  = dynamic.userInfo
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        cell.onLikeTapped.delegate(on: self) { (self, sender) in
            self.like(dynamic)
        }
        cell.onCommentTapped.delegate(on: self) { (self, _) in
            let info = TUIConversationCellData()
            info.userID = dynamic.userInfo.userId
            let vc  = ChatViewController(conversation: info)!
            vc.title = dynamic.userInfo.nick
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        cell.onImageTapped.delegate(on: self) { (self, sender) in
            
            let (_, index, imageViews) = sender
            
            let photos = (0..<imageViews.count)
                .compactMap { index -> GKPhoto? in
                    let photo = GKPhoto()
                    photo.url = URL(string: dynamic.photoList[index].picUrl)
                    photo.sourceImageView = imageViews[index]
                    return photo
                }
            
            let browser = GKPhotoBrowser(photos: photos, currentIndex: index)
            browser.showStyle = .zoom
            browser.hideStyle = .zoomScale
            browser.loadStyle = .indeterminateMask
            browser.maxZoomScale = 20
            browser.doubleZoomScale = 2
            
            browser.show(fromVC: self)
        }
        
        cell.onMoreButtonTapped.delegate(on: self) { (self, _) in
            let alertController = SPAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
     
            alertController.addAction(SPAlertAction(title: "不看Ta的动态", style: .default, handler: { _ in
                
            }))
            
            alertController.addAction(SPAlertAction(title: "举报这条动态", style: .default, handler: { _ in
                
            }))
            
            alertController.addAction(SPAlertAction(title: "取消", style: .cancel, handler: nil))
            
            self.present(alertController, animated: true, completion: nil)
        }
        
        return cell
    }

}
