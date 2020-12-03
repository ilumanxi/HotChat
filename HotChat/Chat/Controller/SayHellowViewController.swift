//
//  SayHellowViewController.swift
//  HotChat
//
//  Created by 风起兮 on 2020/12/2.
//  Copyright © 2020 风起兮. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class SayHellowViewController: UIViewController, IndicatorDisplay, LoadingStateType {
    
    var state: LoadingState = .initial {
        didSet {
            showOrHideIndicator(loadingState: state)
        }
    }
    
    let API = Request<ChatGreetAPI>()
    
    var data: [ChatGreet] = []
    {
        didSet {
            
            resizeTableView()
        }
    }
    
    let onAddButtonDidTapped = Delegate<Void, Void>()
    
    let onSayHellowButtonDidTapped = Delegate<String, Void>()
    
    var selectedData: String? {
        didSet {
            tableView?.reloadData()
        }
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var tableViewHeightLayout: NSLayoutConstraint!
    
   
    
    init() {
        super.init(nibName: nil, bundle: nil)
        self.modalTransitionStyle = .crossDissolve
        self.modalPresentationStyle = .overFullScreen
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func showOrHideIndicator(loadingState: LoadingState, text: String? = nil, image: UIImage? = nil) {
        showOrHideIndicator(loadingState: loadingState, in: tableView, text: text, image: image)
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
        resizeTableView()
        refreshData()
    }
    
    func refreshData() {
        
        state = .refreshingContent
        API.request(.greetList(type: 1), type: Response<[ChatGreet]>.self)
            .verifyResponse()
            .subscribe(onSuccess: { [unowned self] response in
                self.data = response.data ?? []
                self.state = self.data.isEmpty ? .noContent : .contentLoaded
            }, onError: { [weak self] error in
                self?.state = .error
            })
            .disposed(by: rx.disposeBag)
    }
    
    func setupViews() {
        tableView.backgroundColor = .white
        tableView.hiddenFoooter()
    }
    
    func resizeTableView() {
        tableViewHeightLayout?.constant = max(CGFloat(data.count * 44 + 21), 108.0)
        tableView?.reloadData()
        
    }
    
    
    @IBAction func addButtonTapped(_ sender: Any) {
        dismiss(animated: true) {
            self.onAddButtonDidTapped.call()
        }
    }
    
    
    @IBAction func sayHellowButtonTapped(_ sender: Any) {
        
        guard let text = selectedData else {
            show("选择一个消息打招呼")
            return
        }
        
        dismiss(animated: true) {
            self.onSayHellowButtonDidTapped.call(text)
        }
    }
    

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if touches.first?.view == view {
            dismiss(animated: true, completion: nil)
        }
    }
}

extension SayHellowViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = data[indexPath.row]
        selectedData = model.content
    }
}

extension SayHellowViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell")
        
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: "UITableViewCell")
            cell?.textLabel?.numberOfLines = 2
            cell?.textLabel?.textColor = UIColor(hexString: "#333333")
            cell?.textLabel?.font = .systemFont(ofSize: 14)
        }
        
        let model = data[indexPath.row]
        
        cell?.textLabel?.text = data[indexPath.row].content
        
        
        let isSelected = model.content == selectedData
        
        
        
        cell?.imageView?.image = isSelected ? #imageLiteral(resourceName: "box-selected") : #imageLiteral(resourceName: "box-unselected")
        
        return cell!
    }
    
    
    
    
}
