//
//  BannerViewCell.swift
//  HotChat
//
//  Created by 风起兮 on 2021/3/24.
//  Copyright © 2021 风起兮. All rights reserved.
//

import UIKit
import FSPagerView
import URLNavigator



class BannerViewCell: UICollectionViewCell {
    
    var banners: [Banner] = [] {
        didSet {
            pageControl.numberOfPages = banners.count
            bannerView.reloadData()
        }
    }

    var bannerView: FSPagerView
    
    var pageControl: UIPageControl
    
    override init(frame: CGRect) {
        
        bannerView =  FSPagerView(frame: CGRect(origin: .zero, size: frame.size))
        bannerView.bounces = false
//        bannerView.isScrollEnabled = false
        bannerView.itemSize = FSPagerViewAutomaticSize // Fill parent
        bannerView.interitemSpacing = 24
        bannerView.register(FSPagerViewCell.self, forCellWithReuseIdentifier: "FSPagerViewCell")
        bannerView.backgroundColor = .clear
        bannerView.automaticSlidingInterval = 3
        bannerView.isInfinite = true
        
        pageControl = UIPageControl()
//        pageControl.hidesForSinglePage = true
        
        super.init(frame: frame)
        layer.cornerRadius = 10
        bannerView.delegate = self
        bannerView.dataSource = self
        contentView.addSubview(bannerView)
        contentView.addSubview(pageControl)
        
        bannerView.snp.makeConstraints { maker in
            maker.leading.trailing.equalToSuperview()
            maker.top.equalToSuperview().offset(4)
            maker.bottom.equalToSuperview().offset((-4))
        }
        
        pageControl.snp.makeConstraints { maker in
            maker.centerX.equalToSuperview()
            maker.bottom.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension BannerViewCell: FSPagerViewDataSource, FSPagerViewDelegate {
    
    
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
    
    func  pagerView(_ pagerView: FSPagerView, willDisplay cell: FSPagerViewCell, forItemAt index: Int) {
        pageControl.currentPage = index
    }
    
    func pagerViewWillEndDragging(_ pagerView: FSPagerView, targetIndex: Int) {
        pageControl.currentPage = targetIndex
    }
    
}
