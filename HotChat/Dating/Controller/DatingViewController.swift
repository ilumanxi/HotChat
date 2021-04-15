//
//  EngagementViewController.swift
//  HotChat
//
//  Created by 风起兮 on 2021/4/15.
//  Copyright © 2021 风起兮. All rights reserved.
//

import UIKit
import Kingfisher
import RxCocoa
import RxSwift
import MJRefresh
import MagazineLayout


class DatingViewController: UIViewController, LoadingStateType, IndicatorDisplay  {
    
    var state: LoadingState = .initial {
        didSet {
            showOrHideIndicator(loadingState: state)
        }
    }
    
    @IBOutlet weak var backgroundImageView: UIImageView!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    let layout = MagazineLayout()
    
    var pageIndex: Int = 1
    
    let refreshPageIndex: Int = 1
    
    let loadSignal = PublishSubject<Int>()
    
    let videoDatingAPI = Request<VideoDatingAPI>()
        
    var dynamics: [Dynamic] = []
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        return refreshControl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.refreshControl = refreshControl

        collectionView.setCollectionViewLayout(layout, animated: false)
        
        hbd_barAlpha = 0
        navigationItem.leftBarButtonItem?.setTitleTextAttributes(UINavigationBar.appearance().titleTextAttributes, for: .normal)
        
        let url = Bundle.main.url(forResource: "dating", withExtension: "webp")
        
        backgroundImageView.kf.setImage(with: url)
        
        collectionView.register(UINib(nibName: "DatingViewCell", bundle: nil), forCellWithReuseIdentifier: "DatingViewCell")
        
        collectionView.backgroundColor = UIColor.clear
        
        loadSignal
            .subscribe(onNext: requestData)
            .disposed(by: rx.disposeBag)
        
        refreshControl.rx.controlEvent(.valueChanged)
            .subscribe(onNext: { [weak self] _ in
                self?.refreshData()
            })
            .disposed(by: rx.disposeBag)
        
//        collectionView.mj_header = MJRefreshNormalHeader { [weak self] in
//            self?.refreshData()
//        }
        
        collectionView.mj_footer = MJRefreshAutoNormalFooter{ [weak self] in
            self?.loadMoreData()
        }
        
        refreshData()
    }

    
    func endRefreshing(noContent: Bool = false) {
        collectionView.reloadData()
//        collectionView.mj_header?.endRefreshing()
        
        if refreshControl.isRefreshing {
            refreshControl.endRefreshing()
        }
        
        if noContent {
            collectionView.mj_footer?.endRefreshingWithNoMoreData()
        }
        else {
            collectionView.mj_footer?.endRefreshing()
        }
        
    }
    
    func refreshData() {
        loadSignal.onNext(refreshPageIndex)
    }
        
    func loadMoreData() {
        loadSignal.onNext(pageIndex)
    }
    
    func requestData(_ page: Int) {
        if dynamics.isEmpty {
            state = .refreshingContent
        }
        loadData(page)
            .verifyResponse()
            .subscribe(onSuccess: handlerReponse, onError: handlerError)
            .disposed(by: rx.disposeBag)
            
    }
    
    func loadData(_ page: Int) -> Single<Response<Pagination<Dynamic>>> {
         
        return videoDatingAPI.request(.videoList(page))
    }
    
    func handlerReponse(_ response: Response<Pagination<Dynamic>>){

        guard let page = response.data, let data = page.list else {
            return
        }
        
        if page.page == 1 {
            refreshData(data)
        }
        else {
            appendData(data)
        }
                
        state = dynamics.isEmpty ? .noContent : .contentLoaded
        
        if !data.isEmpty {
            pageIndex = page.page + 1
        }
       
        endRefreshing(noContent: !page.hasNext)
    }
    
    func refreshData(_ data: [Dynamic]) {
        if !data.isEmpty {
            dynamics = data
           
        }
    }
    
    func appendData(_ data: [Dynamic]) {
        dynamics = dynamics + data
    }
    
    func handlerError(_ error: Error) {
        if dynamics.isEmpty {
            state = .error
        }
        endRefreshing()
       
    }


}

