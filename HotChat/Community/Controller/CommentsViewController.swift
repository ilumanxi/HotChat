//
//  CommentsViewController.swift
//  Comments
//
//  Created by 风起兮 on 2021/3/2.
//

import UIKit
import PanModal
import RxCocoa
import RxSwift
import MJRefresh
import SPAlertController
import Jelly
import Aquaman

    
class CommentsViewController: UIViewController, AquamanChildViewController, IndicatorDisplay {
    
    var containerView: UIView {
        return wrapView
    }
    
    func aquamanChildScrollView() -> UIScrollView {
        return tableView
    }
    
    @IBOutlet weak var wrapView: UIView!
    
    @IBOutlet weak var tableView: UITableView!
    
    let dynamic: Dynamic
    
    var data: [Comment] = [] {
        didSet {
            state = data.isEmpty ? .noContent : .contentLoaded
        }
    }
    
    let API = Request<DynamicAPI>()
    
    var state: LoadingState = .initial {
        didSet {
            if state == .noContent {
                showOrHideIndicator(loadingState: state, in: containerView, text: "首条评论可坐上沙发哟~", image: UIImage(), actionText: nil)
            }
            else {
                showOrHideIndicator(loadingState: state, in: containerView)
            }
        }
    }
    
    var pageIndex: Int = 1
    
    let refreshPageIndex: Int = 1
    
    let loadSignal = PublishSubject<Int>()
    
    var animator: Animator?
    
    
    init(dynamic: Dynamic) {
        self.dynamic = dynamic
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        registerItem()
        
        loadSignal
            .subscribe(onNext: requestData)
            .disposed(by: rx.disposeBag)
        
        tableView.mj_header = MJRefreshNormalHeader { [weak self] in
            self?.refreshData()
        }
        
        tableView.mj_footer = MJRefreshAutoNormalFooter{ [weak self] in
            self?.loadMoreData()
        }
        
        refreshData()
    }
    
    
    private func registerItem() {
        
        let titleItem = UIBarButtonItem(title: "评论", style: .done, target: nil, action: nil)
        navigationItem.leftBarButtonItem = titleItem

        titleItem.setTitleTextAttributes(
            [
                .font : UIFont.title,
                .foregroundColor : UIColor.titleBlack
            ],
            for: .normal)
        
        tableView.register(UINib(nibName: "CommentFooterView", bundle: nil), forHeaderFooterViewReuseIdentifier: "CommentFooterView")
        tableView.register(UINib(nibName: "CommentViewCell", bundle: nil), forCellReuseIdentifier: "CommentViewCell")
    }
    
    
    @IBAction func inputAction(_ sender: Any) {
        
        let vc = InputViewController()
        
        vc.onSend.delegate(on: self) { (self, text) in
            
            self.comment(text: text, parent: nil, child: nil)
        }
        
        present(vc, animated: true, completion: nil)
    }
    
    func comment(text: String, parent: Comment?, child: Comment?) {
        
        showIndicator()
        API.request(.comment(content: text, dynamicId: dynamic.dynamicId, parentId: parent?.commentId, commentId: child?.commentId), type: Response<Comment>.self)
            .verifyResponse()
            .subscribe(onSuccess: { [weak self] response in
                self?.handle(data: response.data!, parent: parent, child: child)
                self?.hideIndicator()
            }, onError: { [weak self] error in
                self?.hideIndicator()
                if error._code == -1 {
                    let vc = VipBuyViewController()
                    vc.onBuy.delegate(on: self!) { (self, _) in
                        
                        let vc = WebViewController.H5(path: "h5/vip")
                        vc.navigationBarAlpha = 0
                        vc.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "navigation-bar-back"), style: .done, target: self, action: #selector(self.close(_:)))
                        let viewControllerToPresent = BaseNavigationController(rootViewController: vc)
                        
                        let interactionConfiguration = InteractionConfiguration(presentingViewController: self, completionThreshold: 0.5, dragMode: .edge)
                        let uiConfiguration = PresentationUIConfiguration(backgroundStyle: .dimmed(alpha: 0.5))
                        let presentation = SlidePresentation(uiConfiguration: uiConfiguration, direction: .right, size: .fullscreen, interactionConfiguration: interactionConfiguration)
                        let animator = Animator(presentation: presentation)
                        animator.prepare(presentedViewController: viewControllerToPresent)
                        self.animator = animator
                        viewControllerToPresent.rx.methodInvoked(#selector(UIViewController.viewDidDisappear(_:)))
                            .subscribe(onNext: { [weak self] _ in
                                self?.panModalSetNeedsLayoutUpdate()
                            })
                            .disposed(by: self.rx.disposeBag)
                        self.present(viewControllerToPresent, animated: true) {
                            self.panModalSetNeedsLayoutUpdate()
                        }
                        
                    }
                    self?.present(vc, animated: true, completion: nil)
                }
                else {
                    self?.show(error)
                }
            })
            .disposed(by: rx.disposeBag)
    }
    
