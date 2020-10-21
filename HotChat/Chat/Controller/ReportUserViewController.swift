//
//  ReportUserViewController.swift
//  HotChat
//
//  Created by 风起兮 on 2020/10/21.
//  Copyright © 2020 风起兮. All rights reserved.
//

import UIKit

class ReportUserViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, StoryboardCreate, IndicatorDisplay {
    
    
    static var storyboardNamed: String { return "Chat" }
    

    var user: User!
    
    private var selectedIndexPath: IndexPath?
    
    let reports: [String] = [
        "恶意骚扰",
        "色情(文字聊)",
        "色情(视频聊/语音聊)",
        "广告/垃圾信息",
        "可疑诈骗信息",
        "发布政治/违法/恐怖内容"
    ]
    
    @IBOutlet weak var tableView: UITableView!
    
    let reportAPI = Request<ReportAPI>()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = 50

        // Do any additional setup after loading the view.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return reports.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell  = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = reports[indexPath.row]
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
    
    @IBAction func reportButtonTapped(_ sender: Any) {
        
        guard let indexPath = selectedIndexPath else {
            show("请选择举报内容")
            return
            
        }
        let parameters : [String : Any] = [
            "reportUserId" : user.userId,
            "content" : reports[indexPath.row]
        ]
        
        self.showIndicatorOnWindow()
        
        reportAPI.request(.userReport(parameters), type: ResponseEmpty.self)
            .checkResponse()
            .subscribe(onSuccess: { [weak self] reponse in
                self?.hideIndicatorFromWindow()
                self?.showMessageOnWindow(reponse.msg)
                self?.navigationController?.popViewController(animated: true)
            }, onError: { [weak self] error in
                self?.hideIndicatorFromWindow()
                self?.showMessageOnWindow(error.localizedDescription)
                
            })
            .disposed(by: rx.disposeBag)
    }
    
}
