//
//  InterflowViewController.swift
//  HotChat
//
//  Created by 风起兮 on 2021/4/26.
//  Copyright © 2021 风起兮. All rights reserved.
//

import UIKit
import SnapKit
import RxCocoa
import RxSwift
import MJRefresh

class InterflowViewController: UIViewController, IndicatorDisplay, LoadingStateType {
    
    
    var tableView: UITableView!
    
    
    var data: [Interflow] = []
    
    let API = Request<UserAPI>()
    
    var state: LoadingState = .initial {
        didSet {
            if state == .noContent {
                let text = "亲密度>0℃的亲密关系会在这里展示哦~\n快去和心仪的Ta聊聊吧"
                showOrHideIndicator(loadingState: state, text: text, image: UIImage(named: "no-content-intimacy"), actionText: nil, backgroundColor: .white)
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
        setupUI()
        trigger()
        refreshData()
    }
    
    
    func setupUI() {
        tableView = UITableView(frame: .zero, style: .plain)
        tableView.rowHeight = 80
        tableView.estimatedRowHeight = 0
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)
        tableView.snp.makeConstraints { maker in
            maker.edges.equalToSuperview()
        }
        
        tableView.register(UINib(nibName: "InterflowCell", bundle: nil), forCellReuseIdentifier: "InterflowCell")
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


extension InterflowViewController {
    
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
    
    func loadData(_ page: Int) -> Single<Response<Pagination<Interflow>>> {
        return API.request(.userChatList(page: page))
    }
    
    func handlerReponse(_ response: Response<Pagination<Interflow>>){

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
    
    func refreshData(_ data: [Interflow]) {
        if !data.isEmpty {
            self.data = data
        }
    }
    
    func appendData(_ data: [Interflow]) {
        self.data.append(contentsOf: data)
    }
    
    func handlerError(_ error: Error) {
        if data.isEmpty {
            state = .error
        }
        endRefreshing()
       
    }
}

extension InterflowViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}

extension InterflowViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let model = data[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(for: indexPath, cellType: InterflowCell.self)
        
        cell.set(model)
        
        return cell
    }
}
