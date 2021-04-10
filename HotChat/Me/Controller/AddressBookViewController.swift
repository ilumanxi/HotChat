//
//  AddressBookViewController.swift
//  HotChat
//
//  Created by 风起兮 on 2021/4/9.
//  Copyright © 2021 风起兮. All rights reserved.
//

import UIKit
import Aquaman

class AddressBookViewController: UIViewController, AquamanChildViewController {
    
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    func aquamanChildScrollView() -> UIScrollView {
        return scrollView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
