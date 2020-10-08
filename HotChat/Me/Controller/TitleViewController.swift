//
//  TitleViewController.swift
//  HotChat
//
//  Created by 风起兮 on 2020/9/27.
//  Copyright © 2020 风起兮. All rights reserved.
//

import UIKit

class TitleViewController: UITableViewController, IndicatorDisplay {
    
    
    let onSaved = Delegate<Topic, Void>()
    
    
    var tips: [Topic] = [] {
        didSet {
            refreshUI()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(cellType: TitleViewCell.self)
        
        refreshUI()

    }
    
    
    func refreshUI() {
        
        tableView.reloadData()
    }

    // MARK: - Table view data source


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return tips.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let tip = tips[indexPath.row]
        
        
        let cell = tableView.dequeueReusableCell(for: indexPath, cellType: TitleViewCell.self)

        cell.textLabel?.text = tip.label
        return cell
    }
    

    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        var tip = tips[indexPath.row]
        
        let vc = UserInfoInputTextViewController.loadFromStoryboard()
        vc.content = ("您的回答", tip.label, tip.content)
        vc.onSaved.delegate(on: self) { (self, text) in
            tip.content = text
            self.onSaved.call(tip)
        }
        
        navigationController?.pushViewController(vc, animated: true)
    }
   
}
