//
//  UserInfoHeaderView.swift
//  HotChat
//
//  Created by 风起兮 on 2020/9/8.
//  Copyright © 2020 风起兮. All rights reserved.
//

import UIKit
import FSPagerView
import Kingfisher

class UserInfoHeaderView: UIView, FSPagerViewDataSource, FSPagerViewDelegate {
    
    private let reuseIdentifier = "cell"
    
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var pagerView: FSPagerView!
    
    @IBOutlet weak var pageControl: UIPageControl!
    
    
    @IBOutlet weak var nicknameLabel: UILabel!
    
    
    @IBOutlet weak var locationLabel: UILabel!
    
    
    @IBOutlet weak var statusLabel: UILabel!
    
    
    @IBOutlet weak var stackView: UIStackView!
    
    
    @IBOutlet weak var authenticationButton: UIButton!
    
    
    @IBOutlet weak var followButton: UIButton!
    
    
    @IBOutlet weak var sexView: LabelView!
    
    
    @IBOutlet weak var followView: LabelView!
    
    
    let onFollowButtonTapped = Delegate<UserInfoHeaderView, Void>()
    
    var user: User! {
        didSet {
            reloadData()
        }
    }
    
    var count: Int {
        guard let user = user else {
            return 0
        }
        return user.photoList.count  + 1
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        pagerView.itemSize = FSPagerViewAutomaticSize // Fill parent
        pagerView.register(FSPagerViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
    }
    
    
    func numberOfItems(in pagerView: FSPagerView) -> Int {
        return count
    }
    
    
    func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        
        let cell = pagerView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, at: index)
        
        configureCell(cell, for: index)
        
        return cell
    }
    
    func configureCell(_ cell: FSPagerViewCell, for index: Int) {
        
        if index == 0 {
            cell.imageView?.kf.setImage(with: URL(string: user.headPic))
        }
        else {
            
            let urlString = user.photoList[index - 1].picUrl
            cell.imageView?.kf.setImage(with: URL(string: urlString))
        }
        
    }
    
    func pagerViewWillEndDragging(_ pagerView: FSPagerView, targetIndex: Int) {
        pageControl.currentPage = targetIndex
        let isHidden = targetIndex != 0
        stackView.isHidden = isHidden
    }
    
    
    func reloadData() {
        pageControl.numberOfPages = count
        pagerView.reloadData()
        nicknameLabel.text = user.nick
        sexView.setUser(user)
        followView.text = user.userFollowNum.description
        
        authenticationButton.alpha = 0
        followButton.alpha = user.isFollow ? 1 : 0
    }
    
    @IBAction func followAction(_ sender: Any) {
        onFollowButtonTapped.call(self)
    }
    
}
