//
//  NewcomerAwardViewController.swift
//  HotChat
//
//  Created by 风起兮 on 2021/3/29.
//  Copyright © 2021 风起兮. All rights reserved.
//

import UIKit

class NewcomerAwardViewController: UIViewController {
    
    
    @IBOutlet weak var awardButton1: UIButton!
    
    @IBOutlet weak var awardButton2: UIButton!
    
    @IBOutlet weak var awardButton3: UIButton!
    
    @IBOutlet weak var awardButton4: UIButton!
    
    
    let list: [String]
    init(list: [String]) {
        self.list = list
        super.init(nibName: nil, bundle: nil)
        super.modalTransitionStyle = .crossDissolve
        super.modalPresentationStyle = .overFullScreen
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let buttons = [awardButton1, awardButton2, awardButton3, awardButton4]
        
        buttons.forEach {
            $0?.alpha = 0
        }
        
        let data = list[0..<4]
        for index in 0..<data.count {
            let button = buttons[index]
            button?.setTitle(list[index], for: .normal)
            button?.alpha = 1
        }
        
    }

    
    
    @IBAction func doneButtonTapped(_ sender: Any) {
        
        dismiss(animated: true, completion: nil)
    }
    

    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if touches.first?.view == self.view {
            dismiss(animated: true, completion: nil)
        }
    }
}
