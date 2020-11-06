//
//  PhoneBindingController.swift
//  HotChat
//
//  Created by 风起兮 on 2020/11/6.
//  Copyright © 2020 风起兮. All rights reserved.
//

import UIKit

class PhoneBindingController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    
    @IBOutlet weak var phoneTextField: UITextField!
    
    
    @IBOutlet weak var codeTextField: UITextField!
    
    @IBOutlet weak var codeButton: UIButton!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var passwordButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
    }
    
    func setupView() {
        title = "绑定手机"
        scrollView.contentInset = UIEdgeInsets(top: 50, left: 0, bottom: 0, right: 0)
    }
    
    @IBAction func submitButtonTapped(_ sender: Any) {
    }
    

}
