//
//  RelationViewController.swift
//  HotChat
//
//  Created by 风起兮 on 2021/4/12.
//  Copyright © 2021 风起兮. All rights reserved.
//

import UIKit
import SegementSlide
import RxCocoa
import RxSwift
import NSObject_Rx
import Reusable
import Kingfisher
import MJRefresh
import HandyJSON
import SPAlertController
import YBImageBrowser


class RelationViewController: UIViewController, LoadingStateType, IndicatorDisplay {
    
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
    
    let bannerAPI = Request<BannerAPI>()
    
    var headerViewHeight: CGFloat {
        return (view.bounds.width / (2 / 0.75)).rounded(.down)
    }
    
    var banners: [Banner] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    var dynamics: [Dynamic] = []
    
    var selectedDynamic: Dynamic!
    

    @IBOutlet weak var tableView: UITableView!
    
    let playerManager = PlayerManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem?.setTitleTextAttributes(UINavigationBar.appearance().titleTextAttributes, for: .normal)
        
        playerManager.listPlayer.volume = 0
        
        
        tableView.register(BanberHeaderView.self, forHeaderFooterViewReuseIdentifier: "BanberHeaderView")
        tableView.register(UINib(nibName: "DynamicDetailViewCell", bundle: nil), forCellReuseIdentifier: "DynamicDetailViewCell")
        
        tableView.backgroundColor = UIColor(hexString: "#F6F7F9")
        
        loadSignal
            .subscribe(onNext: requestData)
            .disposed(by: rx.disposeBag)
        
        tableView.mj_header = MJRefreshNormalHeader { [weak self] in
            self?.refreshData()
        }
        
        tableView.mj_footer = MJRefreshAutoNormalFooter{ [weak self] in
            self?.loadMoreData()
        }
        
        refreshData()

    }
    
    
    func endRefreshing(noContent: Bool = false) {
        tableView.reloadData()
        tableView.mj_header?.endRefreshing()
        if noContent {
            tableView.mj_footer?.endRefreshingWithNoMoreData()
        }
        else {
            tableView.mj_footer?.endRefreshing()
        }
        
    }
    
    func refreshData() {
        loadSignal.onNext(refreshPageIndex)
        
        loadBanner()
    }
    
    func loadBanner()  {
        bannerAPI.request(.bannerList(type: 1), type: Response<[Banner]>.self)
            .verifyResponse()
            .subscribe(onSuccess: { [weak self] response in
                self?.banners = response.data ?? []
            }, onError: nil)
            .disposed(by: rx.disposeBag)
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
         
        return dynamicAPI.request(.followDynamicList(page))
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
        
        if page.page == 1 {
            scrollViewDidEndDecelerating(self.tableView)
        }
    }
    
    func refreshData(_ data: [Dynamic]) {
        if !data.isEmpty {
            dynamics = data
            self.playerManager.clear()
            
            let videos = data.filter {
                $0.type == .video
            }
            self.playerManager.add(playList: videos)
        }
    }
    
    func appendData(_ data: [Dynamic]) {
        dynamics = dynamics + data
        let videos = data.filter {
            $0.type == .video
        }
        self.playerManager.add(playList: videos)
    }
    
    func handlerError(_ error: Error) {
        if dynamics.isEmpty {
            state = .error
        }
        endRefreshing()
       
    }
    
}


extension RelationViewController: UITableViewDataSource, UITableViewDelegate {
    
    func delete(_ dynamic: Dynamic)  {
        
        showIndicatorOnWindow()
        dynamicAPI.request(.delDynamic(dynamic.dynamicId), type: ResponseEmpty.self)
            .subscribe(onSuccess: {[weak self] response in
               
                self?.dynamics.removeAll{
                    $0.dynamicId == dynamic.dynamicId
                }
                self?.tableView.reloadData()
                
                self?.hideIndicatorFromWindow()
            }, onError: { [weak self] error in
                self?.hideIndicatorFromWindow()
                self?.showMessageOnWindow(error)
            })
            .disposed(by: rx.disposeBag)
    }
    
    
    func like(_ dynamic: Dynamic)  {
        
        dynamicAPI.request(.zan(dynamic.dynamicId), type: Response<[String : Any]>.self)
            .subscribe(onSuccess: {[weak self] response in
                guard
                      let zanNum = response.data?["zanNum"] as? Int,
                      let isSelfZan = response.data?["type"] as? Bool else {
                    return
                }
                
                dynamic.zanNum = zanNum
                dynamic.isSelfZan = isSelfZan
                self?.tableView.reloadData()
                
                Log.print(response)
            }, onError: { error in
                Log.print(error)
            })
            .disposed(by: rx.disposeBag)
        
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if decelerate == false {
            playVideo()
        }
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        playVideo()
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
      
        playVideo()
    }
    
    func playVideo() {
        
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(findVideo), object: nil)
        perform(#selector(findVideo), with: nil, afterDelay: 0.1)
    }
    
