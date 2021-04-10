//
//  TipAlertController.swift
//  HotChat
//
//  Created by 风起兮 on 2021/4/10.
//  Copyright © 2021 风起兮. All rights reserved.
//

import UIKit

class TipAlertController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var messageLabel: UILabel!
    
    
    @IBOutlet weak var leftButton: UIButton!
    
    
    @IBOutlet weak var rightButton: GradientButton!
    
    let header: String
    let message: String
    let leftButtonTitle: String
    let rightButtonTitle: String
    
    let onLeftDidClick = Delegate<Void, Void>()
    let onRightDidClick = Delegate<Void, Void>()
    
    init(title: String, message: String, leftButtonTitle: String, rightButtonTitle: String) {
        self.header = title
        self.message = message
        self.leftButtonTitle = leftButtonTitle
        self.rightButtonTitle = rightButtonTitle
        super.init(nibName: nil, bundle: nil)
        super.modalTransitionStyle = .crossDissolve
        super.modalPresentationStyle = .overFullScreen
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupUI()
    }
    
    func setupUI() {
        titleLabel.text = header
        messageLabel.text = message
        leftButton.setTitle(leftButtonTitle, for: .normal)
        rightButton.setTitle(rightButtonTitle, for: .normal)
    }


    @IBAction func leftButtonTapped(_ sender: Any) {
        dismiss(animated: true) { [weak self] in
            self?.onLeftDidClick.call()
        }
    }
    
    
    @IBAction func rightButtonTapped(_ sender: Any) {
        dismiss(animated: true) { [weak self] in
            self?.onRightDidClick.call()
        }
    }
    
}
