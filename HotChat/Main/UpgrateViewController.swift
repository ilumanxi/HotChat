//
//  UpgrateViewController.swift
//  HotChat
//
//  Created by 风起兮 on 2020/11/18.
//  Copyright © 2020 风起兮. All rights reserved.
//

import UIKit

class UpgrateViewController: UIViewController {
    
    let upgrade: Upgrade
    
    
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var textView: UITextView!
    
    @IBOutlet weak var closeButton: UIButton!
    
    init(upgrade: Upgrade) {
        self.upgrade = upgrade
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }

    func setupView() {
        containerView.layer.cornerRadius = 10
        titleLabel.text = "发现新版本\(upgrade.versionName)可以下载"
        textView.text = upgrade.content
        closeButton.isHidden = upgrade.type.isHidden
    }
    
    @IBAction func upgrateButtonTapped(_ sender: Any) {
        guard let url = URL(string: upgrade.downloadUrl) else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
        if !upgrade.type.isHidden {
            dismiss(animated: true, completion: nil)
        }
    }
    
    
    @IBAction func closeButtonTapped(_ sender: Any) {
        
        dismiss(animated: true, completion: nil)
    }
    
}
