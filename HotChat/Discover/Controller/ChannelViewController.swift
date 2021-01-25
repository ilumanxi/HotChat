//
//  ChannelViewController.swift
//  HotChat
//
//  Created by 风起兮 on 2020/10/15.
//  Copyright © 2020 风起兮. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import MJRefresh
import Kingfisher
import FSPagerView
import URLNavigator

class ChannelViewController: UIViewController, LoadingStateType, IndicatorDisplay, StoryboardCreate {
    
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
        
    static var storyboardNamed: String { return "Discover" }
    
    lazy var bannerView: FSPagerView = {
        let headerViewHeight =  self.headerViewHeight
        let bannerView =  FSPagerView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: headerViewHeight))
        bannerView.bounces = false
        bannerView.delegate = self
        bannerView.dataSource = self
//        bannerView.itemSize = FSPagerViewAutomaticSize // Fill parent
        bannerView.itemSize = bannerView.frame.insetBy(dx: 24, dy: 20).size
        bannerView.interitemSpacing = 24
        bannerView.register(FSPagerViewCell.self, forCellWithReuseIdentifier: "FSPagerViewCell")
        bannerView.backgroundColor = .white
        return bannerView
    }()
    
    let bannerAPI = Request<BannerAPI>()
    
    var headerViewHeight: CGFloat {
        return (view.bounds.width / (2 / 0.75)).rounded(.down)
    }
    
    var banners: [Banner] = [] {
        didSet {
         
            if banners.isEmpty {
                self.tableView.tableHeaderView = nil
            }
           
            if self.bannerView.superview == nil {
                self.tableView.tableHeaderView = bannerView
            }
            
            bannerView.reloadData()
        }
    }
    
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
        
        bannerAPI.request(.bannerList(type: 1), type: Response<[Banner]>.self)
            .verifyResponse()
            .subscribe(onSuccess: { [weak self] response in
                self?.banners = response.data ?? []
            }, onError: nil)
            .disposed(by: rx.disposeBag)
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


extension FSPagerViewCell {
    
    open override var isHighlighted: Bool {
        didSet {
            
        }
    }
    
    open override var isSelected: Bool {
        didSet {
            
        }
    }
}

extension ChannelViewController: FSPagerViewDataSource, FSPagerViewDelegate {
    
    
    func numberOfItems(in pagerView: FSPagerView) -> Int {
        return banners.count
    }
    
    func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        let model = banners[index]
        
        let cell = pagerView.dequeueReusableCell(withReuseIdentifier: "FSPagerViewCell", at: index)
        cell.contentView.layer.shadowColor = UIColor.clear.cgColor
        cell.imageView?.kf.setImage(with: URL(string: model.img))
        return cell
    }
    
    func pagerView(_ pagerView: FSPagerView, didSelectItemAt index: Int) {
        
        let model = banners[index]
        guard let url = URL(string: model.url) else { return }
        
        Navigator.share.push(url)
    }
    
}
