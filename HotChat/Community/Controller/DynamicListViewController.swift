//
//  DynamicListViewController.swift
//  HotChat
//
//  Created by 风起兮 on 2021/4/6.
//  Copyright © 2021 风起兮. All rights reserved.
//

import UIKit
import Tabman
import Pageboy
import Lantern
import Kingfisher


class DynamicListContainerController: TabmanViewController {
    
    
    var viewControllers: [UIViewController] = []
    var titles: [String] = []
    
    
    init(titles: [String], viewControllers: [UIViewController]) {
        self.titles = titles
        self.viewControllers = viewControllers
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func set(titles: [String], viewControllers: [UIViewController]) {
        self.titles = titles
        self.viewControllers = viewControllers
        reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set PageboyViewControllerDataSource dataSource to configure page view controller.
        dataSource = self
        
        // Create a bar
        let bar = TMBarView.ButtonBar()
        
        // Customize bar properties including layout and other styling.
        bar.layout.contentInset = UIEdgeInsets(top: 0.0, left: 12, bottom: 0, right: 12)
        bar.layout.interButtonSpacing = 24.0
        bar.indicator.weight = .custom(value: 2.5)
        bar.indicator.cornerStyle = .eliptical
        bar.indicator.overscrollBehavior = .none
        bar.layout.showSeparators = false
        bar.fadesContentEdges = true
        bar.spacing = 30.0
        bar.backgroundView.style = .clear
        
        // Set tint colors for the bar buttons and indicator.
        bar.buttons.customize {
            $0.tintColor = UIColor(hexString: "#666666")
            $0.font = .systemFont(ofSize: 17, weight: .medium)
            $0.selectedTintColor = UIColor(hexString: "#333333")
            $0.selectedFont = .systemFont(ofSize: 20, weight: .bold)
        }
        bar.indicator.tintColor = UIColor(hexString: "#FF3F3F")
        bar.backgroundColor = .white
        
        addBar(bar.hiding(trigger: .manual), dataSource: self, at: .top)
        
    }
    
}



extension DynamicListContainerController: PageboyViewControllerDataSource, TMBarDataSource {
    
    // MARK: PageboyViewControllerDataSource
    
    func numberOfViewControllers(in pageboyViewController: PageboyViewController) -> Int {
        viewControllers.count // How many view controllers to display in the page view controller.
    }
    
    func viewController(for pageboyViewController: PageboyViewController, at index: PageboyViewController.PageIndex) -> UIViewController? {
        
        // View controller to display at a specific index for the page view controller.
        viewControllers[index]
    }
    
    func defaultPage(for pageboyViewController: PageboyViewController) -> PageboyViewController.Page? {
        nil // Default page to display in the page view controller (nil equals default/first index).
    }
    
    // MARK: TMBarDataSource
    
    func barItem(for bar: TMBar, at index: Int) -> TMBarItemable {
        
        return TMBarItem(title: titles[index]) // Item to display for a specific index in the bar.
    }
}


class DynamicListViewController: UIViewController, LoadingStateType, IndicatorDisplay {
        
    var headerViewHeight: CGFloat = 0
    private var menuViewHeight: CGFloat = 44.0
    
