//
//  OnlineStatusViewController.swift
//  HotChat
//
//  Created by 风起兮 on 2021/4/20.
//  Copyright © 2021 风起兮. All rights reserved.
//

import UIKit
import PanModal
import RxSwift
import RxCocoa
import MJRefresh

class OnlineStatusViewController: UIViewController, LoadingStateType, IndicatorDisplay {
    
    
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    let API = Request<PushNoticeAPI>()
    
    var data: [PushItem] = []
    

    
    var state: LoadingState = .initial {
        didSet {
            if state == .noContent {
                showOrHideIndicator(loadingState: state, in: containerView, text: "当前暂无消息，请留意新的消息提示。", image: UIImage(named: "no-content-noti"), actionText: nil)
            }
            else {
                showOrHideIndicator(loadingState: state, in: containerView)
            }
        }
    }
    
    var pageIndex: Int = 1
    
    let refreshPageIndex: Int = 1
    
    let loadSignal = PublishSubject<Int>()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupUI()
        trigger()
        
        refreshData()
        
    }
    
    @IBAction func refreshButtonTapped(_ sender: Any) {
        UIView.animate(withDuration: 0.25) {
            self.tableView.contentOffset = .zero
        } completion: { _ in
            self.tableView.mj_header?.beginRefreshing()
        }
    }
    
    
    @IBAction func closeButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
    func setupUI()  {
        tableView.register(UINib(nibName: "OnlineStatusCell", bundle: nil), forCellReuseIdentifier: "OnlineStatusCell")
    }
    
    func trigger()  {
        loadSignal
            .subscribe(onNext: requestData)
            .disposed(by: rx.disposeBag)
        
        tableView.mj_header = MJRefreshNormalHeader { [weak self] in
            self?.refreshData()
        }
        
        tableView.mj_footer = MJRefreshAutoNormalFooter{ [weak self] in
            self?.loadMoreData()
        }
    }
    
}

extension OnlineStatusViewController {
    
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
    
    func loadData(_ page: Int) -> Single<Response<Pagination<PushItem>>> {
        return API.request(.pushNoticeList(type: 10004, page: page))
    }
    
    func handlerReponse(_ response: Response<Pagination<PushItem>>){

        guard let page = response.data, let data = page.list else {
            return
        }
        
        if page.page == 1 {
            refreshData(data)
        }
        else {
            appendData(data)
        }
        
        titleLabel.text = "共有\(page.count)条消息"
        
        state = self.data.isEmpty ? .noContent : .contentLoaded
        
        if !data.isEmpty {
            pageIndex = page.page + 1
        }
        endRefreshing(noContent: !page.hasNext)
    }
    
    func refreshData(_ data: [PushItem]) {
        if !data.isEmpty {
            self.data = data
        }
    }
    
    func appendData(_ data: [PushItem]) {
        self.data.append(contentsOf: data)
    }
    
    func handlerError(_ error: Error) {
        if data.isEmpty {
            state = .error
        }
        endRefreshing()
       
    }
}

extension OnlineStatusViewController: UITableViewDelegate {
    
    
}

extension OnlineStatusViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let model = data[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(for: indexPath, cellType: OnlineStatusCell.self)
        cell.set(model)
        
        cell.onChat.delegate(on: self) { (self, _) in
            let user  = model.userInfo!
            let info = TUIConversationCellData()
            info.userID = user.userId
            let vc  = ChatViewController(conversation: info)!
            vc.title = user.nick
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        return cell
    }
}


extension OnlineStatusViewController: PanModalPresentable {
    
    var panScrollable: UIScrollView? {
        return nil
    }
    
    var longFormHeight: PanModalHeight {
        
        if traitCollection.verticalSizeClass == .compact {
            
        }
        
        let scale: CGFloat = 407.0 / 667.0
        
        return .contentHeight(UIScreen.main.bounds.height * scale)
    }
    
    var panModalBackgroundColor: UIColor {
        return UIColor.black.withAlphaComponent(0.5)
    }
    
    var showDragIndicator: Bool {
        return false
    }
}

