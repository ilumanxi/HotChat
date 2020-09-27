//
//  LabelViewController.swift
//  HotChat
//
//  Created by 谭帆帆 on 2020/9/26.
//  Copyright © 2020 风起兮. All rights reserved.
//

import UIKit


class LabelViewController: UITableViewController, Wireframe {
    
    var labels: [LikeTag] = [] {
        didSet {
            refreshUI()
        }
    }
    
    var maximumCount = 1
    
    let onSaved = Delegate<[LikeTag], Void>()
    

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.rowHeight = 50
        tableView.register(cellType: LabelViewCell.self)
        
        refreshUI()
    }
    
    func refreshUI() {
        
        if labels.isEmpty {
            navigationItem.rightBarButtonItems = nil
        }
        else {
            
            let saveItem = UIBarButtonItem(title: "保存", style: .plain, target: self, action: #selector(saveAction))
            navigationItem.rightBarButtonItems = [saveItem]
        }
        
        tableView.reloadData()
    }
    
    
    @objc func saveAction() {
        
        let selectedLabels = labels.filter{ $0.isCheck }
        
        onSaved.call(selectedLabels)
    }

    // MARK: - Table view data source


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return labels.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let label = labels[indexPath.row]
        
        let isCheck = label.isCheck
        
        let cell = tableView.dequeueReusableCell(for: indexPath, cellType: LabelViewCell.self)
        cell.titleLabel.text = label.label
        cell.titleLabel.isHighlighted = isCheck
        cell.iconView.isHighlighted = isCheck
        
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let isCheck = !labels[indexPath.row].isCheck
        
        if maximumCount == 1 {
            labels.modifyForEach { $1.isCheck = false }
            labels.modifyElement(at: indexPath.row) { $0.isCheck  = isCheck }
        }
        else {
            
            labels.modifyElement(at: indexPath.row) { $0.isCheck  = isCheck }
            
            let selectedLabels =  labels.filter{ $0.isCheck }
            
            if  selectedLabels.count > maximumCount {
                labels.modifyElement(at: indexPath.row) { $0.isCheck  = false }
                show("最多选择\(maximumCount)项")
            }
        }
        
        tableView.reloadData()
    }
}
