//
//  ChatMemberViewController.swift
//  HotChat
//
//  Created by 风起兮 on 2021/3/18.
//  Copyright © 2021 风起兮. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa
import MJRefresh

class ChatMemberViewController: UITableViewController, IndicatorDisplay, LoadingStateType {
    
    
    
    let API = Request<GroupChatAPI>()
    
    var state: LoadingState = .initial {
        didSet {
            if isViewLoaded  && state != oldValue {
                showOrHideIndicator(loadingState: state)
            }
        }
    }
    
    
    var data: [User] = []
    
    var pageIndex: Int = 1
    
    let refreshPageIndex: Int = 1
    
    let loadSignal = PublishSubject<Int>()
    
    let groupId: String
    let sex: Sex
    
    init(groupId: String, sex: Sex) {
        self.groupId = groupId
        self.sex = sex
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        // Do any additional setup after loading the view.
        
        setupViews()
        
        loadSignal
            .subscribe(onNext: requestData)
            .disposed(by: rx.disposeBag)
        
        tableView.mj_header = MJRefreshNormalHeader { [weak self] in
            self?.refreshData()
        }
        
        tableView.mj_footer = MJRefreshAutoNormalFooter{ [weak self] in
            self?.loadMoreData()
        }

        
        state = .loadingContent

        refreshData()
        
       
    }

    
    func setupViews()  {
        
        tableView.rowHeight = 75
        tableView.register(UINib(nibName: "ChatMemberCell", bundle: nil), forCellReuseIdentifier: "ChatMemberCell")
    }


}


extension ChatMemberViewController {
    
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
    
    func loadData(_ page: Int) -> Single<Response<Pagination<User>>> {
        
        return API.request(.getGroupList(groupId: groupId, type: sex.rawValue, page: page))
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
                
        state = self.data.isEmpty ? .noContent : .contentLoaded
        
        if !data.isEmpty {
            pageIndex = page.page + 1
        }
        
       
        endRefreshing(noContent: !page.hasNext)
    }
    
    func refreshData(_ data: [User]) {
        if !data.isEmpty {
            self.data = data
        }
    }
    
    func appendData(_ data: [User]) {
        self.data.append(contentsOf: data)
    }
    
    func handlerError(_ error: Error) {
        if data.isEmpty {
            state = .error
        }
        endRefreshing()
       
    }
}

extension ChatMemberViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return data.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(for: indexPath, cellType: ChatMemberCell.self)
        cell.set(data[indexPath.row])
        
        return cell
    }
    
}
