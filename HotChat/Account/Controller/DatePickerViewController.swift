//
//  DatePickerViewController.swift
//  HotChat
//
//  Created by 风起兮 on 2020/9/24.
//  Copyright © 2020 风起兮. All rights reserved.
//

import UIKit

class DatePickerViewController: UIViewController {
    
    
    let onDateUpdated = Delegate<Date, Void>()
    
    
    var date = Date()
    
    @IBOutlet weak var datePicker: UIDatePicker!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        datePicker.maximumDate = Date()
        datePicker.date = date
    }
    
    
    @IBAction func datePiackerValueChanged(_ sender: UIDatePicker) {
        date = sender.date
    }
    
    
    @IBAction func cancelAction(_ sender: Any) {
        dismiss(animated: false, completion: nil)
    }
    
    @IBAction func doneAction(_ sender: Any) {
        
        onDateUpdated.call(date)
        dismiss(animated: false, completion: nil)
    }
    
    
}
