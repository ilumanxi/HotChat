//
//  MessageAlertController.swift
//  HotChat
//
//  Created by 风起兮 on 2021/5/17.
//  Copyright © 2021 风起兮. All rights reserved.
//

import UIKit

class MessageAlertController: UIViewController {

    
    @IBOutlet weak var messageLabel: UILabel!
    
    
    @IBOutlet weak var leftButton: UIButton!
    
    
    @IBOutlet weak var rightButton: GradientButton!
    

    let message: String
    let leftButtonTitle: String
    let rightButtonTitle: String
    
    let onLeftDidClick = Delegate<Void, Void>()
    
    let onRightDidClick = Delegate<Void, Void>()
    
    @objc
    var onRightClick: (() -> Void)?
    
    @objc
    init(message: String, leftButtonTitle: String, rightButtonTitle: String) {
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
        messageLabel.text = message
        leftButton.setTitle(leftButtonTitle, for: .normal)
        leftButton.isHidden = leftButtonTitle.isEmpty
        rightButton.setTitle(rightButtonTitle,  for: .normal)
        rightButton.isHidden = rightButtonTitle.isEmpty
    }


    @IBAction func leftButtonTapped(_ sender: Any) {
        dismiss(animated: true) { [weak self] in
            self?.onLeftDidClick.call()
        }
    }
    
    
    @IBAction func rightButtonTapped(_ sender: Any) {
        dismiss(animated: true) { [weak self] in
            self?.onRightDidClick.call()
            self?.onRightClick?()
        }
    }
    

}
