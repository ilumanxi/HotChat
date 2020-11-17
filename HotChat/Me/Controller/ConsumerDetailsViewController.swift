//
//  SubsidiaryAccountViewController.swift
//  HotChat
//
//  Created by 风起兮 on 2020/11/9.
//  Copyright © 2020 风起兮. All rights reserved.
//

import UIKit
import SegementSlide
import RxSwift
import RxCocoa
import MJRefresh

class ConsumerDetailsViewController: UIViewController, SegementSlideContentScrollViewDelegate, LoadingStateType, IndicatorDisplay {
    
    var state: LoadingState = .initial  {
        didSet {
            if isViewLoaded {
                showOrHideIndicator(loadingState: state)
            }
        }
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    let type: Checklist
    
    @objc var scrollView: UIScrollView {
        return tableView
    }
    
    var pageIndex: Int = 1
    
    let refreshPageIndex: Int = 1
    
    let loadSignal = PublishSubject<Int>()
    
    let consumerAPI = Request<ConsumerAPI>()
    
    var data: [Consumer] = []
    
    init(type: Checklist) {
        self.type = type
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        
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
    
    func setupView() {
        tableView.rowHeight = 60
        tableView.estimatedRowHeight = 0
        tableView.register(UINib(nibName: "SubsidiaryAccountCell", bundle: nil), forCellReuseIdentifier: "SubsidiaryAccountCell")
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
    
    func loadData(_ page: Int) -> Single<Response<Pagination<Consumer>>> {
         
        return consumerAPI.request(.detailsList(page: page, tag: type.tag))
    }
    
    func handlerReponse(_ response: Response<Pagination<Consumer>>){

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
    
    func refreshData(_ data: [Consumer]) {
        if !data.isEmpty {
            self.data = data
        }
    }
    
    func appendData(_ data: [Consumer]) {
        self.data = self.data + data
    }
    
    func handlerError(_ error: Error) {
        if data.isEmpty {
            state = .error
        }
        endRefreshing()
       
    }

}


extension ConsumerDetailsViewController: UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let entity = data[indexPath.row]
        
        
        let cell = tableView.dequeueReusableCell(for: indexPath, cellType: SubsidiaryAccountCell.self)
        cell.evenTextLabel.text = entity.title
        cell.dateTextLabel.text = entity.time
        cell.energyTextLabel.text = "\(entity.type.symbol)\(entity.energy)"
        cell.energyTextLabel.textColor = entity.type.color
        
        return cell
    }
}


extension Checklist {
    
    var tag: Int {
        switch self {
        case .all:
            return 0
        case .earn:
            return 1
        case .expenditure:
            return 3
        case .recharge:
            return 2
        }
    }
}


extension ConsumerType {
    
    var symbol: String {
        switch self {
        case .expense:
            return "-"
        case .earning:
            return "+"
        }
    }
    
    var color: UIColor {
        switch self {
        case .expense:
            return UIColor(hexString: "#333333")
        case .earning:
            return UIColor(hexString: "#FBB819")
        }
    }
}