    @objc func findVideo() {
        let visibleCells = tableView.visibleCells
        
        if visibleCells.isEmpty {
            self.playerManager.stop()
            return
        }
        
        let indexPaths =  visibleCells.compactMap { [unowned self] in
            self.tableView.indexPath(for: $0)
        }
        
        
        let videoIndexPaths = indexPaths.filter {[unowned self] indexPath in
           return self.dynamics[indexPath.row].type == .video
        }
        
        let playFrame = self.view.frame.inset(by: self.view.safeAreaInsets)
        
        var activateVideoCells: [DynamicDetailViewCell] = []
        
        for indexPath in videoIndexPaths {
            
            if let videoCell = tableView.cellForRow(at: indexPath) as? DynamicDetailViewCell, let videoView =  videoCell.collectionView.visibleCells.first {
                
                let videoViewFrame = videoView.convert(videoView.bounds, to: self.view)
                if playFrame.contains(videoViewFrame) {
                    activateVideoCells.append(videoCell)
                }
            }
        }
        
        if activateVideoCells.isEmpty {
            self.playerManager.stop()
            return
        }
        
        
        let videoCells = activateVideoCells.sorted {
            $0.frame .minY < $1.frame.minY
        }
       
        
        let playCell = videoCells.first!
  
        guard let playIndexPath = tableView.indexPath(for: playCell) else {
            return
        }
        
        let item = self.dynamics[playIndexPath.row]
        
        
        guard let index = self.playerManager.items.firstIndex (where: { $0.uid == item.uid }) else { return  }
        
        if self.playerManager.currentIndex == index {
            return
        }
        
        let containerView = playCell.collectionView.visibleCells.first!
        
        self.playerManager.removePlayView()
        
        self.playerManager.addPlayView(in: containerView)
        self.playerManager.play(at: index)
        
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        let data = self.dynamics[indexPath.row]
        if data.type == .image {
            return
        }
        
        guard let cell = tableView.cellForRow(at: indexPath) as? DynamicDetailViewCell else {
            return
        }
        
        guard let playCell = cell.collectionView.visibleCells.first else { return  }
        
        self.playerManager.addPlayView(in: playCell)
        
        self.playerManager.play(at: 0)
        
        
    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return self.banners.isEmpty ? 0.1 : headerViewHeight
    }
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let banberHeaderView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "BanberHeaderView") as? BanberHeaderView
        banberHeaderView?.banners = self.banners
        return banberHeaderView
    }


    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dynamics.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let dynamic = dynamics[indexPath.item]
        
        let cell = tableView.dequeueReusableCell(for: indexPath, cellType: DynamicDetailViewCell.self)
        cell.dynamic = dynamic
        
        cell.onAvatarTapped.delegate(on: self) { (self, sender) in
            let vc = UserInfoViewController()
            vc.user  = dynamic.userInfo
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        cell.onLikeTapped.delegate(on: self) { (self, sender) in
            self.like(dynamic)
        }
        
        cell.onGiveTapped.delegate(on: self) { (self, sender) in
            if LoginManager.shared.user!.userId != dynamic.userInfo.userId {
                self.selectedDynamic = dynamic
                
                let vc = GiftViewController()
                vc.navigationBarAlpha = 0
                vc.delegate = self
                
                let navController = BaseNavigationController(rootViewController: vc)
                navController.modalPresentationStyle = .overFullScreen
                navController.modalTransitionStyle = .coverVertical
                navController.navigationBar.isHidden = true
                self.present(navController, animated: true) {
                    navController.navigationBar.isHidden = false
                }
            }
        }
        
        cell.onCommentTapped.delegate(on: self) { (self, _) in
            let vc = CommentsViewController(dynamic: dynamic)
            let nav = PanModalNavigationController(rootViewController: vc)
            self.presentPanModal(nav)
        }
        
        cell.onImageTapped.delegate(on: self) { (self, sender) in
            
            let (_, index, imageViews) = sender
            
            let photos: [YBIBDataProtocol]
            
            if dynamic.type == .video {
                let video = YBIBVideoData()
                video.videoURL = URL(string: dynamic.video!.url)!
                video.projectiveView = imageViews[index]
                video.autoPlayCount = .max
                photos = [video]
            }
            else {
                photos = (0..<imageViews.count)
                    .compactMap { index -> YBIBImageData? in
                        let photo = YBIBImageData()
                        photo.imageURL = URL(string: dynamic.photoList[index].picUrl)!
                        photo.projectiveView = imageViews[index]
                        return photo
                    }
            }
            
            let  browser = YBImageBrowser()
            browser.dataSourceArray = photos
            browser.currentPage = index
            // 只有一个保存操作的时候，可以直接右上角显示保存按钮
            browser.defaultToolViewHandler?.topView.operationButton.isHidden = true
            browser.show()
            
        }
        
        cell.onMoreButtonTapped.delegate(on: self) { (self, _) in
            let alertController = SPAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            if LoginManager.shared.user!.userId == dynamic.userInfo.userId {
                alertController.addAction(SPAlertAction(title: "删除", style: .default, handler: { [weak self] _ in
                    self?.tipDelete(dynamic)
                }))
            }
            else {
//                alertController.addAction(SPAlertAction(title: "不看Ta的动态", style: .default, handler: { _ in
//
//                }))
                
                alertController.addAction(SPAlertAction(title: "举报这条动态", style: .default, handler: { [weak self] _ in
                    let vc = ReportViewController.loadFromStoryboard()
                    vc.dynamic = dynamic
                    self?.present(vc, animated: true, completion: nil)
                }))
            }
            alertController.addAction(SPAlertAction(title: "取消", style: .cancel, handler: nil))
            
            self.present(alertController, animated: true, completion: nil)
        }
        
        cell.onAccostButtonTapped.delegate(on: self) { (self, _) in
            self.accost(dynamic)
        }
        
        cell.onChatButtonTapped.delegate(on: self) { (self, _) in
            self.chat(dynamic)
        }
        
        return cell
    }
    
    func chat(_ dynamic: Dynamic) {
        let user = dynamic.userInfo!
        
        if CallHelper.share.checkCall(user, type: .text, indicatorDisplay: self) {
            let info = TUIConversationCellData()
            info.userID = user.userId
            let vc  = ChatViewController(conversation: info)!
            vc.title = user.nick
            navigationController?.pushViewController(vc, animated: true)
        }
    }

    func accost(_ dynamic: Dynamic) {
        
        showIndicator()
        dynamicAPI.request(.clickDynamicGreet(dynamicId: dynamic.dynamicId), type: Response<[String: Any]>.self)
            .verifyResponse()
            .subscribe(onSuccess: { [weak self] respoonse in
                self?.hideIndicator()
                // resultCode： 1132成功 1130搭讪过了 1131失败
                guard let self = self,
                      let resultCode = respoonse.data?["resultCode"] as? Int,
                      let resultMsg = respoonse.data?["resultMsg"] as? String else {
                    return
                }
                
                if resultCode == 1132 || resultCode == 1130 {
                    dynamic.isGreet = true
                }
                else {
                    self.show(resultMsg)
                }
                self.tableView.reloadData()
                
            }, onError: { [weak  self] error in
                self?.hideIndicator()
                self?.show(error)
            })
            .disposed(by: rx.disposeBag)
    }
    
    func tipDelete(_ dynamic: Dynamic) {
        
        let alertController = UIAlertController(title: nil, message: "你确定删除这条动态吗", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "确定", style: .destructive, handler: { [weak self] _ in
            self?.delete(dynamic)
        }))
        alertController.addAction(UIAlertAction(title: "取消", style: .default, handler: nil))
        
        present(alertController, animated: true, completion: nil)
    }
}


