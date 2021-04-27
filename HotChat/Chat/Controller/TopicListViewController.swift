//
//  TopicListViewController.swift
//  HotChat
//
//  Created by 风起兮 on 2021/3/17.
//  Copyright © 2021 风起兮. All rights reserved.
//

import UIKit


class TopicListViewController: UICollectionViewController, LoadingStateType, IndicatorDisplay {
    
    var state: LoadingState = .initial {
        didSet {
            showOrHideIndicator(loadingState: state)
        }
    }
    
    let columnFlowLayout = ColumnFlowLayout()
    
    let API = Request<GroupChatAPI>()
    
    var data: [GroupTopic] = [] {
        didSet
        {
            collectionView.reloadData()
        }
    }
    
    init() {
        super.init(collectionViewLayout: columnFlowLayout)
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "话题热聊"

        collectionView.layoutMargins = UIEdgeInsets(top: 8, left: 15, bottom: 8, right: 15)
        collectionView.backgroundColor = UIColor(hexString: "#F6F7F9")
        
        self.collectionView.register(UINib(nibName: "TopicListViewCell", bundle: nil), forCellWithReuseIdentifier: "TopicListViewCell")
        // Do any additional setup after loading the view.
        
        refreshData()
        
        
    }
    
    
    func pushVip() {
        
        let vc = WebViewController.H5(path: "h5/vip")
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func refreshData() {
        
        state = .refreshingContent
        
        API.request(.groupList, type: Response<[GroupTopic]>.self)
            .verifyResponse()
            .subscribe(onSuccess: { [weak self] response in
                guard let self = self else { return }
                
                self.data = response.data ?? []
                
                self.state =  self.data.isEmpty ? .noContent : .contentLoaded
                
            }, onError: { [weak self] error in
                self?.state = .error
                self?.show(error)
                
            })
            .disposed(by: rx.disposeBag)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return data.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(for: indexPath, cellType: TopicListViewCell.self)
        cell.set(data[indexPath.item])
        
  
    
        // Configure the cell
    
        return cell
    }

    // MARK: UICollectionViewDelegate

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let model = data[indexPath.item]
        
        checkjoinGroup(model)
    }

    func checkjoinGroup(_ gorup: GroupTopic) {
        showIndicator()
        API.request(.groupStatus(groupId: gorup.groupId), type: Response<[String : Any]>.self)
            .verifyResponse()
            .subscribe(onSuccess: { [weak self] response in
                self?.hideIndicator()
               
                guard let self = self, let resultCode = response.data?["resultCode"] as? Int, let msg =  response.data?["msg"] as? String else {
                    return
                }
                
                
                guard let status = ChatTopicStatusViewController.Status(rawValue: resultCode) else {
                    self.show(msg)
                    return
                }
                
                switch status {
                case .normal:
                    self.joinGroup(gorup)
                case .crowd, .full:
                    self.pushChatTopicStatus(status)
                }
                
            }, onError: { [weak self] error in
                
                self?.hideIndicator()
                self?.show(error)
                
            })
            .disposed(by: rx.disposeBag)
    }
    
    func pushChatTopicStatus(_ status: ChatTopicStatusViewController.Status) {
        let vc  = ChatTopicStatusViewController(status: status)

        vc.buyVip.delegate(on: self) { (self, _) in
            self.pushVip()
        }

        present(vc, animated: true, completion: nil)
    }
    

    func joinGroup(_ gorup: GroupTopic)  {
        
        V2TIMManager.sharedInstance()?.joinGroup(gorup.groupId, msg: nil, succ: {
            self.pushChatTopic(gorup)
        }, fail: { (code, desc) in
            if code == 10013 { //   already group member
                self.pushChatTopic(gorup)
            }
            else {
                self.show(desc)
            }
        })
        
    }
    
    func pushChatTopic(_ gorup: GroupTopic) {
        let conversation =  TUIConversationCellData()
        conversation.groupID = gorup.groupId
        
        guard let vc = ChatTopicViewController(conversation: conversation) else { return  }
        vc.title = gorup.name
        navigationController?.pushViewController(vc, animated: true)
    }
}
