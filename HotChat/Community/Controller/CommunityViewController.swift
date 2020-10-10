//
//  CommunityViewController.swift
//  HotChat
//
//  Created by 风起兮 on 2020/9/9.
//  Copyright © 2020 风起兮. All rights reserved.
//

import UIKit
import HBDNavigationBar
import SegementSlide
import RxCocoa
import RxSwift
import NSObject_Rx
import Reusable


class DemoViewController: UITableViewController, SegementSlideContentScrollViewDelegate {
    var scrollView: UIScrollView {
        return tableView
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 100
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell()
        cell.textLabel?.text = indexPath.description
        return cell
        
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = UIViewController()
        vc.title = indexPath.description
        vc.view.backgroundColor = .random
               
        navigationController?.pushViewController(vc, animated: true)
    }
    

}
    
class CommunityViewController: UIViewController {
    


    let dynamicAPI = RequestAPI<DynamicAPI>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        hbd_barHidden = true
        
//        defaultSelectedIndex = 0
//        reloadData()
        
        dynamicAPI.request(.recommendList, type: Response<[Dynamic]>.self)
            .subscribe(onSuccess: { response in
                Log.print(response)
            }, onError: { error in
                Log.print(error)
            })
            .disposed(by: rx.disposeBag)
        
    }
    
    //    override var bouncesType: BouncesType {
    //        return .child
    //    }
    //
    //    private lazy var contentViewControllers: [DemoViewController] =  {
    //
    //        let recommend = DemoViewController()
    //        recommend.title = "推荐"
    //
    //        let vlog = DemoViewController()
    //        vlog.title = "小视频"
    //
    //        return [recommend, vlog]
    //    }()
    //
    //    private var contentTitles: [String] {
    //        contentViewControllers.compactMap { $0.title }
    //    }
    //
    //    override var titlesInSwitcher: [String] {
    //        return contentTitles
    //    }
        
        
    //    private lazy var communityHeaderView: CommunityHeaderView =  {
    //
    //        let headerView = CommunityHeaderView.loadFromNib()
    //        headerView.translatesAutoresizingMaskIntoConstraints = false
    //        headerView.contentView.widthAnchor.constraint(equalToConstant: self.view.frame.width).isActive = true
    //        let size = headerView.contentView.systemLayoutSizeFitting(UIView.layoutFittingExpandedSize)
    //        headerView.heightAnchor.constraint(equalToConstant: size.height + UIApplication.shared.statusBarFrame.height).isActive = true
    //        headerView.contentView.widthAnchor.constraint(equalToConstant: self.view.frame.width).isActive = false
    //
    //        return headerView
    //    }()
    //
    //    override func segementSlideHeaderView() -> UIView {
    //
    //        return communityHeaderView
    //    }
    //
    //    override func segementSlideContentViewController(at index: Int) -> SegementSlideContentScrollViewDelegate? {
    //
    //        return contentViewControllers[index]
    //    }
    
//    override func scrollViewDidScroll(_ scrollView: UIScrollView, isParent: Bool) {
//        super.scrollViewDidScroll(scrollView, isParent: isParent)
//        guard isParent else {
//            return
//        }
//        updateNavigationBarStyle(scrollView)
//    }
//
//    private func updateNavigationBarStyle(_ scrollView: UIScrollView) {
//
//        let isHidden = (scrollView.contentOffset.y / headerStickyHeight) >= 1.0
//
//        if communityHeaderView.toolBarView.isHidden != isHidden {
//            communityHeaderView.toolBarView.isHidden = isHidden
//        }
//    }
    
}
