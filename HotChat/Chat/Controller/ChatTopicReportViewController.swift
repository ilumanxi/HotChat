//
//  ChatTopicReportViewController.swift
//  HotChat
//
//  Created by 风起兮 on 2021/3/19.
//  Copyright © 2021 风起兮. All rights reserved.
//

import UIKit

class ReportContentCell: UITableViewCell {
    
    var indicatorView: UIView
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        self.indicatorView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 12))
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        textLabel?.font = .systemFont(ofSize: 14)
        selectionStyle = .none
        isSelected = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var isSelected: Bool {
        didSet {
            
            indicatorView.layer.cornerRadius = indicatorView.bounds.height / 2
            if isSelected {
                
                indicatorView.layer.borderWidth = 0
                indicatorView.layer.borderColor = nil
                indicatorView.backgroundColor = UIColor(hexString: "#FF423E")
            }
            else {
                indicatorView.layer.borderWidth = 0.5
                indicatorView.layer.borderColor = UIColor(hexString: "#C3C3C3").cgColor
                indicatorView.backgroundColor = .clear
            }
            accessoryView = indicatorView
        }
    }
}

class ChatTopicReportViewController: UIViewController, IndicatorDisplay {
    
    
    let reports = [
        "可疑诈骗信息",
        "恶意骚扰",
        "色情（文字聊）",
        "性别不符",
        "广告/垃圾信息",
        "发布政治/违法/恐怖内容"
    ]
    
    
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var tableView: UITableView!
    
    init() {
        super.init(nibName: nil, bundle: nil)
        modalTransitionStyle = .crossDissolve
        modalPresentationStyle = .overFullScreen
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    var indexPathForSelectedRow: IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.backgroundColor = .white
        tableView.rowHeight = 38
        tableView.register(ReportContentCell.self, forCellReuseIdentifier: "ReportContentCell")

        // Do any additional setup after loading the view.
    }


    @IBAction func closeButtonTapped(_ sender: Any) {
        
        dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func submitButtonTapped(_ sender: Any) {
        
        guard let _ = indexPathForSelectedRow else {
            showMessageOnWindow("请选择一项")
            return
        }
        
        showMessageOnWindow("举报提交成功")
        dismiss(animated: true, completion: nil)
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if touches.first?.view == self.view {
            dismiss(animated: true, completion: nil)
        }
    }
}

extension ChatTopicReportViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        indexPathForSelectedRow = indexPath
        tableView.reloadData()
        
    }
}

extension ChatTopicReportViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reports.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(for: indexPath, cellType: ReportContentCell.self)
        cell.textLabel?.text = reports[indexPath.row]
        cell.isSelected = indexPathForSelectedRow == indexPath
        return cell
    }
    
}
