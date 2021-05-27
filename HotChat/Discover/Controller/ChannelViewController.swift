//
//  ChannelViewController.swift
//  HotChat
//
//  Created by 风起兮 on 2020/10/15.
//  Copyright © 2020 风起兮. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import MJRefresh
import Kingfisher
import FSPagerView
import URLNavigator
import Blueprints


class ChannelViewController: UIViewController, LoadingStateType, IndicatorDisplay {
    
    var state: LoadingState = .initial {
        didSet {
            showOrHideIndicator(loadingState: state)
        }
    }
    
    var channel: Channel!
    
    var data: [User] = [] {
        didSet {
            collectionView.reloadData()
        }
    }
    
    var pageIndex: Int = 1
    
    let refreshPageIndex: Int = 1
    
    let loadSignal = PublishSubject<(type: String, labelId: Int, index: Int)>()
    
    let discoverAPI = Request<DiscoverAPI>()
    
    var collectionView: UICollectionView!
    
    let bannerAPI = Request<BannerAPI>()
    
    var headerViewHeight: CGFloat {
        return (view.bounds.width / (2 / 0.6)).rounded(.down)
    }
    
    var banners: [Banner] = [] {
        didSet {
            collectionView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()

        loadSignal
            .subscribe(onNext: requestData)
            .disposed(by: rx.disposeBag)
        
        
        collectionView.mj_header = MJRefreshNormalHeader { [weak self] in
            self?.refreshData()
        }
        
        collectionView.mj_footer = MJRefreshAutoNormalFooter{ [weak self] in
            self?.loadMoreData()
        }
        
        state = .loadingContent
        refreshData()
    }
    
    
    
    func setupUI()  {
        
        let verticalBlueprintLayout = VerticalBlueprintLayout(
          itemsPerRow: itemsPerRow,
          height: 100,
          minimumInteritemSpacing: minimumInteritemSpacing,
          minimumLineSpacing: minimumLineSpacing,
          sectionInset: sectionInsets,
          stickyHeaders: false,
          stickyFooters: false
        )
        
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: verticalBlueprintLayout)
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleWidth]
        collectionView.backgroundColor = .groupTableViewBackground
        view.addSubview(collectionView)
        
        collectionView.register(UINib(nibName: "UserCardCell", bundle: nil), forCellWithReuseIdentifier: "UserCardCell")
        collectionView.register(BanberView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "BanberView")
        
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    

    
    func endRefreshing(noContent: Bool = false) {
        collectionView.reloadData()
        collectionView.mj_header?.endRefreshing()
        if noContent {
            collectionView.mj_footer?.endRefreshingWithNoMoreData()
        }
        else {
            collectionView.mj_footer?.endRefreshing()
        }
    }
    
    func refreshData() {
        loadSignal.onNext((type: channel.type, labelId: channel.labelId, index: refreshPageIndex))
        
        bannerAPI.request(.bannerList(type: 1), type: Response<[Banner]>.self)
            .verifyResponse()
            .subscribe(onSuccess: { [weak self] response in
                self?.banners = response.data ?? []
            }, onError: nil)
            .disposed(by: rx.disposeBag)
    }

    func loadMoreData() {
        loadSignal.onNext((type: channel.type, labelId: channel.labelId, index: pageIndex))
    }
    
    func requestData(_ page: (type: String, labelId: Int, index: Int)) {
        if data.isEmpty {
            state = .refreshingContent
        }
         
        loadData(page)
            .verifyResponse()
            .subscribe(onSuccess: handlerReponse, onError: handlerError)
            .disposed(by: rx.disposeBag)
            
    }
    
    func loadData(_ page: (type: String, labelId: Int, index: Int)) -> Single<Response<Pagination<User>>> {
        
        return discoverAPI.request(.discoverList(type: page.type, labelId: page.labelId, page: page.index)).verifyResponse()
    }
    
    func handlerReponse(_ response: Response<Pagination<User>>){

        guard let page = response.data, let data = page.list else {
            return
        }
        
        if page.page == 1 {
            refreshData(data)
        }
        else {
            appendData(data)
        }
        
        if !data.isEmpty {
            pageIndex = page.page + 1
        }
                
        state = self.data.isEmpty ? .noContent : .contentLoaded
        
        endRefreshing(noContent: !page.hasNext)
        
    }
    
    func refreshData(_ data: [User]) {
        if !data.isEmpty {
            self.data = data
        }
    }
    
    func appendData(_ data: [User]) {
        self.data = self.data + data
    }
    
    func handlerError(_ error: Error) {
        if data.isEmpty {
            state = .error
        }
        endRefreshing()
       
    }

}
extension ChannelViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var itemsPerRow: CGFloat {
        return 2
    }
    
    var minimumInteritemSpacing: CGFloat {
        return 5
    }
    
    var minimumLineSpacing: CGFloat {
        return 5
    }
    
    var sectionInsets: UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
    }
    
//    func configureVerticalLayout() {
//        let verticalBlueprintLayout = VerticalBlueprintLayout(
//          itemsPerRow: itemsPerRow,
//          height: 100,
//          minimumInteritemSpacing: minimumInteritemSpacing,
//          minimumLineSpacing: minimumLineSpacing,
//          sectionInset: sectionInsets,
//          stickyHeaders: false,
//          stickyFooters: false
//        )
//
//        UIView.animate(withDuration: 0.5) { [weak self] in
//            self?.collectionView.collectionViewLayout = verticalBlueprintLayout
//            self?.view.setNeedsLayout()
//            self?.view.layoutIfNeeded()
//        }
//    }
    
    func layoutCellCalculatedSize(forItemAt indexPath: IndexPath) -> CGSize {
        
//        let layoutCellForSize = collectionView.dequeueReusableCell(for: indexPath, cellType: UserCardCell.self)
//        let data =  data[indexPath.item]
//        layoutCellForSize.textLabel.text = data.content
//        layoutCellForSize.setNeedsLayout()
//        layoutCellForSize.layoutIfNeeded()
        let cellWidth = widthForCellInCurrentLayout()
//        let cellHeight: CGFloat = 0
//        let cellTargetSize = CGSize(width: cellWidth, height: cellHeight)
//        let cellSize = layoutCellForSize.contentView.systemLayoutSizeFitting(
//            cellTargetSize,
//            withHorizontalFittingPriority: UILayoutPriority(900),
//            verticalFittingPriority: .fittingSizeLevel)
        return CGSize(width: cellWidth, height: cellWidth + 46)
    }

    func widthForCellInCurrentLayout() -> CGFloat {
        var cellWidth = collectionView.frame.size.width - (sectionInsets.left + sectionInsets.right)
        if itemsPerRow > 1 {
            cellWidth -= minimumInteritemSpacing * (itemsPerRow - 1)
        }
        return floor(cellWidth / itemsPerRow)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let bannerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, for: indexPath, viewType: BanberView.self)
        bannerView.banners = banners
        
        return bannerView
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        

        let cell = collectionView.dequeueReusableCell(for: indexPath, cellType: UserCardCell.self)
        cell.layer.cornerRadius = 8
        
        cell.setUser(data[indexPath.item])
        
        return cell
    }
    

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        if banners.isEmpty {
            return .zero
        }
        return CGSize(width: collectionView.frame.width, height: headerViewHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return layoutCellCalculatedSize(forItemAt: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let vc = UserInfoViewController()
        vc.user  = data[indexPath.item]
        navigationController?.pushViewController(vc, animated: true)
    }
    
}


