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
    
    
    let API = RequestAPI<Account>()
    
    
    var tags: [LikeTag] = []
    
    fileprivate let maximumSelectTagCount = 3
    
    var selectedTags: [String] = [] {
        didSet {
            collectionView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        collectionViewGridLayout.itemHeight = 28
        collectionViewGridLayout.itemInterval = 10
        collectionViewGridLayout.itemLineInterval = 10
        collectionViewGridLayout.sectionInsert = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        
        let hub = MBProgressHUD.showAdded(to: view.window!, animated: true)
        
        
        API.request(.labelList, type: HotChatResponse<[LikeTag]>.self)
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
        
        if selectedTags.contains(tag.label) {
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
        
        let tag = tags[indexPath.item]
        
        if selectedTags.contains(tag.label) {
            
            selectedTags.removeAll { $0 == tag.label }
        }
        else if selectedTags.count >= maximumSelectTagCount {
            view.makeToast("最多选择三项", duration: 3.0, position: .bottom)
        }
        else {
            selectedTags.append(tag.label)
        }
    }
    
    
}
