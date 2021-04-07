//
//  DynamicInfoViewController.swift
//  HotChat
//
//  Created by 风起兮 on 2021/4/6.
//  Copyright © 2021 风起兮. All rights reserved.
//

import UIKit
import Aquaman
import RxCocoa
import RxSwift
import MJRefresh

class DynamicInfoViewController: UIViewController, AquamanChildViewController, IndicatorDisplay {
    
    func aquamanChildScrollView() -> UIScrollView {
        tableView
    }
    
    enum InfoType: Int {
        case zan
        case gift
        
        var noConent: String {
            switch self {
            case .zan:
                return "暂无点赞，可要求好友前来围观呀"
            case .gift:
                return "万水千山总是情，有无礼物都可行对吧~"
            }
        }
    }
    
    let infoType: InfoType
    let dynamic: Dynamic
    
    init(infoType: InfoType, dynamic: Dynamic) {
        self.infoType = infoType
        self.dynamic = dynamic
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var data: [DynamicInfo] = []
    
    let API = Request<DynamicAPI>()
    
    var state: LoadingState = .initial {
        didSet {
            
            switch state {
            case .noContent:
                showOrHideIndicator(loadingState: state, text: infoType.noConent, image: UIImage(), actionText: nil)
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
        tableView = UITableView(frame: .zero, style: .plain)
        tableView.rowHeight = 70
        tableView.estimatedRowHeight = 0
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = .white
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { maker in
            maker.edges.equalToSuperview()
        }

        tableView.register(UINib(nibName: "UserInfoViewCell", bundle: nil), forCellReuseIdentifier: "UserInfoViewCell")
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

extension DynamicInfoViewController {
    
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
    
    func loadData(_ page: Int) -> Single<Response<Pagination<DynamicInfo>>> {
        switch infoType {
        case .zan:
            return API.request(.dynamicZanList(dynamicId: dynamic.dynamicId, page: page))
        case .gift:
            return API.request(.dynamicGiftList(dynamicId: dynamic.dynamicId, page: page))
        }
    }
    
    func handlerReponse(_ response: Response<Pagination<DynamicInfo>>){

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
    
    func refreshData(_ data: [DynamicInfo]) {
        if !data.isEmpty {
            self.data = data
        }
    }
    
    func appendData(_ data: [DynamicInfo]) {
        self.data.append(contentsOf: data)
    }
    
    func handlerError(_ error: Error) {
        if data.isEmpty {
            state = .error
        }
        endRefreshing()
       
    }
}

extension DynamicInfoViewController: UITableViewDelegate {
    
    
}

extension DynamicInfoViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let model = data[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(for: indexPath, cellType: UserInfoViewCell.self)
        
        cell.set(model)
        
        switch infoType {
        case .zan:
            let image = UIImage(named: "like-selected")
            let imageView = UIImageView(image: image)
            cell.accessoryView = imageView
        case .gift:
            let label = UILabel()
            label.font = .systemFont(ofSize: 14, weight: .medium)
            label.textColor = UIColor(hexString: "#FF4C5D")
            label.text = model.content
            label.sizeToFit()
            cell.accessoryView = label
        }
        return cell
    }
}
