//
//  VisitorsController.swift
//  HotChat
//
//  Created by 风起兮 on 2021/2/1.
//  Copyright © 2021 风起兮. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import MJRefresh
import Kingfisher

class VisitorsController: UIViewController, LoadingStateType, IndicatorDisplay {
    
    var state: LoadingState = .initial {
        didSet {
            showOrHideIndicator(loadingState: state)
        }
    }
    
    var channel: Channel!
    
    var data: [User] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    var pageIndex: Int = 1
    
    let refreshPageIndex: Int = 1
    
    let loadSignal = PublishSubject<Int>()
    
    let userAPI = Request<UserAPI>()
    
    
    @IBOutlet weak var tableView: UITableView!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "我的访客"
        
        tableView.register(UINib(nibName: "ChannelCell", bundle: nil), forCellReuseIdentifier: "ChannelCell")

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
        
        return userAPI.request(.visitorList(page)).verifyResponse()
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
        
        if !data.isEmpty {
            pageIndex = page.page + 1
        }
                
        state = self.data.isEmpty ? .noContent : .contentLoaded
        
        endRefreshing(noContent: !page.hasNext)
        
    }
    
    func refreshData(_ data: [User]) {
        if !data.isEmpty {
            self.data = data
        }
    }
    
    func appendData(_ data: [User]) {
        self.data = self.data + data
    }
    
    func handlerError(_ error: Error) {
        if data.isEmpty {
            state = .error
        }
        endRefreshing()
       
    }

}


extension VisitorsController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 104
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let user = data[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(for: indexPath, cellType: ChannelCell.self)
        cell.setUser(user)
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = UserInfoViewController()
        vc.user  = data[indexPath.row]
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
}



