//
//  CommunityViewController.swift
//  HotChat
//
//  Created by 风起兮 on 2020/9/9.
//  Copyright © 2020 风起兮. All rights reserved.
//

import UIKit
import HBDNavigationBar
import SegementSlide
import RxCocoa
import RxSwift
import NSObject_Rx
import Reusable
import Blueprints
import Kingfisher
import MJRefresh
import HandyJSON



class CommunityViewController: UIViewController, LoadingStateType, IndicatorDisplay {
    
    
    var state: LoadingState = .initial {
        didSet {
            if isViewLoaded {
                showOrHideIndicator(loadingState: state)
            }
        }
    }
    
    var pageIndex: Int = 1
    
    let refreshPageIndex: Int = 1
    
    let loadSignal = PublishSubject<Int>()
    
    let dynamicAPI = Request<DynamicAPI>()
    
    var dynamics: [Dynamic] = []
    
    @IBOutlet weak var collectionView: UICollectionView!
    
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.backgroundColor = .groupTableViewBackground
        
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
        
        state = .loadingContent
        collectionView.mj_header?.beginRefreshing()
      
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
            .checkResponse()
            .subscribe(onSuccess: handlerReponse, onError: handlerError)
            .disposed(by: rx.disposeBag)
            
    }
    
    func loadData(_ page: Int) -> Single<Response<Pagination<Dynamic>>> {
         
        return dynamicAPI.request(.recommendList(page), type: Response<Pagination<Dynamic>>.self)
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let cell = sender as? UICollectionViewCell, let indexPath = collectionView.indexPath(for: cell) else {
            return
        }
        
        if let vc = segue.destination as? DynamicDetailViewController {
            
            vc.user = dynamics[indexPath.item].userInfo
        }
        
    }
}


extension CommunityViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    var itemsPerRow: CGFloat {
        return 2
    }
    
    var minimumInteritemSpacing: CGFloat {
        return 10
    }
    
    var minimumLineSpacing: CGFloat {
        return 10
    }
    
    var sectionInsets: UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 10, bottom: 60, right: 10)
    }
    
    func configureVerticalLayout() {
        let verticalBlueprintLayout = VerticalBlueprintLayout(
          itemsPerRow: itemsPerRow,
          height: 100,
          minimumInteritemSpacing: minimumInteritemSpacing,
          minimumLineSpacing: minimumLineSpacing,
          sectionInset: sectionInsets,
          stickyHeaders: false,
          stickyFooters: false
        )

        UIView.animate(withDuration: 0.5) { [weak self] in
            self?.collectionView.collectionViewLayout = verticalBlueprintLayout
            self?.view.setNeedsLayout()
            self?.view.layoutIfNeeded()
        }
    }
    
    func layoutCellCalculatedSize(forItemAt indexPath: IndexPath) -> CGSize {
        
        let layoutCellForSize = collectionView.dequeueReusableCell(for: indexPath, cellType: DynamicViewCell.self)
        let data =  dynamics[indexPath.item]
        layoutCellForSize.textLabel.text = data.content
        layoutCellForSize.setNeedsLayout()
        layoutCellForSize.layoutIfNeeded()
        let cellWidth = widthForCellInCurrentLayout()
        let cellHeight: CGFloat = 0
        let cellTargetSize = CGSize(width: cellWidth, height: cellHeight)
        let cellSize = layoutCellForSize.contentView.systemLayoutSizeFitting(
            cellTargetSize,
            withHorizontalFittingPriority: UILayoutPriority(900),
            verticalFittingPriority: .fittingSizeLevel)
        return cellSize
    }

    func widthForCellInCurrentLayout() -> CGFloat {
        var cellWidth = collectionView.frame.size.width - (sectionInsets.left + sectionInsets.right)
        if itemsPerRow > 1 {
            cellWidth -= minimumInteritemSpacing * (itemsPerRow - 1)
        }
        return floor(cellWidth / itemsPerRow)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dynamics.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        let cell = collectionView.dequeueReusableCell(for: indexPath, cellType: DynamicViewCell.self)
        
        let data =  dynamics[indexPath.item]
        
        cell.textLabel.text = data.content
        cell.imageView.kf.setImage(with: URL(string: data.coverUrl))
        cell.nicknameLabel.text = data.userInfo.nick
        cell.profileImageView.kf.setImage(with: URL(string: data.userInfo.headPic))
        cell.likeLabel.text = data.zanNum.description
        cell.likeButton.isSelected = data.isSelfZan
        cell.layer.cornerRadius = 8
        
        cell.onLikeClicked.delegate(on: self) { (self, _) in
            self.like(data)
        }
        
        return cell
    }
    

    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return layoutCellCalculatedSize(forItemAt: indexPath)
    }
    
    func like(_ dynamic: Dynamic)  {
        
        dynamicAPI.request(.zan(dynamic.dynamicId), type: Response<[String : Any]>.self)
            .subscribe(onSuccess: {[weak self] response in
               
                guard let index = self?.dynamics.lastIndex(where: { $0.dynamicId == dynamic.dynamicId }),
                      let zanNum = response.data?["zanNum"] as? Int,
                      let isSelfZan = response.data?["type"] as? Bool else {
                    return
                }
                
                self?.dynamics.modifyElement(at: index, { element in
                    element.zanNum = zanNum
                    element.isSelfZan = isSelfZan
                })
                self?.collectionView.reloadData()
                
                Log.print(response)
            }, onError: { error in
                Log.print(error)
            })
            .disposed(by: rx.disposeBag)
        
    }
    
}
