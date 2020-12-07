//
//  SayHellowSettingViewController.swift
//  HotChat
//
//  Created by 风起兮 on 2020/12/2.
//  Copyright © 2020 风起兮. All rights reserved.
//

import UIKit

extension ChatGreetStatus {
    
    var textColor: UIColor?  {
        switch self {
        case .empty:
            return UIColor(hexString: "#5159F8")
        case .ok:
            return UIColor(hexString: "#08B91D")
        case .failed:
            return UIColor(hexString: "已驳回")
        }
    }
    
    var text: String?  {
        switch self {
        case .empty:
            return "审核中"
        case .ok:
            return "已通过"
        case .failed:
            return "已驳回"
        }
    }
    
}

class SayHellowSettingViewController: UIViewController, LoadingStateType, IndicatorDisplay {
    
    var state: LoadingState = .initial {
        didSet {
            showOrHideIndicator(loadingState: state, in: tableView)
        }
    }
    
    let API = Request<ChatGreetAPI>()
    
    let limitCount: Int = 15
    
    var data: [ChatGreet] = []
    {
        didSet {
            tableView?.reloadData()
        }
    }
    
    
    @IBOutlet weak var tableView: UITableView!
    
    
    @IBOutlet weak var addButton: UIButton!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        refreshData()
        // Do any additional setup after loading the view.
    }
    
    func setupViews()  {
        title = "打招呼设置"
        tableView.rowHeight = UITableView.automaticDimension
        tableView.backgroundColor = .white
        tableView.hiddenFoooter()
    }

    
    func refreshData() {
        
        state = .refreshingContent
        API.request(.greetList(type: 0), type: Response<[ChatGreet]>.self)
            .verifyResponse()
            .subscribe(onSuccess: { [unowned self] response in
                self.data = response.data ?? []
                self.state = self.data.isEmpty ? .noContent : .contentLoaded
            }, onError: { [weak self] error in
                self?.state = .error
            })
            .disposed(by: rx.disposeBag)
    }
    
    func delete(_ chatGreet: ChatGreet){
        
        showIndicator()
        API.request(.delGreet(id: chatGreet.id), type: ResponseEmpty.self)
            .verifyResponse()
            .subscribe(onSuccess: { [unowned self] response in
                self.data.removeAll { $0.id == chatGreet.id }
                self.hideIndicator()
                self.show(response.msg)
            }, onError: { [unowned self] error in
                self.hideIndicator()
                self.show(error.localizedDescription)
            })
            .disposed(by: rx.disposeBag)
    }
    
    @IBAction func addButtonTapped(_ sender: Any) {

        if data.count >= limitCount {
            show("提示“最多添加\(limitCount)条招呼语")
            return
        }
        
        let vc = SayHellowAddViewController()
        vc.onAdded.delegate(on: self) { (self, _) in
            self.refreshData()
        }
        present(vc, animated: true, completion: nil)
    }
    
}

extension SayHellowSettingViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let model = data[indexPath.row]
        return UISwipeActionsConfiguration(actions: [UIContextualAction(style: .destructive, title: "删除", handler: { [weak self] (action, sourceView, actionPerformed) in
            self?.delete(model)
            
            actionPerformed(true)
        })])
        
    }
    
}

extension SayHellowSettingViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell")
        
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: "UITableViewCell")
            cell?.selectionStyle = .none
            cell?.textLabel?.numberOfLines = 0
            cell?.textLabel?.textColor = UIColor(hexString: "#333333")
            cell?.textLabel?.font = .systemFont(ofSize: 14)
            
            let label = UILabel()
            label.font = .systemFont(ofSize: 14)
            cell?.accessoryView = label
        }
        
        let model = data[indexPath.row]
        
        cell?.textLabel?.text = model.content
        
        if let label = cell?.accessoryView as? UILabel {
            label.text = model.status.text
            label.textColor = model.status.textColor
            label.sizeToFit()
        }
        
        return cell!
    }

}