    var state: LoadingState = .initial {
        didSet {
            if isViewLoaded {
                showOrHideIndicator(loadingState: state)
            }
        }
    }
    
    
    var dynamic: Dynamic!
    
   
    init(dynamic: Dynamic) {
        self.dynamic = dynamic
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    var viewControllers: [UIViewController] = []
    
    fileprivate lazy var  dynamicView: DynamicView  =  {
       let view =  DynamicView.loadFromNib()
        
        view.onImageTapped.delegate(on: self) { (self, context) in
            let collectionView = context.0.collectionView
            let indexPath = context.1
            self.openLantern(with: collectionView?.cellForItem(at: indexPath) as? MediaViewCell, indexPath: indexPath)
        }
        
        view.onDeleteTapped.delegate(on: self) { (self, _) in
            
            let vc =  TipAlertController(title: "提示", message:  "确定删除该消息？", leftButtonTitle: "取消", rightButtonTitle: "确定")
            vc.onRightDidClick.delegate(on: self) { (self, _) in
                self.delete(self.dynamic)
            }
            self.present(vc, animated: true, completion: nil)
        }
        
        return view
    }()
    
    
    
    var containerController: DynamicListContainerController!
     

    let userAPI = Request<UserAPI>()
    
    let dynamicAPI = Request<DynamicAPI>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "动态详情"
        viewControllers = [
            CommentsViewController(dynamic: dynamic),
            DynamicInfoViewController(infoType: .zan, dynamic: dynamic),
            DynamicInfoViewController(infoType: .gift, dynamic: dynamic)
        ]

        makeUI()
        
        refreshData()
    }
    
    
    func display()  {
        dynamicView.dynamic = dynamic
        containerController.set(titles: menuViewTitles(), viewControllers: viewControllers)
    }
    
    
    func makeUI() {
        
        view.backgroundColor = .white
        
        view.addSubview(dynamicView)
        dynamicView.snp.makeConstraints { [unowned self] maker in
            maker.top.equalTo(self.safeTop)
            maker.leading.trailing.equalToSuperview()
        }
        dynamicView.setContentHuggingPriority(UILayoutPriority(rawValue: 900), for: .vertical)
        
        containerController = DynamicListContainerController(titles: menuViewTitles(), viewControllers: viewControllers)
        
        addChild(containerController)
        
        let containerView = containerController.view!
        
        view.addSubview(containerView)
        
        containerView.snp.makeConstraints { [unowned self] maker in
            maker.top.equalTo(self.dynamicView.snp.bottom)
            maker.leading.trailing.bottom.equalToSuperview()
        }
        
        containerController.didMove(toParent: self)
    }
    
    
    func menuViewTitles() -> [String] {
        
        let titles = [
            "评论（\(dynamic.commentCount)）",
            "赞（\(dynamic.zanNum)）",
            "礼物（\(dynamic.giftNum)）",
        ]
        
        return titles
    }
    
    func delete(_ dynamic: Dynamic)  {
        
        showIndicatorOnWindow()
        dynamicAPI.request(.delDynamic(dynamic.dynamicId), type: ResponseEmpty.self)
            .subscribe(onSuccess: {[weak self] response in
                self?.navigationController?.popViewController(animated: true)
                self?.hideIndicatorFromWindow()
            }, onError: { [weak self] error in
                self?.hideIndicatorFromWindow()
                self?.showMessageOnWindow(error)
            })
            .disposed(by: rx.disposeBag)
    }
    
    func openLantern(with view: UIView?, indexPath: IndexPath) {
        let lantern = Lantern()
        
        lantern.numberOfItems = { [unowned self] in
            return self.dynamic.type == DynamicType.image ? self.dynamic.photoList.count : 1
        }
        lantern.cellClassAtIndex = { [unowned self] index in
            if self.dynamic.type == DynamicType.image {
                return LanternImageCell.self
            }
            else {
                return VideoZoomCell.self
            }
        }
        lantern.reloadCellAtIndex = { [unowned self] context in
            
            if let videoCell = context.cell as? VideoZoomCell {
                videoCell.imageView.kf.setImage(with: URL(string: self.dynamic.video!.coverUrl))
                videoCell.player.replaceCurrentItem(with: AVPlayerItem(url: URL(string: self.dynamic.video!.url)!))
            }
            else if let lanternCell = context.cell as? LanternImageCell {
                lanternCell.imageView.kf.setImage(with: URL(string: self.dynamic.photoList[context.index].picUrl))
            }
            
        }
        lantern.cellWillAppear = { cell, index in
            if let videoCell = cell as? VideoZoomCell {
                videoCell.player.play()
            }
        }
        lantern.cellWillDisappear = { cell, index in
            if let videoCell = cell as? VideoZoomCell {
                videoCell.player.pause()
            }
        }
        lantern.transitionAnimator = LanternZoomAnimator(previousView: { index -> UIView? in
            return view
        })
        lantern.pageIndex = indexPath.item
        lantern.show()
    }


    func refreshData() {

        state = .refreshingContent
        dynamicAPI.request(.dynamicInfo(dynamicId: dynamic.dynamicId), type: Response<Dynamic>.self)
            .verifyResponse()
            .subscribe(onSuccess: { [unowned self] response in
                self.dynamic = response.data!
                self.display()
                self.state = .contentLoaded
            }, onError: { [weak self] error in
                self?.state  = .error
            })
            .disposed(by: rx.disposeBag)
       
    }
}