extension DatingViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.dynamics.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(for: indexPath, cellType: DatingViewCell.self)
        cell.set(dynamics[indexPath.item])
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let vc = DatingDetailViewController()
        vc.dynamic = self.dynamics[indexPath.item]
        self.navigationController?.pushViewController(vc, animated: true)
    }

}


// MARK: UICollectionViewDelegateMagazineLayout

extension DatingViewController: UICollectionViewDelegateMagazineLayout {
    
    var itemsPerRow: CGFloat {
        return 2
    }
    
    var minimumInteritemSpacing: CGFloat {
        return 5
    }
    
    var minimumLineSpacing: CGFloat {
        return 12
    }
    
    var sectionInsets: UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 10, bottom: 0, right: 12)
    }
    
    
    func layoutCellCalculatedSize(forItemAt indexPath: IndexPath) -> CGSize {
        
      
        let cellWidth = widthForCellInCurrentLayout()
      
        return CGSize(width: cellWidth, height: cellWidth + 65)
    }

    func widthForCellInCurrentLayout() -> CGFloat {
        var cellWidth = collectionView.frame.size.width - (sectionInsets.left + sectionInsets.right)
        if itemsPerRow > 1 {
            cellWidth -= minimumInteritemSpacing * (itemsPerRow - 1)
        }
        return floor(cellWidth / itemsPerRow)
    }

 func collectionView(
   _ collectionView: UICollectionView,
   layout collectionViewLayout: UICollectionViewLayout,
   sizeModeForItemAt indexPath: IndexPath)
   -> MagazineLayoutItemSizeMode
 {
    let size = layoutCellCalculatedSize(forItemAt: indexPath)
    
    return MagazineLayoutItemSizeMode(widthMode: .halfWidth, heightMode: .static(height: size.height))
 }

 func collectionView(
   _ collectionView: UICollectionView,
   layout collectionViewLayout: UICollectionViewLayout,
   visibilityModeForHeaderInSectionAtIndex index: Int)
   -> MagazineLayoutHeaderVisibilityMode
 {
   return .hidden
 }

 func collectionView(
   _ collectionView: UICollectionView,
   layout collectionViewLayout: UICollectionViewLayout,
   visibilityModeForFooterInSectionAtIndex index: Int)
   -> MagazineLayoutFooterVisibilityMode
 {
   return .hidden
 }

 func collectionView(
   _ collectionView: UICollectionView,
   layout collectionViewLayout: UICollectionViewLayout,
   visibilityModeForBackgroundInSectionAtIndex index: Int)
   -> MagazineLayoutBackgroundVisibilityMode
 {
   return .hidden
 }

 func collectionView(
   _ collectionView: UICollectionView,
   layout collectionViewLayout: UICollectionViewLayout,
   horizontalSpacingForItemsInSectionAtIndex index: Int)
   -> CGFloat
 {
   return minimumInteritemSpacing
 }

 func collectionView(
   _ collectionView: UICollectionView,
   layout collectionViewLayout: UICollectionViewLayout,
   verticalSpacingForElementsInSectionAtIndex index: Int)
   -> CGFloat
 {
   return minimumLineSpacing
 }

 func collectionView(
   _ collectionView: UICollectionView,
   layout collectionViewLayout: UICollectionViewLayout,
   insetsForSectionAtIndex index: Int)
   -> UIEdgeInsets
 {
    return sectionInsets
 }

 func collectionView(
   _ collectionView: UICollectionView,
   layout collectionViewLayout: UICollectionViewLayout,
   insetsForItemsInSectionAtIndex index: Int)
   -> UIEdgeInsets
 {
   return .zero
 }

 func collectionView(
   _ collectionView: UICollectionView,
   layout collectionViewLayout: UICollectionViewLayout,
   finalLayoutAttributesForRemovedItemAt indexPath: IndexPath,
   byModifying finalLayoutAttributes: UICollectionViewLayoutAttributes)
 {
   // Fade and drop out
   finalLayoutAttributes.alpha = 0
   finalLayoutAttributes.transform = .init(scaleX: 0.2, y: 0.2)
 }

}

