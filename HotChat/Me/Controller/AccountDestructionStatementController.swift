//
//  AccountDestructionStatementController.swift
//  HotChat
//
//  Created by 风起兮 on 2020/12/23.
//  Copyright © 2020 风起兮. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class AccountDestructionStatementController: UIViewController {
    
    
    @IBOutlet weak var destructionButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupViews()
        
        let countdown =  Observable<Int>.countdown(15).share(replay: 1)
        
        countdown
            .subscribe(
                onNext: { [unowned self] seconds in
                    self.destructionButton.isEnabled = false
                    self.destructionButton.setTitle("申请注销\(seconds)s", for: .disabled)
                    self.destructionButton.backgroundColor = UIColor(hexString: "#BDBDBD")
                },
                onCompleted: {
                    self.destructionButton.isEnabled = true
                    self.destructionButton.setTitle("申请注销", for: .normal)
                    self.destructionButton.backgroundColor = UIColor(hexString: "#FF3F3F")
            })
            .disposed(by: rx.disposeBag)
    }

    
    func setupViews(){
        
        title = "账号注销"
        
        let webViewController = WebViewController.H5(path: "h5/logout/txt")
        addChild(webViewController)
        webViewController.willMove(toParent: self)
        view.addSubview(webViewController.view)
        webViewController.view.snp.makeConstraints { maker in
            
            maker.top.leading.trailing.equalToSuperview()
            maker.bottom.equalTo(destructionButton.snp.top).offset(-20)
        }
        
        webViewController.didMove(toParent: self)
    }
    
    
    @IBAction func destructionButtonTapped(_ sender: Any) {
        
        let vc = AccountDestructionController(style: .password)
        navigationController?.pushViewController(vc, animated: true)
    }
    
}