    @objc func close(_ sender: Any) {
        
        presentedViewController?.dismiss(animated: true, completion: {
//            self.panModalSetNeedsLayoutUpdate()
        })
    }
    
    func handle(data: Comment, parent: Comment?, child: Comment?) {
        if parent == nil &&  child == nil { // 动态评论
            self.data.insert(data, at: 0)
        }
        else if parent != nil && child == nil { //动态评论回复
            parent?.nextList.append( data)
            parent?.childCommentCount += 1
        }
        else if parent != nil && child != nil { //动态评论回复的评论进行回复
            parent?.nextList.append(data)
            parent?.childCommentCount += 1
        }
        else {
            fatalError()
        }
        tableView.reloadData()
    }
}

extension CommentsViewController {
    
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
    
    func loadData(_ page: Int) -> Single<Response<Pagination<Comment>>> {
         
        return API.request(.commentList(dynamicId: dynamic.dynamicId, parentId: nil, page: page))
    }
    
    func handlerReponse(_ response: Response<Pagination<Comment>>){

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
        
        navigationItem.leftBarButtonItem?.title =  "评论 (\(page.count))"
       
        endRefreshing(noContent: !page.hasNext)
    }
    
    func refreshData(_ data: [Comment]) {
        if !data.isEmpty {
            self.data = data
        }
    }
    
    func appendData(_ data: [Comment]) {
        self.data.append(contentsOf: data)
    }
    
    func handlerError(_ error: Error) {
        if data.isEmpty {
            state = .error
        }
        endRefreshing()
       
    }
}

extension CommentsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let vc = InputViewController()
        
        let parent = data[indexPath.section]
        var child: Comment? = nil
        
        if indexPath.row == 0 { // 评论
            vc.inputBar.textField.placeholder = "回复\(parent.userInfo.nick)："
        }
        else { // 回复
            child = parent.nextList[indexPath.item - 1]
            vc.inputBar.textField.placeholder = "回复\(child!.userInfo.nick)："
            
        }
        vc.onSend.delegate(on: self) { (self, text) in
            
            self.comment(text: text, parent: parent, child: child)
        }
        
        present(vc, animated: true, completion: nil)
    }
}

extension CommentsViewController: UITableViewDataSource {
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let comment = data[section]
        
        if comment.isExpanded {
            return comment.nextList.count + 1
        }
        else if comment.nextList.count > 1 {
            return 2
        }
        
        return comment.nextList.count + 1
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        let comment = data[section]
        
        if comment.childCommentCount <= 1 {
            return nil
        }
        
        let footer = tableView.dequeueReusableHeaderFooterView(CommentFooterView.self)
        footer?.layoutMargins = UIEdgeInsets(top: 0, left: 48 + 15, bottom: 0, right: 0)
        footer?.section = section
        
        let close = comment.isExpanded && comment.isAllLoad
        
        footer?.titleLabel.text = close ? "收起回复" : "展开更多回复"
        footer?.disclosureButton.isSelected = close
        footer?.onTapped.delegate(on: self, block: { (self, section) in
            
            if !comment.isExpanded && !comment.isAllLoad { //没有铺开，还没加载数据
                comment.isExpanded = true
                self.loadMoreReply(comment: comment)
            }
            else if comment.isExpanded && !comment.isAllLoad { //已经铺开，还没加载完数据
                self.loadMoreReply(comment: comment)
            }
            else { // 数据加载完成
                comment.isExpanded = !comment.isExpanded
                tableView.reloadData()
            }
           
        })
        
