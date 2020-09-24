//
//  UserInfoHeaderView.swift
//  HotChat
//
//  Created by 风起兮 on 2020/9/8.
//  Copyright © 2020 风起兮. All rights reserved.
//

import UIKit
import FSPagerView

class UserInfoHeaderView: UIView, FSPagerViewDataSource, FSPagerViewDelegate {
    
    private let reuseIdentifier = "cell"
    
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var pagerView: FSPagerView!
    
    @IBOutlet weak var pageControl: UIPageControl!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        pagerView.itemSize = FSPagerViewAutomaticSize // Fill parent
        pagerView.register(FSPagerViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
    }
    
    
    func numberOfItems(in pagerView: FSPagerView) -> Int {
        return 3
    }
    
    
    func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        
        let cell = pagerView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, at: index)
        cell.backgroundColor = .random
        
        return cell
    }
    
    func pagerViewWillEndDragging(_ pagerView: FSPagerView, targetIndex: Int) {
        pageControl.currentPage = targetIndex
    }
    
}
