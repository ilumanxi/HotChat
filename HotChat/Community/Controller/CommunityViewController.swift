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
    
    func showOrHideIndicator(loadingState: LoadingState, text: String? = nil, image: UIImage? = nil) {
        showOrHideIndicator(loadingState: loadingState, in: self.collectionView, text: text, image: image)
    }
    
    
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
    
    let upgradeAPI = Request<UpgradeAPI>()
    
    var dynamics: [Dynamic] = []
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var phoneBindingView: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GiftManager.shared().getGiftList { _ in
        }
        
        GiftHelper.giftNumConfig(success: { _ in
            
        }, failed: { _ in
            
        })
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            LoginManager.shared.getLocation { _ in
                
            }
        }
        
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
        hiddenPhoneBindingView()
        observeLPhoneState()
        checkUserInitState()
        
        upgradeAPI.request(.updateChannel, type: Response<Upgrade>.self)
            .verifyResponse()
            .subscribe(onSuccess: { [weak self] response in
                let vc = UpgrateViewController(upgrade: response.data!)
                self?.present(vc, animated: true, completion: nil)
            })
            .disposed(by: rx.disposeBag)
      

    }
    
    
    func checkUserInitState() {
        if !LoginManager.shared.user!.isInit {
            let vc = UserInformationViewController.loadFromStoryboard()
            navigationController?.pushViewController(vc, animated: false)
        }
    }
    
    
    func observeLPhoneState() {
        NotificationCenter.default.rx.notification(.userDidChange)
            .subscribe(onNext: { [weak self] _ in
                self?.hiddenPhoneBindingView()
            })
            .disposed(by: rx.disposeBag)
    }
    
    func hiddenPhoneBindingView() {
        if !LoginManager.shared.user!.phone.isEmpty {
            phoneBindingView?.removeFromSuperview()
        }
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
            .verifyResponse()
            .subscribe(onSuccess: handlerReponse, onError: handlerError)
            .disposed(by: rx.disposeBag)
            
    }
    
    func loadData(_ page: Int) -> Single<Response<Pagination<Dynamic>>> {
         
        return dynamicAPI.request(.recommendList(page))
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
    

    
    @IBAction func sendButtonTapped(_ sender: Any) {
        if LoginManager.shared.user!.realNameStatus.isPresent {
            presentDynamic()
        }
        else {
            checkUserAttestation()
        }
    }
    
    func presentDynamic() {
        let vc = DynamicViewController.loadFromStoryboard()
        let navVC = UINavigationController(rootViewController: vc)
        navVC.modalPresentationStyle = .fullScreen
        present(navVC, animated: true, completion: nil)
    }
    
    let authenticationAPI = Request<AuthenticationAPI>()
    
    func checkUserAttestation() {
        showIndicator()
        authenticationAPI.request(.checkUserAttestation, type: Response<Authentication>.self)
            .verifyResponse()
            .subscribe(onSuccess: { [weak self] response in
                guard let self = self else { return }
                self.hideIndicator()
                if response.data!.realNameStatus.isPresent {
                    let user = LoginManager.shared.user!
                    user.realNameStatus = response.data!.realNameStatus
                    LoginManager.shared.update(user: user)
                    self.presentDynamic()
                }
                else {
                    let vc = AuthenticationGuideViewController()
                    vc.onPushing.delegate(on: self) { (self, _) -> UINavigationController? in
                        return self.navigationController
                    }
                    self.present(vc, animated: true, completion: nil)
                }
            }, onError: { [weak self] error in
                self?.hideIndicator()
                self?.show(error.localizedDescription)
            })
            .disposed(by: rx.disposeBag)
    }
    
    @IBAction func bingPhone(_ sender: Any) {
        
        let vc = PhoneBindingController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func hiddenPhoneBindingTapped(_ sender: Any) {
        
        phoneBindingView.removeFromSuperview()
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