        return footer
    }
    
    func loadMoreReply(comment: Comment) {
        
        showIndicator()
        API.request(.commentList(dynamicId: dynamic.dynamicId, parentId: comment.commentId, page: comment.nextPage), type: Response<Pagination<Comment>>.self)
            .verifyResponse()
            .subscribe(onSuccess: { [weak self] response in
                
                self?.handleReply(comment: comment, response: response)
                
                self?.hideIndicator()
                
            }, onError: { [weak self] error in
                self?.hideIndicator()
                self?.show(error)
            })
            .disposed(by: rx.disposeBag)
    }
    
    func handleReply(comment: Comment, response: Response<Pagination<Comment>>)  {
        let data = response.data?.list ?? []
        
        
        if response.data!.page == 1 {
            comment.nextList = data
        }
        else {
            comment.nextList.append(contentsOf: data)
        }
        
        if !data.isEmpty {
            comment.nextPage += 1
        }
        
        comment.isAllLoad = !response.data!.hasNext
        
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        if data[section].childCommentCount <= 1 {
            return 0.01
        }
        
        return 28
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(for: indexPath, cellType: CommentViewCell.self)
        let comment: Comment
        
        if indexPath.row == 0 {
            cell.layoutMargins = .zero
            cell.separatorInset = UIEdgeInsets(top: 0, left: 48 + 15, bottom: 0, right: 0)
            comment = data[indexPath.section]
            cell.setComment(comment)
        }
        else {
            
            cell.layoutMargins = UIEdgeInsets(top: 0, left: 48 + 15, bottom: 0, right: 0)
            cell.separatorInset = UIEdgeInsets(top: 0, left: UIView.layoutFittingExpandedSize.width, bottom: 0, right: 0)
            comment = data[indexPath.section].nextList[indexPath.item - 1]
            cell.setComment(comment)
        }
        
        cell.onLikeTapped.delegate(on: self) { (self, sender) in
            self.like(comment)
        }
        return cell
        
    }
    
    @IBAction func handleLongPress(_ sender: UILongPressGestureRecognizer) {
        
        let point = sender.location(in: tableView)
        
        guard let indexPath = tableView.indexPathForRow(at: point), sender.state == .began else { return }
        
        let parent = data[indexPath.section]
        
        var child: Comment? = nil
        
        if indexPath.row > 0 {
            child = parent.nextList[indexPath.item - 1]
        }
        
        let alertController = SPAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let comment = child ?? parent
        
        if  comment.userInfo.userId == LoginManager.shared.user!.userId {
            alertController.addAction(SPAlertAction(title: "删除", style: .destructive, handler: {  [weak self] _ in
                self?.delete(parent: parent, child: child)
            }))
        }
        alertController.addAction(SPAlertAction(title: "举报", style: .default, handler: { [weak self] _ in
            let vc = CommentReportViewController()
            vc.onSubmit.delegate(on: self!) { (self, content) in
                self.report(child ?? parent, content: content)
            }
            self?.present(vc, animated: true, completion: nil)
        }))
        
        alertController.addAction(SPAlertAction(title: "取消", style: .default, handler: { action in
            
        }))
         
        present(alertController, animated: true, completion: nil)
        
    }
    
    func report(_ comment: Comment, content: String) {
        API.request(.commentReport(content: content, dynamicId: dynamic.dynamicId, commentId: comment.commentId), type: ResponseEmpty.self)
            .subscribe(onSuccess: { [weak self] response in
                self?.show(response.msg)
                
            }, onError: { [weak self] error in
                self?.show(error)
            })
            .disposed(by: rx.disposeBag)
    }
    
    func delete(parent: Comment, child: Comment?) {
        
        let commentId = child?.commentId ?? parent.commentId
        
        showIndicator()
        API.request(.delComment(commentId: commentId), type: Response<Comment>.self)
            .verifyResponse()
            .subscribe(onSuccess: { [weak self] response in
                
                if let childComment = child, let index = parent.nextList.firstIndex(of: childComment) {
                    parent.nextList.remove(at: index)
                    parent.childCommentCount -= 1
                }
                else if let index = self?.data.firstIndex(of: parent) {
                    self?.data.remove(at: index)
                }
                self?.tableView.reloadData()
                self?.hideIndicator()
            }, onError: { [weak self] error in
                self?.hideIndicator()
                self?.show(error)
                
            })
            .disposed(by: rx.disposeBag)
    }
    
    func like(_ comment: Comment)  {
        
        API.request(.commentZan(dynamicId: dynamic.dynamicId, commentId: comment.commentId), type: Response<[String : Any]>.self)
            .subscribe(onSuccess: {[weak self] response in
                guard
                      let zanNum = response.data?["zanNum"] as? Int,
                      let isSelfZan = response.data?["type"] as? Bool else {
                    return
                }
                
                comment.zanNum = zanNum
                comment.isSelfZan = isSelfZan
                self?.tableView.reloadData()
                
            }, onError: { error in
                Log.print(error)
            })
            .disposed(by: rx.disposeBag)
        
    }
}


extension CommentsViewController: PanModalPresentable {
    
    var panScrollable: UIScrollView? {
        return nil
    }
    
    var longFormHeight: PanModalHeight {
        
        if traitCollection.verticalSizeClass == .compact {
            
        }
        
        let scale: CGFloat = 407.0 / 667.0
        
        return .contentHeight(UIScreen.main.bounds.height * scale)
    }
    
    var panModalBackgroundColor: UIColor {
        return UIColor.black.withAlphaComponent(0.5)
    }
    
    var showDragIndicator: Bool {
        return false
    }
    
    
}


class PanModalNavigationController: BaseNavigationController {
    
}

extension PanModalNavigationController: PanModalPresentable {
    
    var panScrollable: UIScrollView? {
        return nil
    }
    
    var longFormHeight: PanModalHeight {
        
        if traitCollection.verticalSizeClass == .compact {
            
        }
        
        let scale: CGFloat = 407.0 / 667.0
        
        return .contentHeight(UIScreen.main.bounds.height * scale)
    }
    
    var panModalBackgroundColor: UIColor {
        return UIColor.black.withAlphaComponent(0.5)
    }
    
    var showDragIndicator: Bool {
        return false
    }
}
