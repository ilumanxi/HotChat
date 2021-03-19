//
//  ChatTopicMenuViewController.swift
//  HotChat
//
//  Created by 风起兮 on 2021/3/19.
//  Copyright © 2021 风起兮. All rights reserved.
//

import UIKit

class MenuCell: UITableViewCell {
    
    let titleLabel: UILabel
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        self.titleLabel = UILabel()
        self.titleLabel.font = .systemFont(ofSize: 15, weight: .medium)
        self.titleLabel.textColor = UIColor(hexString: "#333333")
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        super.separatorInset = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        setupViews()
        
    }
    
    func setupViews()  {
        
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { maker in
            maker.center.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class ChatTopicMenuViewController: UITableViewController {
    
    var menus: [String]
    
    let ondSelected = Delegate<Int, Void>()
    
    
    let cellSize = CGSize(width: 72, height: 32)
    
    init(menus: [String]) {
        self.menus = menus
        super.init(style: .plain)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.bounces = false
        tableView.rowHeight = cellSize.height
        tableView.register(MenuCell.self, forCellReuseIdentifier: "MenuCell")

        preferredContentSize = CGSize(width: cellSize.width, height: cellSize.height * CGFloat(menus.count))
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return menus.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(for: indexPath, cellType: MenuCell.self)
        cell.titleLabel.text = menus[indexPath.row]
        
        return cell
    }
    
    
    // MARK: - Table view deletage
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        defer {
            tableView.deselectRow(at: indexPath, animated: true)
        }
       
        dismiss(animated: true) { [weak self] in
            self?.ondSelected.call(indexPath.row)
        }
    }
   

}
