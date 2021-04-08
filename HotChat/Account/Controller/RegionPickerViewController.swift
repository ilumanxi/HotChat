//
//  RegionPickerViewController.swift
//  HotChat
//
//  Created by 风起兮 on 2021/4/8.
//  Copyright © 2021 风起兮. All rights reserved.
//

import UIKit

class RegionPickerViewController: UIViewController {
    
    
    @IBOutlet weak var pickerView: UIPickerView!
    
    fileprivate var provinceIndex: Int = 0
    fileprivate var cityIndex: Int = 0
    
    private var data: [Region] = []
    
    let onPickered = Delegate<(Region, Region), Void>()
    
    init() {
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
        
        Region.requestData {
            self.data = Region.data
            self.pickerView.reloadAllComponents()
        }
        
        data = Region.data
    }


    
    @IBAction func cancelItemTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
    
    @IBAction func doneItemTapped(_ sender: Any) {
        dismiss(animated: true) {
            self.onPickered.call((self.data[self.provinceIndex], self.data[self.provinceIndex].list[self.cityIndex]))
        }
    }
    
}


extension RegionPickerViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        
        return data.isEmpty ? 0 : 2
    }
    
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        if  component == 0 {
            return data.count
        }
        
        return data[provinceIndex].list.count
    }
    
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if component == 0 {
            provinceIndex = row
            cityIndex = 0
            pickerView.reloadComponent(1)
        }
        else {
            cityIndex = row
        }
        
        pickerView.selectRow(provinceIndex, inComponent: 0, animated: true)
        pickerView.selectRow(cityIndex, inComponent:1, animated: true)
    }
    
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        
        
        if component == 0 {
            
            return NSAttributedString(string: data[row].label)
        }
        
        return NSAttributedString(string: data[provinceIndex].list[row].label)
    }
    
}
