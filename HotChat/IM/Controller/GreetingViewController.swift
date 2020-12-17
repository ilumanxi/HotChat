//
//  GreetingViewController.swift
//  HotChat
//
//  Created by 风起兮 on 2020/12/17.
//  Copyright © 2020 风起兮. All rights reserved.
//

import UIKit
import SnapKit



@objc protocol GreetingViewControllerDelegate: NSObjectProtocol {
    
     @objc optional  func greetingViewController(_ greetingViewController: GreetingViewController, didSelect content: String)
}


class GreetingViewController: UIViewController, LoadingStateType, IndicatorDisplay {
   
    @objc class var contentHeight: CGFloat  {
        return 210.5 + UIApplication.shared.keyWindow!.safeAreaInsets.bottom
    }
    
    
    var state: LoadingState = .initial
    
    @objc weak var delegate:GreetingViewControllerDelegate?
    
    
    lazy var lineView: SeparatorLine =  {
        let view = SeparatorLine()
        view.backgroundColor = UIColor(r: 186, g: 186, b: 186)
        return view
    }()
    
    
    let API = Request<ChatGreetAPI>()
    
    @IBOutlet weak var tableView: UITableView!
    
    var data: [String] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupViews()
        
        refreshData()
    }
    
    func setupViews()  {
//        view.backgroundColor = UIColor(r: 246, g: 246, b: 246)
        view.backgroundColor = .white
        tableView.backgroundColor = .white
        tableView.hiddenFoooter()
        
        view.addSubview(lineView)
        lineView.snp.makeConstraints { maker in
            maker.leading.trailing.top.equalToSuperview()
        }
    }
    
    func refreshData() {
        
        state = .refreshingContent
        API.request(.userChatWords, type: Response<[[String : Any]]>.self)
            .verifyResponse()
            .subscribe(onSuccess: { [unowned self] response in
                self.data = response.data?.compactMap{ $0["content"] as? String } ?? []
                self.state = self.data.isEmpty ? .noContent : .contentLoaded
                
            }, onError: { [weak self] error in
                self?.state = .error
            })
            .disposed(by: rx.disposeBag)
    }

}

extension GreetingViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        defer {
            tableView.deselectRow(at: indexPath, animated: true)
        }
        
        guard let delegate = delegate, delegate.responds(to: #selector(GreetingViewControllerDelegate.greetingViewController(_:didSelect:))) else { return  }
        
        delegate.greetingViewController?(self, didSelect: data[indexPath.row])
    }
}

extension GreetingViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
            cell?.textLabel?.numberOfLines = 2
            cell?.textLabel?.font = .systemFont(ofSize: 11)
            cell?.textLabel?.textColor = UIColor(hexString: "#999999")
        }
        
        cell?.textLabel?.text = data[indexPath.row]
        
        return cell!
        
    }
    
    
}
