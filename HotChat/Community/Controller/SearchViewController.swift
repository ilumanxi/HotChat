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



class SearchViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, IndicatorDisplay {
    
    struct SearchParameters {
        let searchContent: String
        let page: Int
    }

    
    @IBOutlet weak var tableView: UITableView!
    
    
    lazy var searchBar: UISearchBar = {
        
        let bar = UISearchBar()
        bar.showsCancelButton = true
        bar.placeholder = "请输入昵称/ID"
        bar.delegate = self
        bar.sizeToFit()
        
        return bar
    }()
    
    
    var page: Int = 1
    
    var data: [User] = [] {
        didSet {
            tableView.reloadData()
            tableView.mj_footer?.isHidden = data.isEmpty
        }
    }
    
    let loadSignal = PublishSubject<Void>()
    
    let searchAPI = Request<SearchAPI>()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.titleView = searchBar
        
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
            .map(parameters)
            .flatMapLatest(loadData)
            .subscribe(onNext: handlerReponse, onError: handlerError)
            .disposed(by: rx.disposeBag)
    }
    
    func loadData(parameters : SearchParameters) -> Single<Response<Pagination<User>>> {
        return searchAPI.request(.searchList(searchContent: parameters.searchContent, page: parameters.page)).checkResponse()
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
        show(error.localizedDescription)
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
        
        let cell = tableView.dequeueReusableCell(for: indexPath, cellType: SearchViewCell.self)
        configureCell(cell, for: indexPath)
        
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
    
    func configureCell(_ cell: SearchViewCell, for indexPath: IndexPath) {
        
        let user = data[indexPath.row]
        
        cell.avatarImageView.kf.setImage(with: URL(string: user.headPic))
        cell.nicknameLabel.text = user.nick
        if user.onlineStatus == 1 {
            cell.statusLabel.text = "在线"
            cell.statusLabel.textColor = UIColor(hexString: "#1AD36E")
        }
        else {
            cell.statusLabel.text = "直播中"
            cell.statusLabel.textColor = UIColor(hexString: "#FF788C")
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