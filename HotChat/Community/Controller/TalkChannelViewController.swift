//
//  TalkChannelViewController.swift
//  HotChat
//
//  Created by 风起兮 on 2021/3/24.
//  Copyright © 2021 风起兮. All rights reserved.
//

import UIKit
import Aquaman
//import Blueprints
import RxSwift
import RxCocoa
import MJRefresh
import SnapKit
import DGCollectionViewLeftAlignFlowLayout



class TalkChannelViewController: UIViewController, AquamanChildViewController, IndicatorDisplay, LoadingStateType {
    
    var state: LoadingState = .initial {
        didSet {
            if isViewLoaded  && state != oldValue {
                showOrHideIndicator(loadingState: state)
            }
        }
    }
    
    var pageIndex: Int = 1
    
    let refreshPageIndex: Int = 1
    
    let loadSignal = PublishSubject<Int>()
    
    let channel: Channel
    
    init(channel: Channel) {
        self.channel = channel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func aquamanChildScrollView() -> UIScrollView {
        return collectionView
    }
    
    let discoverAPI = Request<DiscoverAPI>()
    
    var collectionView: UICollectionView!
    
    var data: [TalkChannel] = []
    
    let onFinished = Delegate<Void, Void>()
    
    override func loadView() {
        super.loadView()
        setupUI()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureVerticalLayout()
        
        loadSignal
            .subscribe(onNext: requestData)
            .disposed(by: rx.disposeBag)
        
        collectionView.mj_header = MJRefreshNormalHeader { [weak self] in
            self?.refreshData()
        }
        
        collectionView.mj_footer = MJRefreshAutoNormalFooter{ [weak self] in
            self?.loadMoreData()
        }
        
        refreshData()
    }

    
    func setupUI()  {
        
        let layout = DGCollectionViewLeftAlignFlowLayout()
        
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
//        collectionView.autoresizingMask = [.flexibleWidth, .flexibleWidth]
        collectionView.backgroundColor = .groupTableViewBackground
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { maker in
            maker.edges.equalToSuperview()
        }
        
        configureVerticalLayout()
        
        collectionView.register(UINib(nibName: "TalkChannelCell", bundle: nil), forCellWithReuseIdentifier: "TalkChannelCell")
        collectionView.register(BannerViewCell.self, forCellWithReuseIdentifier: "BannerViewCell")
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        
    }
    
}

extension TalkChannelViewController {
    
    func endRefreshing(noContent: Bool = false) {
        collectionView.reloadData()
        collectionView.mj_header?.endRefreshing()
        if noContent {
            collectionView.mj_footer?.endRefreshingWithNoMoreData()
        }
        else {
            collectionView.mj_footer?.endRefreshing()
        }
        
        onFinished.call()
    }
    
    func refreshData() {
        loadSignal.onNext(refreshPageIndex)
    }
    
    func loadMoreData() {
        loadSignal.onNext(pageIndex)
    }
    
    func requestData(_ page: Int) {
        if data.isEmpty {
            state = .refreshingContent
        }
        loadData(page)
            .verifyResponse()
            .subscribe(onSuccess: handlerReponse, onError: handlerError)
            .disposed(by: rx.disposeBag)
            
    }
    
    func loadData(_ page: Int) -> Single<Response<Pagination<TalkChannel>>> {
         
        return  discoverAPI.request(.homeList(type: channel.type, labelId: channel.labelId, page: page))
    }
    
    func handlerReponse(_ response: Response<Pagination<TalkChannel>>){

        guard let page = response.data, let data = page.list else {
            return
        }
        
        if page.page == 1 {
            refreshData(data)
        }
        else {
            appendData(data)
        }
                
        state = self.data.isEmpty ? .noContent : .contentLoaded
        
        if !data.isEmpty {
            pageIndex = page.page + 1
        }
        
        endRefreshing(noContent: !page.hasNext)
    }
    
    func refreshData(_ data: [TalkChannel]) {
        if !data.isEmpty {
            self.data = data
        }
    }
    
    func appendData(_ data: [TalkChannel]) {
        self.data.append(contentsOf: data)
    }
    
    func handlerError(_ error: Error) {
        if data.isEmpty {
            state = .error
        }
        endRefreshing()
       
    }
}

extension TalkChannelViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
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
        return UIEdgeInsets(top: 12, left: 14, bottom: 49, right: 14)
    }
    
    func configureVerticalLayout() {
        
        guard let collectionViewFlowLayout = self.collectionView.collectionViewLayout as? UICollectionViewFlowLayout  else { return  }
        collectionViewFlowLayout.minimumLineSpacing = minimumLineSpacing
        collectionViewFlowLayout.minimumInteritemSpacing = minimumInteritemSpacing
        collectionViewFlowLayout.sectionInset = sectionInsets
        
        
//
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
    }
    
    func layoutCellCalculatedSize(forItemAt indexPath: IndexPath) -> CGSize {
        
        let model = data[indexPath.item]
        
        switch model.type {
        case .user:
            let cellWidth = widthForCellInCurrentLayout()
            return CGSize(width: cellWidth, height: cellWidth)
        case .banner:
            let cellWidth = collectionView.frame.size.width - (sectionInsets.left + sectionInsets.right)
            let sacle: CGFloat = 345.0 / 98.0
            return CGSize(width: cellWidth, height: cellWidth / sacle + 8)
        default:
            return .zero
        }
    }

    func widthForCellInCurrentLayout() -> CGFloat {
        let cellWidth = collectionView.frame.size.width - sectionInsets.left - sectionInsets.right - minimumInteritemSpacing
//        if itemsPerRow > 1 {
//            cellWidth -= minimumInteritemSpacing * (itemsPerRow - 1)
//        }
        return floor(cellWidth / itemsPerRow)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return minimumLineSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return minimumInteritemSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let model = data[indexPath.item]
        
        switch model.type {
        case .user:
            let cell = collectionView.dequeueReusableCell(for: indexPath, cellType: TalkChannelCell.self)
            cell.set(model: model.userInfo!)
            return cell
        case .banner:
            let cell = collectionView.dequeueReusableCell(for: indexPath, cellType: BannerViewCell.self)
            cell.banners = model.bannerList
            return cell
        default:
            return UICollectionViewCell()
        }
    }
    

    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return layoutCellCalculatedSize(forItemAt: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let model = data[indexPath.item]
        
        if case .user =  model.type {
            let vc = UserInfoViewController()
            vc.user = model.userInfo!
            navigationController?.pushViewController(vc, animated: true)
        }
        
    }
    
}
