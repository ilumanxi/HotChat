//
//  ChannelViewController.swift
//  HotChat
//
//  Created by 风起兮 on 2020/10/15.
//  Copyright © 2020 风起兮. All rights reserved.
//

import UIKit
import Aquaman
import RxSwift
import RxCocoa
import MJRefresh
import Kingfisher

class ChannelViewController: UIViewController, LoadingStateType, IndicatorDisplay, AquamanChildViewController, StoryboardCreate {
    
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
    
    let loadSignal = PublishSubject<(type: String, labelId: Int, index: Int)>()
    
    let discoverAPI = Request<DiscoverAPI>()
    
    
    @IBOutlet weak var tableView: UITableView!
    
    func aquamanChildScrollView() -> UIScrollView {
        return tableView
    }
    
    static var storyboardNamed: String { return "Discover" }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        loadSignal.onNext((type: channel.type, labelId: channel.labelId, index: refreshPageIndex))
    }

    func loadMoreData() {
        loadSignal.onNext((type: channel.type, labelId: channel.labelId, index: pageIndex))
    }
    
    func requestData(_ page: (type: String, labelId: Int, index: Int)) {
        if data.isEmpty {
            state = .refreshingContent
        }
         
        loadData(page)
            .verifyResponse()
            .subscribe(onSuccess: handlerReponse, onError: handlerError)
            .disposed(by: rx.disposeBag)
            
    }
    
    func loadData(_ page: (type: String, labelId: Int, index: Int)) -> Single<Response<Pagination<User>>> {
        
        return discoverAPI.request(.discoverList(type: page.type, labelId: page.labelId, page: page.index)).verifyResponse()
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


extension ChannelViewController: UITableViewDataSource, UITableViewDelegate {
    
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

extension ChannelCell {
    
    func setUser(_ user: User) {
       avatarImageView.kf.setImage(with: URL(string: user.headPic))
       nicknameLabel.text = user.nick
       nicknameLabel.textColor = user.vipType.textColor
       sexView.setSex(user)
       locationLabel.text = user.region
       introduceLabel.text = user.introduce
       statusLabel.text = user.onlineStatus.text
       statusLabel.textColor = user.onlineStatus.color
       vipButton.setVIP(user.vipType)
       authenticationButton.isHidden = !user.girlStatus
    }
}
