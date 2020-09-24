//
//  UserInfoLikeObjectViewController.swift
//  HotChat
//
//  Created by 风起兮 on 2020/9/2.
//  Copyright © 2020 风起兮. All rights reserved.
//

import UIKit
import Toast_Swift

class UserInfoLikeObjectViewController: UIViewController {
    
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    @IBOutlet weak var collectionViewGridLayout: CollectionViewGridLayout!
    
    
    var tags: [String] = []
    
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

        tags = [
            "女生范",
            "爱唱歌",
            "逗比",
            "声音甜",
            "性格开朗",
            "老司机",
            "游戏控",
            "小可爱",
            "爱跳舞"
        ]
    }
    
}

extension UserInfoLikeObjectViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tags.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(for: indexPath, cellType: UserInfoLikeObjectCell.self)
        
        let tag = tags[indexPath.item]
        
        if selectedTags.contains(tag) {
            cell.contentView.backgroundColor = .theme
            cell.titleLabel.textColor = .white
        }
        else {
            cell.contentView.backgroundColor = .normalGray
            cell.titleLabel.textColor = .textGray
        }
        
        cell.titleLabel.text = tags[indexPath.item]
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let tag = tags[indexPath.item]
        
        if selectedTags.contains(tag) {
            
            selectedTags.removeAll { $0 == tag }
        }
        else if selectedTags.count >= maximumSelectTagCount {
            view.makeToast("最多选择三项", duration: 3.0, position: .bottom)
        }
        else {
            selectedTags.append(tag)
        }
    }
    
    
}
