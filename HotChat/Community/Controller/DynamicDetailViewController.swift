//
//  DynamicDetailViewController.swift
//  HotChat
//
//  Created by 风起兮 on 2020/10/12.
//  Copyright © 2020 风起兮. All rights reserved.
//

import UIKit
import GKPhotoBrowser
import SPAlertController
import MJRefresh
import RxSwift
import RxCocoa
import Aquaman
import YBImageBrowser

class DynamicDetailViewController: UIViewController, IndicatorDisplay, UITableViewDataSource, UITableViewDelegate, AquamanChildViewController, StoryboardCreate {

    
    static var storyboardNamed: String { return "Community" }
    
    var state: LoadingState = .initial {
        didSet {
            if isViewLoaded {
                if state == .noContent  && user.userId == LoginManager.shared.user!.userId {
                    showOrHideIndicator(loadingState: state, in: tableView, text: "发布你的第一条动态\n收获新的朋友", image: UIImage(), actionText: "发布", backgroundColor: .white)
                }
                else if state == .noContent {
                    showOrHideIndicator(loadingState: state, in: tableView, text: "还没发布消息......", image: UIImage(named: "no-content-dynamic"), actionText: nil, backgroundColor: .white)
                }
                else {
                    showOrHideIndicator(loadingState: state, in: tableView, backgroundColor: .white)
                }
            }
        }
    }
    

    let dynamicAPI = Request<DynamicAPI>()
    
    var commentCount: Int = 0
    var dynamics: [Dynamic] = [] {
        didSet {
            if isViewLoaded {
                tableView.reloadData()
            }
        }
    }
        
