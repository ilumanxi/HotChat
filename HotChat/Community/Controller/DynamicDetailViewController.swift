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
import SegementSlide

class DynamicDetailViewController: UIViewController, IndicatorDisplay, UITableViewDataSource, UITableViewDelegate, SegementSlideContentScrollViewDelegate, StoryboardCreate {

    
    static var storyboardNamed: String { return "Community" }
    
    var state: LoadingState = .initial {
        didSet {
            if isViewLoaded {
                showOrHideIndicator(loadingState: state)
            }
        }
    }

    let dynamicAPI = Request<DynamicAPI>()
    
    var dynamics: [Dynamic] = [] {
        didSet {
            if isViewLoaded {
                tableView.reloadData()
            }
        }
    }
    
    @objc var scrollView: UIScrollView {
        return tableView
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    var user: User!
    
    let loadSignal = PublishSubject<[String : Any]>()
    
    var selectedDynamic: Dynamic!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if user.userId != LoginManager.shared.user!.userId {
            setupChatView()
        }

        tableView.mj_header = MJRefreshNormalHeader { [weak self] in
            self?.refreshData()
        }
        
        tableView.mj_footer = MJRefreshAutoNormalFooter{ [weak self] in
            self?.loadMoreData()
        }
        
        loadSignal
            .subscribe(onNext: requestData)
            .disposed(by: rx.disposeBag)

        state = .loadingContent
        refreshData()
        
    }
    
    private let chatViewHeight: CGFloat = 48
    
    private var chatView: UserInfoChatView!
    
    
    private func setupChatView() {
        
        chatView = UserInfoChatView.loadFromNib()
        chatView.onPushing.delegate(on: self) { (self, _) -> (User, UINavigationController) in
            return (self.user, self.navigationController!)
        }
        chatView.backgroundColor = .clear
        view.addSubview(chatView)
        
        chatView.snp.makeConstraints { maker in
            maker.height.equalTo(48)
            maker.leading.trailing.equalToSuperview()
            maker.bottom.equalTo(self.safeBottom).offset(-20).priority(999)
            maker.bottom.equalToSuperview().offset(-34)
        }
        
        if #available(iOS 11.0, *) {
            additionalSafeAreaInsets = UIEdgeInsets(top: 0, left: 0, bottom: 48, right: 0)
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
            .checkResponse()
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
               
                guard let index = self?.dynamics.lastIndex(where: { $0.dynamicId == dynamic.dynamicId }),
                      let zanNum = response.data?["zanNum"] as? Int,
                      let isSelfZan = response.data?["type"] as? Bool else {
                    return
                }
                
                self?.dynamics.modifyElement(at: index, { element in
                    element.zanNum = zanNum
                    element.isSelfZan = isSelfZan
                })
                self?.tableView.reloadData()
                
                Log.print(response)
            }, onError: { error in
                Log.print(error)
            })
            .disposed(by: rx.disposeBag)
        
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
            if LoginManager.shared.user!.userId != self.user.userId {
                self.selectedDynamic = dynamic
                let vc = GiftViewController()
                vc.delegate = self
                vc.modalPresentationStyle = .overFullScreen
                self.present(vc, animated: true, completion: nil)
            }
        }
        
        cell.onCommentTapped.delegate(on: self) { (self, _) in
            let info = TUIConversationCellData()
            info.userID = dynamic.userInfo.userId
            let vc  = ChatViewController(conversation: info)!
            vc.title = dynamic.userInfo.nick
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        cell.onImageTapped.delegate(on: self) { (self, sender) in
            
            let (_, index, imageViews) = sender
            
            let photos = (0..<imageViews.count)
                .compactMap { index -> GKPhoto? in
                    let photo = GKPhoto()
                    photo.url = URL(string: dynamic.photoList[index].picUrl)
                    photo.sourceImageView = imageViews[index]
                    return photo
                }
            
            let browser = GKPhotoBrowser(photos: photos, currentIndex: index)
            browser.showStyle = .zoom
            browser.hideStyle = .zoomScale
            browser.loadStyle = .indeterminateMask
            browser.maxZoomScale = 20
            browser.doubleZoomScale = 2
            
            browser.show(fromVC: self)
        }
        
        cell.onMoreButtonTapped.delegate(on: self) { (self, _) in
            let alertController = SPAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            if LoginManager.shared.user!.userId == self.user.userId {
                alertController.addAction(SPAlertAction(title: "删除", style: .default, handler: { _ in
                    
                }))
            }
            else {
                alertController.addAction(SPAlertAction(title: "不看Ta的动态", style: .default, handler: { _ in
                    
                }))
                
                alertController.addAction(SPAlertAction(title: "举报这条动态", style: .default, handler: { [weak self] _ in
                    let vc = ReportViewController.loadFromStoryboard()
                    vc.user = dynamic.userInfo
                    self?.present(vc, animated: false, completion: nil)
                }))
            }
            alertController.addAction(SPAlertAction(title: "取消", style: .cancel, handler: nil))
            
            self.present(alertController, animated: true, completion: nil)
        }
        
        return cell
    }

}


extension DynamicDetailViewController: GiftViewControllerDelegate {
    
    func giftViewController(_ gift: GiftViewController, didSelectItemAt indexPath: IndexPath) {
        
        guard let dynamic = selectedDynamic else {
            return
        }
        
        let giftData = gift.gifts[indexPath.item]
        giftData.count = 1
        
        GiftManager.shared().giveGift(self.user.userId, type: 1, dynamicId: dynamic.dynamicId, gift: giftData) { (responseObject, error) in
            if let error = error {
                self.show(error.localizedDescription)
                return
            }
            let giveGift = GiveGift.mj_object(withKeyValues: responseObject?["data"])!
            
            if giveGift.resultCode == 1 {
                
                dynamic.giftNum += 1
                self.tableView.reloadData()
                
                let  user  = LoginManager.shared.user!
                user.userEnergy = giveGift.userEnergy
                LoginManager.shared.update(user: user)
                
                let cellData = GiftCellData(direction: .MsgDirectionOutgoing)
                cellData.gift = giftData
                let imData = IMData.default()
                imData.data = giftData.mj_JSONString()
                
                let data = TUICallUtils.dictionary2JsonData(imData.mj_keyValues() as! [AnyHashable : Any])
                cellData.innerMessage = V2TIMManager.sharedInstance()!.createCustomMessage(data)
                GiftManager.shared().sendGiftMessage(cellData, userID: self.user.userId)
                gift.dismiss(animated: true, completion: nil)
                
                self.show("送礼成功")
            }
            else if (giveGift.resultCode == 3) { //能量不足，需要充值
                gift.dismiss(animated: true) {
                    
                    let alertController = UIAlertController(title: nil, message: "您的能量不足、请充值！", preferredStyle: .alert)
                    
                    alertController.addAction(UIAlertAction(title: "立即充值", style: .default, handler: { _ in
                        let vc = WalletViewController()
                        self.navigationController?.pushViewController(vc, animated: true)
                    }))
                    
                    alertController.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
                    
                    self.present(alertController, animated: true, completion: nil)
                  
                }
                
            }
            else {
                
                self.show(giveGift.msg)
            }
            
        }
    }

    
}

