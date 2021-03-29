//
//  AvatarTipViewController.swift
//  HotChat
//
//  Created by 风起兮 on 2021/3/29.
//  Copyright © 2021 风起兮. All rights reserved.
//

import UIKit

class AvatarTipViewController: UIViewController {
    
    let onAvatar = Delegate<Void, Void>()
    
    private static let cacheKey = "AvatarTipViewController.isPresent"
    
    static func isPresent() -> Bool {
        
        guard let date = UserDefaults.standard.object(forKey: cacheKey) as? Date else {
            return true
        }
        
       
        if  date.isToday {
            return false
        }
        
        if date < Date() {
            return true
        }
        
        return false
    }
    
    
    static func cachePresent() {
        UserDefaults.standard.set(Date(), forKey: cacheKey)
    }
    
    
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
        
        infoLabel.text = "完成修改，额外奖励\(text)"

        // Do any additional setup after loading the view.
    }


    @IBAction func avatarButtonTapped(_ sender: Any) {
        dismiss(animated: true) { [weak self] in
            self?.onAvatar.call()
        }
    }
    
    
    @IBAction func closeButtonTapeed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if touches.first?.view == self.view {
            dismiss(animated: true, completion: nil)
        }
    }

}