    func aquamanChildScrollView() -> UIScrollView {
        return tableView
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    var user: User!
    
    let loadSignal = PublishSubject<[String : Any]>()
    
    var selectedDynamic: Dynamic!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: "NoteViewCell", bundle: nil), forCellReuseIdentifier: "NoteViewCell")
        
    
        tableView.mj_header = MJRefreshNormalHeader { [weak self] in
            self?.refreshData()
        }
        
        tableView.mj_footer = MJRefreshAutoNormalFooter{ [weak self] in
            self?.loadMoreData()
        }
        
        loadSignal
            .subscribe(onNext: { [weak self] parameters in
                self?.requestData(parameters)
            })
            .disposed(by: rx.disposeBag)

        state = .loadingContent
        refreshData()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        chatViewState()
    }
    
    private let chatViewHeight: CGFloat = 48
    
    private var chatView: UserInfoChatView!
    
    
    let API = Request<ChatGreetAPI>()
    
    
    func actionTapped() {
        if LoginManager.shared.user!.realNameStatus.isPresent {
            self.presentDynamic()
        }
        else {
            self.checkUserAttestation()
        }
    }
    
    func presentDynamic() {
        let vc = DynamicViewController()
        vc.onSened.delegate(on: self) { (self, _) in
            
            if let navigationController =  self.children.first as? UINavigationController,
               let controller = navigationController.viewControllers.first as? IndicatorDisplay {
                controller.refreshData()
            }
        }
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
                self?.show(error)
            })
            .disposed(by: rx.disposeBag)
    }
    
    func chatViewState() {
        if LoginManager.shared.user!.girlStatus {
            API.request(.checkGreet(toUserId: user.userId), type: Response<[String : Any]>.self)
                .verifyResponse()
                .subscribe(onSuccess: { [weak self] response in

                    guard let resultCode = response.data?["resultCode"] as? Int else { return }
                    
                    if resultCode == 1005 {
                        self?.chatView?.state = .sayHellow
                    }
                    else if resultCode == 1006 {
                        self?.chatView?.state = .default
                    }
                    else if resultCode == 1007 {
                        self?.chatView?.state = .notSayHellow
                    }
                    
                }, onError: nil)
                .disposed(by: rx.disposeBag)
        }
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
        
        var parameters: [String : Any] = [:]
        parameters["userId"] = user.userId
        if dynamics.isEmpty {
            parameters["currentDynamicId"] = "0"
            parameters["handleType"] = 0
        }
        else {
            parameters["handleType"] = 1
            parameters["currentDynamicId"] = dynamics.first?.dynamicId ?? "0"
        }
        
        loadSignal.onNext(parameters)
    }
    
    func loadMoreData() {
        var parameters: [String : Any] = [:]
        parameters["userId"] = user.userId
        parameters["currentDynamicId"] = dynamics.last?.dynamicId ?? "0"
        if dynamics.isEmpty {
            parameters["handleType"] = 0
        }
        else {
            parameters["handleType"] = 2
        }
        loadSignal.onNext(parameters)
    }
    
    func requestData(_ parameters: [String : Any]) {
        if dynamics.isEmpty {
            state = .refreshingContent
        }
        loadData(parameters)
            .verifyResponse()
            .subscribe(onSuccess: handlerReponse, onError: handlerError)
            .disposed(by: rx.disposeBag)
    }
    
    func loadData(_ parameters: [String : Any]) -> Single<Response<Pagination<Dynamic>>> {
         
        return dynamicAPI.request(.dynamicList(parameters))
    }
    
    func handlerReponse(_ response: Response<Pagination<Dynamic>>){

        guard let page = response.data, let data = page.list else {
            return
        }
        
        commentCount = page.count
        
        if page.handleType == 0 || page.handleType == 1 {
            refreshData(data)
        }
        else {
            appendData(data)
        }
        
        if page.page == 1 && dynamics.isEmpty {
            state = .noContent
        } else if !dynamics.isEmpty {
            state = .contentLoaded
        }
        endRefreshing(noContent: !page.hasNext)
        
    }
    
    func refreshData(_ data: [Dynamic]) {
        
        dynamics = data +  dynamics
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
                
            }, onError: { error in
                Log.print(error)
            })
            .disposed(by: rx.disposeBag)
        
    }
    
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
    
    
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dynamics.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let dynamic = dynamics[indexPath.item]
        
        let cell = tableView.dequeueReusableCell(for: indexPath, cellType: NoteViewCell.self)
        cell.dynamic = dynamic
        cell.timelineView.isHidden = commentCount == (indexPath.row + 1)
        
        let previouIndex = indexPath.row - 1
        
        if previouIndex >= 0 {
            cell.yearLabel.isHidden = dynamics[previouIndex].year == dynamic.year
        }
        
        cell.onAvatarTapped.delegate(on: self) { (self, sender) in
            let vc = UserInfoViewController()
            vc.user  = dynamic.userInfo
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        cell.onLikeTapped.delegate(on: self) { (self, sender) in
            self.like(dynamic)
        }
        
        cell.onGiveTapped.delegate(on: self) { (self, sender) in
            if LoginManager.shared.user!.userId != self.user.userId {
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
            
            if LoginManager.shared.user!.userId == self.user.userId {
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


extension DynamicDetailViewController: GiftViewControllerDelegate {
    
    func giftViewController(_ giftController: GiftViewController, didSelect gift: Gift) {
        
        guard let dynamic = selectedDynamic else {
            return
        }
        
        GiftManager.shared().giveGift(self.user.userId, type: 1, dynamicId: dynamic.dynamicId, gift: gift) { (responseObject, error) in
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
                user.freeGifts = giveGift.freeGifts
                user.userTanbi = giveGift.userTanbi
                LoginManager.shared.update(user: user)
                
                let cellData = GiftCellData(direction: .MsgDirectionOutgoing)
                cellData.gift = gift
                let imData = IMData.default()
                imData.data = gift.mj_JSONString()
                imData.giftRequestId = giveGift.giftRequestId
                let data = TUICallUtils.dictionary2JsonData(imData.mj_keyValues() as! [AnyHashable : Any])
                cellData.innerMessage = V2TIMManager.sharedInstance()!.createCustomMessage(data)
                GiftManager.shared().sendGiftMessage(cellData, userID: self.user.userId)
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

