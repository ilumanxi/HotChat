//
//  UserInfoLikeObjectViewController.swift
//  HotChat
//
//  Created by 风起兮 on 2020/9/2.
//  Copyright © 2020 风起兮. All rights reserved.
//

import UIKit
import MBProgressHUD



class UserInfoLikeObjectViewController: UIViewController, IndicatorDisplay {
    
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    @IBOutlet weak var collectionViewGridLayout: CollectionViewGridLayout!
    
    
    let onUpdated = Delegate<User, Void>()
     
    
    let userAPI = RequestAPI<UserAPI>()
    
    
    var maximumCount = 3
    
    var labels: [LikeTag] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        collectionViewGridLayout.itemHeight = 28
        collectionViewGridLayout.itemInterval = 10
        collectionViewGridLayout.itemLineInterval = 10
        collectionViewGridLayout.sectionInsert = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        
        let hub = MBProgressHUD.showAdded(to: view, animated: true)
        
        userAPI.request(.userConfig(type: 1), type: Response<[LikeTag]>.self)
            .subscribe(onSuccess: { [weak self] response in
                if response.isSuccessd {
                    self?.labels = response.data!
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
        return labels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(for: indexPath, cellType: UserInfoLikeObjectCell.self)
        
        let tag = labels[indexPath.item]
        
        if tag.isCheck {
            cell.contentView.backgroundColor = .theme
            cell.titleLabel.textColor = .white
        }
        else {
            cell.contentView.backgroundColor = .normalGray
            cell.titleLabel.textColor = .textGray
        }
        
        cell.titleLabel.text = labels[indexPath.item].label
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let isCheck = !labels[indexPath.row].isCheck
        labels.modifyElement(at: indexPath.item) { $0.isCheck  = isCheck }
        
        let selectedLabels =  labels.filter{ $0.isCheck }
        
        if  selectedLabels.count > maximumCount {
            labels.modifyElement(at: indexPath.item) { $0.isCheck  = false }
            show("最多选择\(maximumCount)项")
        }
        
        collectionView.reloadData()
    }
    
    
    @IBAction func submitButtonDidTag() {
        
        let selectedTags = labels.filter {$0.isCheck }
        
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
        userAPI.request(.editUser(value: params), type: Response<User>.self)
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
