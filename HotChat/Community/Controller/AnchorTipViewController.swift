//
//  AnchorTipViewController.swift
//  HotChat
//
//  Created by 风起兮 on 2021/3/29.
//  Copyright © 2021 风起兮. All rights reserved.
//

import UIKit

class AnchorTipViewController: UIViewController {
    
    
    @IBOutlet weak var selectedButton: UIButton!
    
    let onAnthor = Delegate<Void,Void>()
    
    
    private static let cacheKey = "AnchorTipViewController.remind"
    
    static func notRemind() -> Bool {
        return UserDefaults.standard.bool(forKey: cacheKey)
    }
    
    static func cacheRemind(_ remind: Bool)  {
        UserDefaults.standard.set(remind, forKey: cacheKey)
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
        super.modalPresentationStyle = .overFullScreen
        super.modalTransitionStyle = .crossDissolve
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if touches.first?.view == self.view {
            dismiss(animated: true, completion: nil)
        }
    }

    
    @IBAction func closeButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneButton(_ sender: Any) {
        
        self.onAnthor.call()
        dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func tipButtonTapped(_ sender: Any) {
        
        selectedButton.isSelected = !selectedButton.isSelected
        
        Self.cacheRemind(selectedButton.isSelected)
    }
}
