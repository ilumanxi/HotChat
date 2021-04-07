//
//  NotificationViewController.swift
//  HotChat
//
//  Created by 风起兮 on 2021/4/6.
//  Copyright © 2021 风起兮. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import MJRefresh

class NotificationViewController: UIViewController, IndicatorDisplay {
    
    
    var data: [Notice] = []
    
    let API = Request<DynamicAPI>()
    
    var state: LoadingState = .initial {
        didSet {
            
            switch state {
            case .noContent:
                showOrHideIndicator(loadingState: state, text: "没有互动通知哦~", image: UIImage(named: "no-content-notice"), actionText: nil)
            default:
                showOrHideIndicator(loadingState: state)
            }
        }
    }
    
    var pageIndex: Int = 1
    
    let refreshPageIndex: Int = 1
    
    let loadSignal = PublishSubject<Int>()
    
    var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
               
        makeUI()
        trigger()
        refreshData()
    }
    
    func makeUI()  {
        
        navigationItem.title = "动态通知"
        
        tableView = UITableView(frame: .zero, style: .plain)
        tableView.rowHeight = 92
        tableView.estimatedRowHeight = 0
        tableView.dataSource = self
        tableView.delegate = self
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { maker in
            maker.edges.equalToSuperview()
        }

        tableView.register(UINib(nibName: "NotificationViewCell", bundle: nil), forCellReuseIdentifier: "NotificationViewCell")
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

extension NotificationViewController {
    
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
    
    func loadData(_ page: Int) -> Single<Response<Pagination<Notice>>> {
        return API.request(.dynamicNewsList(dynamicId: "0", page: page))
    }
    
    func handlerReponse(_ response: Response<Pagination<Notice>>){

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
    
    func refreshData(_ data: [Notice]) {
        if !data.isEmpty {
            self.data = data
        }
    }
    
    func appendData(_ data: [Notice]) {
        self.data.append(contentsOf: data)
    }
    
    func handlerError(_ error: Error) {
        if data.isEmpty {
            state = .error
        }
        endRefreshing()
       
    }
}

extension NotificationViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let model = data[indexPath.row]
        
        let dynamic = model.data!
        showIndicator()
        API.request(.dynamicInfo(dynamicId: dynamic.dynamicId), type: Response<Dynamic>.self)
            .subscribe(onSuccess: { [unowned self] response in
                model.isRead = true
                let vc = DynamicListViewController(dynamic: response.data!)
                self.navigationController?.pushViewController(vc, animated: true)
                self.hideIndicator()
            }, onError: { [weak self] error in
                self?.hideIndicator()
                self?.show(error)
            })
            .disposed(by: rx.disposeBag)
        
       
    }
    
}

extension NotificationViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let model = data[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(for: indexPath, cellType: NotificationViewCell.self)
        
        cell.set(model)
        
        return cell
    }
}
