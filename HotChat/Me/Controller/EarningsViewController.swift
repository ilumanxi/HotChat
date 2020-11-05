//
//  EarningsViewController.swift
//  HotChat
//
//  Created by 风起兮 on 2020/11/5.
//  Copyright © 2020 风起兮. All rights reserved.
//

import UIKit

class EarningsViewController: UIViewController {
    
    
    @IBOutlet weak var segmentedContainerView: UIStackView!
    
    
    var selectedIndex: Int = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "我的收益"
        
        setSelectedIndex(0)
        
        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func segmentedButtonTapped(_ sender: UIButton) {
        
        let index = segmentedContainerView.subviews.firstIndex(of: sender)!
        setSelectedIndex(index)
    }
    
    
    func setSelectedIndex(_ index: Int) {
        
        selectedIndex = index
        
        for i in 0..<segmentedContainerView.subviews.count {
            let butnton = segmentedContainerView.subviews[i] as! UIButton
            let isSelected: Bool = (i == index)
            butnton.isSelected = isSelected
            butnton.backgroundColor = isSelected ? UIColor(hexString: "#5159F8") : UIColor(hexString: "#F6F5F5")
            
        }
        
    }
    


    @IBAction func pusGiftEarnings(_ sender: Any) {
        
        let vc = GiftEarningsViewController()
        navigationController?.pushViewController(vc, animated: true)
    }

    @IBAction func pusTalkEarnings(_ sender: Any) {
        
        let vc = TalkEarningsViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
}
