//
//  SearchViewController.swift
//  HotChat
//
//  Created by 风起兮 on 2020/10/20.
//  Copyright © 2020 风起兮. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Kingfisher
import MJRefresh

/// // to fix height of the navigation bar
class SearchBarContainerView: UIView {
    
    
    lazy var searchBar: UISearchBar = {
        let bar = UISearchBar()
        bar.searchBarStyle = .minimal
        bar.showsCancelButton = true
        bar.placeholder = "请输入昵称/ID"
        return bar
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    func setupViews() {
        addSubview(searchBar)
        searchBar.snp.makeConstraints { maker in
            maker.leading.trailing.centerY.equalToSuperview()
            maker.top.bottom.greaterThanOrEqualToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var intrinsicContentSize: CGSize {
        
        return UIView.layoutFittingExpandedSize
    }
    
}



class SearchViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, IndicatorDisplay {
    
    struct SearchParameters {
        let searchContent: String
        let page: Int
    }

    
    @IBOutlet weak var tableView: UITableView!
    
    
    var searchBarContainerView = SearchBarContainerView()
    
    lazy var searchBar: UISearchBar = {
        searchBarContainerView.searchBar.delegate = self
        return searchBarContainerView.searchBar
    }()
    
    
    var page: Int = 1
    
    var data: [User] = [] {
        didSet {
            showOrHideIndicator(loadingState: data.isEmpty ? .noContent : .contentLoaded)
            tableView.reloadData()
            tableView.mj_footer?.isHidden = data.isEmpty
        }
    }
    
    let loadSignal = PublishSubject<Void>()
    
    let searchAPI = Request<SearchAPI>()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.titleView = searchBarContainerView
        navigationItem.hidesBackButton = true
        
        tableView.mj_footer = MJRefreshAutoNormalFooter{ [weak self] in
            self?.loadSignal.onNext(())
        }
        tableView.mj_footer?.isHidden = true

        
        searchBar.rx.text.orEmpty
            .subscribe(onNext: { [weak self] _ in
                self?.page = 1
                self?.tableView.mj_footer?.resetNoMoreData()
            })
            .disposed(by: rx.disposeBag)
        
        
        
        Observable.of(searchBar.rx.searchButtonClicked.asObservable(), loadSignal.asObserver())
            .merge()
            .do(onNext: { [weak self] in
                self?.data = []
                self?.searchBar.resignFirstResponder()
            })
//            .map(parameters)
//            .flatMapLatest(loadData)
            .map{[unowned self] in self.parameters() }
            .flatMapLatest{[unowned self] parameters in self.loadData(parameters: parameters)}
            .subscribe(onNext: { [weak self] response in
                self?.handlerReponse(response)
            }, onError: { [weak self] error in
                self?.handlerError(error)
            })
            .disposed(by: rx.disposeBag)
    }
    
    func loadData(parameters : SearchParameters) -> Single<Response<Pagination<User>>> {
        return searchAPI.request(.searchList(searchContent: parameters.searchContent, page: parameters.page)).verifyResponse()
    }
    
    func parameters() -> SearchParameters {
        return SearchParameters(searchContent: searchBar.text ?? "", page: page)
    }
    
    func handlerReponse(_ response: Response<Pagination<User>>){

        guard let page = response.data, let data = page.list else {
            return
        }
        
        if page.handleType == 0 || page.handleType == 1 || page.page == 1 {
            refreshData(data)
        }
        else {
            appendData(data)
        }
        
        if page.hasNext{
            self.page += 1
        }
        
        endRefreshing(noContent: !page.hasNext)
        
    }
    
    func refreshData(_ data: [User]) {
        
        self.data = data
    }
    
    func appendData(_ data: [User]) {
        self.data = self.data + data
    }
    
    func handlerError(_ error: Error) {
        endRefreshing()
        show(error)
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        searchBar.becomeFirstResponder()
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 106
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let user = data[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(for: indexPath, cellType: ChannelCell.self)
        cell.setUser(user)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        defer {
            tableView.deselectRow(at: indexPath, animated: true)
        }
        
        let user = data[indexPath.row]
        
        let vc = UserInfoViewController()
        vc.user = user
        navigationController?.pushViewController(vc, animated: true)
        
    }
    
}

extension OnlineStatus {
    
    var text: String? {
        switch self {
        case .online:
            return "在线"
        case .living:
            return "直播中"
        case .offline:
            return "离线"
        }
    }
    
    var color: UIColor? {
        switch self {
        case .online:
           return UIColor(hexString: "#1AD36E")
        case .living:
            return UIColor(hexString: "#FF788C")
        case .offline:
            return nil
        }
    }
    
}


extension SearchViewController: UISearchBarDelegate {
    
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        navigationController?.popViewController(animated: true)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
    }
}
