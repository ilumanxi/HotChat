//
//  RecommendViewController.swift
//  HotChat
//
//  Created by 风起兮 on 2021/4/22.
//  Copyright © 2021 风起兮. All rights reserved.
//

import UIKit
import MJRefresh
import RxSwift
import RxCocoa

class RecommendViewController: UIViewController, LoadingStateType, IndicatorDisplay {
    
    
    enum DataType: Int {
        //  推荐
        case recommend = 10003
        //  上线
        case active = 10004
    }
    
    
    @IBOutlet weak var tableView: UITableView!
    
    let type: RecommendViewController.DataType
    
    init(type: RecommendViewController.DataType) {
        self.type = type
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let API = Request<PushNoticeAPI>()
    
    var data: [PushItem] = []
    

    
    var state: LoadingState = .initial {
        didSet {
            if state == .noContent {
                showOrHideIndicator(loadingState: state, text: "当前暂无消息，请留意新的消息提示。", image: UIImage(named: "no-content-noti"), actionText: nil)
            }
            else {
                showOrHideIndicator(loadingState: state)
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

extension RecommendViewController {
    
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
        return API.request(.pushNoticeList(type: type.rawValue, page: page))
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

extension RecommendViewController: UITableViewDelegate {
    
    
}

extension RecommendViewController: UITableViewDataSource {
    
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
