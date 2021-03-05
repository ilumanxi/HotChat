//
//  CommentReportViewController.swift
//  HotChat
//
//  Created by 风起兮 on 2021/3/5.
//  Copyright © 2021 风起兮. All rights reserved.
//

import UIKit

class CommentReportViewController: UIViewController, IndicatorDisplay {
    
    private var selectedIndexPath: IndexPath?
    
    @IBOutlet weak var tableView: UITableView!
    
    let onSubmit = Delegate<String, Void>()
    
    lazy var contents: [String] = {
        return [
            "庸俗",
            "涉黄",
            "涉政",
            "涉暴",
            "辱骂"
        ]
    }()
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.modalTransitionStyle = .crossDissolve
        self.modalPresentationStyle = .overFullScreen
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.register(UINib(nibName: "ReportCell", bundle: nil), forCellReuseIdentifier: "cell")
    }
    
    
    @IBAction func submit(_ sender: Any) {
        
        guard let indexPath = selectedIndexPath else {
            show("请选择举报类型")
            return
            
        }
        
        onSubmit.call(contents[indexPath.row])
        dismiss(animated: true, completion: nil)
    }
    

    
    @IBAction func close(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}


extension CommentReportViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contents.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell  = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = contents[indexPath.row]
        let image: UIImage?
        if indexPath == selectedIndexPath {
            image = UIImage(named: "box-selected")
        }
        else {
            image = UIImage(named: "box-unselected")
        }
        
        let imageView = UIImageView(image: image)
        cell.accessoryView = imageView
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        selectedIndexPath = indexPath
        tableView.reloadData()
    }
    
}
