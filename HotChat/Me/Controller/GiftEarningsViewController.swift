//
//  GiftEarningsViewController.swift
//  HotChat
//
//  Created by 风起兮 on 2020/11/5.
//  Copyright © 2020 风起兮. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import MJRefresh
import Kingfisher


class GiftEarningsViewController: UIViewController, LoadingStateType, IndicatorDisplay {
    
    var state: LoadingState = .initial  {
        didSet {
            if isViewLoaded {
                showOrHideIndicator(loadingState: state)
            }
        }
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    var pageIndex: Int = 1
    
    let refreshPageIndex: Int = 1
    
    let loadSignal = PublishSubject<Int>()
    
    let consumerAPI = Request<ConsumerAPI>()
    
    var data: [GiftEarning] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        tableView.mj_header?.beginRefreshing()
    }
    
    func setupViews() {
        title = "礼物"
        
        tableView.rowHeight = 70
        tableView.estimatedRowHeight = 0
        tableView.register(UINib(nibName: "GiftEarningsCell", bundle: nil), forCellReuseIdentifier: "GiftEarningsCell")
        
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
            .checkResponse()
            .subscribe(onSuccess: handlerReponse, onError: handlerError)
            .disposed(by: rx.disposeBag)
            
    }
    
    func loadData(_ page: Int) -> Single<Response<Pagination<GiftEarning>>> {
         
        return consumerAPI.request(.profitGiftList(page: page))
    }
    
    func handlerReponse(_ response: Response<Pagination<GiftEarning>>){

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
    
    func refreshData(_ data: [GiftEarning]) {
        if !data.isEmpty {
            self.data = data
        }
    }
    
    func appendData(_ data: [GiftEarning]) {
        self.data = self.data + data
    }
    
    func handlerError(_ error: Error) {
        if data.isEmpty {
            state = .error
        }
        endRefreshing()
       
    }

}

extension GiftEarningsViewController: UITableViewDelegate {
    
}



extension GiftEarningsViewController: UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return data.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(for: indexPath, cellType: GiftEarningsCell.self)
        cell.setModel(data[indexPath.row])
        return cell
    }
}

extension GiftEarningsCell {
    
    func setModel(_ model: GiftEarning){
        giftImageview.kf.setImage(with: URL(string: model.img))
        titleLabel.text = model.title
        timeLabel.text = model.time
        energyLabel.text = model.energy
        nicknameLabel.text = model.nick
    }
    
}
