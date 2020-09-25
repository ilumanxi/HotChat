//
//  UserInfoLikeObjectViewController.swift
//  HotChat
//
//  Created by 风起兮 on 2020/9/2.
//  Copyright © 2020 风起兮. All rights reserved.
//

import UIKit
import MBProgressHUD



class UserInfoLikeObjectViewController: UIViewController, Wireframe {
    
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    @IBOutlet weak var collectionViewGridLayout: CollectionViewGridLayout!
    
    
    let onUpdated = Delegate<User, Void>()
     
    
    let userAPI = RequestAPI<UserAPI>()
    
    
    var maximumSelectTagCount = 3
    
    var tags: [LikeTag] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        collectionViewGridLayout.itemHeight = 28
        collectionViewGridLayout.itemInterval = 10
        collectionViewGridLayout.itemLineInterval = 10
        collectionViewGridLayout.sectionInsert = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        
        let hub = MBProgressHUD.showAdded(to: view, animated: true)
        
        userAPI.request(.userConfig(type: 1), type: HotChatResponse<[LikeTag]>.self)
            .subscribe(onSuccess: { [weak self] response in
                if response.isSuccessd {
                    self?.tags = response.data!
                    self?.collectionView.reloadData()
                } else {
                    self?.show(response.msg)
                }
                hub.hide(animated: true)
            }, onError: { [weak self]  error in
                self?.show(error.localizedDescription)
                hub.hide(animated: true)
            })
            .disposed(by: rx.disposeBag)

    }
    
}

extension UserInfoLikeObjectViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tags.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(for: indexPath, cellType: UserInfoLikeObjectCell.self)
        
        let tag = tags[indexPath.item]
        
        if tag.isCheck {
            cell.contentView.backgroundColor = .theme
            cell.titleLabel.textColor = .white
        }
        else {
            cell.contentView.backgroundColor = .normalGray
            cell.titleLabel.textColor = .textGray
        }
        
        cell.titleLabel.text = tags[indexPath.item].label
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        var tag = tags[indexPath.item]
        
        tag.isCheck = !tag.isCheck
        
        tags[indexPath.item] = tag
       
        let selectedTags = tags.filter {$0.isCheck }
        
        if selectedTags.count > maximumSelectTagCount {
            tag.isCheck = false
            tags[indexPath.item] = tag
            show("最多选择\(maximumSelectTagCount)项")
            return
        }
        
        collectionView.reloadData()
        
    }
    
    
    @IBAction func submitButtonDidTag() {
        
        let selectedTags = tags.filter {$0.isCheck }
        
        if selectedTags.isEmpty {
            show("至少选择一项")
            return
        }
        
        let label = selectedTags
            .map {
                $0.id.description
            }
            .joined(separator: ",")
        
        let params: [String : Any] = [
            "type" : 2,
            "label" : label
        ]
        
        let hub = MBProgressHUD.showAdded(to: view, animated: true)
        userAPI.request(.editUser(value: params), type: HotChatResponse<User>.self)
            .subscribe(onSuccess: { [weak self] response in
                if response.isSuccessd {
                    self?.onUpdated.call(response.data!)
                } else {
                    self?.show(response.msg)
                }
                hub.hide(animated: true)
            }, onError: { [weak self]  error in
                self?.show(error.localizedDescription)
                hub.hide(animated: true)
            })
            .disposed(by: rx.disposeBag)
    }
    
}
