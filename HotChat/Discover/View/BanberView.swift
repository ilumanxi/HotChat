//
//  BanberView.swift
//  HotChat
//
//  Created by 风起兮 on 2021/3/3.
//  Copyright © 2021 风起兮. All rights reserved.
//

import UIKit
import FSPagerView
import URLNavigator

class BanberHeaderView: UITableViewHeaderFooterView {
    var banners: [Banner] = [] {
        didSet {
            bannerView.itemSize = bannerView.frame.insetBy(dx: 12, dy: 5).size
            bannerView.reloadData()
        }
    }

    var bannerView: FSPagerView
    
    override init(reuseIdentifier: String?) {
        bannerView =  FSPagerView(frame: .zero)
//        bannerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        bannerView.bounces = false
        bannerView.itemSize = FSPagerViewAutomaticSize // Fill parent
        bannerView.interitemSpacing = 24
        bannerView.register(FSPagerViewCell.self, forCellWithReuseIdentifier: "FSPagerViewCell")
        bannerView.backgroundColor = .clear
        bannerView.automaticSlidingInterval = 3
        bannerView.isInfinite = true
        super.init(reuseIdentifier: reuseIdentifier)
        bannerView.delegate = self
        bannerView.dataSource = self
        contentView.addSubview(bannerView)
    }
    
    override func layoutSubviews() {
        
        super.layoutSubviews()
        bannerView.frame = bounds
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension BanberHeaderView: FSPagerViewDataSource, FSPagerViewDelegate {
    
    
    func numberOfItems(in pagerView: FSPagerView) -> Int {
        return banners.count
    }
    
    func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        let model = banners[index]
        
        let cell = pagerView.dequeueReusableCell(withReuseIdentifier: "FSPagerViewCell", at: index)
        cell.contentView.layer.shadowColor = UIColor.clear.cgColor
        cell.imageView?.contentMode = .scaleToFill
        cell.imageView?.kf.setImage(with: URL(string: model.img))
        return cell
    }
    
    func pagerView(_ pagerView: FSPagerView, didSelectItemAt index: Int) {
        
        let model = banners[index]
        guard let url = URL(string: model.url) else { return }
        
        Navigator.share.push(url)
    }
    
}

class BanberView: UICollectionReusableView {
    
    
    var banners: [Banner] = [] {
        didSet {
            bannerView.itemSize = bannerView.frame.insetBy(dx: 12, dy: 5).size
            bannerView.reloadData()
        }
    }

    var bannerView: FSPagerView
    
    override init(frame: CGRect) {
        
        
        bannerView =  FSPagerView(frame: CGRect(origin: .zero, size: frame.size))
        bannerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        bannerView.bounces = false
        bannerView.itemSize = FSPagerViewAutomaticSize // Fill parent
        bannerView.interitemSpacing = 24
        bannerView.register(FSPagerViewCell.self, forCellWithReuseIdentifier: "FSPagerViewCell")
        bannerView.backgroundColor = .clear
        bannerView.automaticSlidingInterval = 3
        bannerView.isInfinite = true
        
        super.init(frame: frame)
        bannerView.delegate = self
        bannerView.dataSource = self
        addSubview(bannerView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension BanberView: FSPagerViewDataSource, FSPagerViewDelegate {
    
    
    func numberOfItems(in pagerView: FSPagerView) -> Int {
        return banners.count
    }
    
    func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        let model = banners[index]
        
        let cell = pagerView.dequeueReusableCell(withReuseIdentifier: "FSPagerViewCell", at: index)
        cell.contentView.layer.shadowColor = UIColor.clear.cgColor
        cell.imageView?.kf.setImage(with: URL(string: model.img))
        return cell
    }
    
    func pagerView(_ pagerView: FSPagerView, didSelectItemAt index: Int) {
        
        let model = banners[index]
        guard let url = URL(string: model.url) else { return }
        
        Navigator.share.push(url)
    }
    
}

extension FSPagerViewCell {
    
    open override var isHighlighted: Bool {
        didSet {
            
        }
    }
    
    open override var isSelected: Bool {
        didSet {
            
        }
    }
}