extension RelationViewController: GiftViewControllerDelegate {
    
    func giftViewController(_ giftController: GiftViewController, didSelect gift: Gift) {
        
        guard let dynamic = selectedDynamic else {
            return
        }
        
        GiftManager.shared().giveGift(selectedDynamic.userInfo.userId, type: 1, dynamicId: dynamic.dynamicId, gift: gift) { (responseObject, error) in
            if let error = error {
                self.show(error)
                return
            }
            let giveGift = GiveGift.mj_object(withKeyValues: responseObject?["data"])!
            
            if giveGift.resultCode == 1 {
                
                dynamic.giftCount += 1
                self.tableView.reloadData()
                
                let  user  = LoginManager.shared.user!
                user.userEnergy = giveGift.userEnergy
                LoginManager.shared.update(user: user)
                
                let cellData = GiftCellData(direction: .MsgDirectionOutgoing)
                cellData.gift = gift
                let imData = IMData.default()
                imData.data = gift.mj_JSONString()
                imData.giftRequestId = giveGift.giftRequestId
                let data = TUICallUtils.dictionary2JsonData(imData.mj_keyValues() as! [AnyHashable : Any])
                cellData.innerMessage = V2TIMManager.sharedInstance()!.createCustomMessage(data)
                GiftManager.shared().sendGiftMessage(cellData, userID: dynamic.userInfo.userId)
                giftController.dismiss(animated: true, completion: nil)
                
                self.show("送礼成功")
            }
            else if (giveGift.resultCode == 3) { //能量不足，需要充值
                giftController.dismiss(animated: true) {
                    
                    let vc =  TipAlertController(title: "温馨提示", message:  "您的能量不足，请充值", leftButtonTitle: "取消", rightButtonTitle: "立即充值")
                    vc.onRightDidClick.delegate(on: self) { (self, _) in
                        let vc = WalletViewController()
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                    self.present(vc, animated: true, completion: nil)
                }
                
            }
            else {
                
                self.show(giveGift.msg)
            }
            
        }
    }

    
}
