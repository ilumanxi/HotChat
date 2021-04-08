//
//  PickerViewController.swift
//  HotChat
//
//  Created by 风起兮 on 2021/4/8.
//  Copyright © 2021 风起兮. All rights reserved.
//

import UIKit

class PickerViewController: UIViewController {
    
    
    @IBOutlet weak var pickerView: UIPickerView!
    
    
    let onPickered = Delegate<String, Void>()
    
    let conents: [String]
    private(set) var selectRow: Int
    
    init(conents: [String], selectRow: Int = 0) {
        self.conents = conents
        self.selectRow = selectRow
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
        
        pickerView.selectRow(selectRow, inComponent: 0, animated: true)
    }


    
    @IBAction func cancelItemTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
    
    @IBAction func doneItemTapped(_ sender: Any) {
        
        dismiss(animated: true) {
            self.onPickered.call(self.conents[self.selectRow])
        }
    }
}


extension PickerViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        
        return 1
    }
    
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        return conents.count
    }
    
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectRow = row
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        
        
        return NSAttributedString(string: conents[row])
    }
    
}
