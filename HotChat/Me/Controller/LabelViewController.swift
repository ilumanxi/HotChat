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
            tableView.reloadData()
        }
    }
    
    var maximumCount = 1

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(cellType: UITableViewCell.self)
    }

    // MARK: - Table view data source


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return labels.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let label = labels[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(for: indexPath, cellType: UITableViewCell.self)
        cell.textLabel?.text = label.label
        let image = label.isCheck ? UIImage(named: "") : UIImage(named: "")
        let imageView = UIImageView(image: image)
        cell.accessoryView = imageView
        
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
