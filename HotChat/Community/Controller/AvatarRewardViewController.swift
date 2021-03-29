//
//  AvatarRewardViewController.swift
//  HotChat
//
//  Created by 风起兮 on 2021/3/29.
//  Copyright © 2021 风起兮. All rights reserved.
//

import UIKit

class AvatarRewardViewController: UIViewController {
    

    @IBOutlet weak var infoLabel: UILabel!
    
    let text: String
    init(text: String) {
        self.text = text
        super.init(nibName: nil, bundle: nil)
        super.modalTransitionStyle = .crossDissolve
        super.modalPresentationStyle = .overFullScreen
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let string = NSMutableAttributedString()
        string.append(NSAttributedString(string: "感谢您的理解配合，那么请收下"))
        string.append(NSAttributedString(string: text, attributes: [NSAttributedString.Key.foregroundColor : UIColor(hexString: "#F75852")]))
        string.append(NSAttributedString(string: "的奖励"))
        
        infoLabel.attributedText = string

        // Do any additional setup after loading the view.
    }

    @IBAction func doneButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func closeButtonTapped(_ sender: Any) {
        
        dismiss(animated: true, completion: nil)
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if touches.first?.view == self.view {
            dismiss(animated: true, completion: nil)
        }
    }
}
