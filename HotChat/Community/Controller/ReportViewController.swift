//
//  ReportViewController.swift
//  HotChat
//
//  Created by 风起兮 on 2020/10/14.
//  Copyright © 2020 风起兮. All rights reserved.
//

import UIKit
import Reusable




class ReportViewController: UIViewController, IndicatorDisplay, StoryboardCreate {
    
    
    static var storyboardNamed: String {
        return "Community"
    }
    
    var user: User!
    
    
    private var selectedIndexPath: IndexPath?
    
    @IBOutlet weak var tableView: UITableView!
    
    lazy var contents: [String] = {
        return [
            "广告/营销",
            "低俗/色情",
            "涉政/谩骂",
            "盗用他人图像"
        ]
    }()
    
    
    let reportAPI = Request<ReportAPI>()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
    }
    
    
    @IBAction func closeButtonTapped(_ sender: Any) {
        dismiss(animated: false, completion: nil)
    }
    
    
    @IBAction func submitButtonTapped(_ sender: Any) {
        
        guard let indexPath = selectedIndexPath else {
            show("请选择举报内容")
            return
            
        }
        let parameters : [String : Any] = [
            "reportUserId" : user.userId,
            "content" : contents[indexPath.row]
        ]
        
        self.showIndicatorOnWindow()
        
        reportAPI.request(.userReport(parameters), type: ResponseEmpty.self)
            .checkResponse()
            .subscribe(onSuccess: { [weak self] reponse in
                self?.hideIndicatorFromWindow()
                self?.showMessageOnWindow(reponse.msg)
                self?.dismiss(animated: false, completion: nil)
            }, onError: { [weak self] error in
                self?.hideIndicatorFromWindow()
                self?.showMessageOnWindow(error.localizedDescription)
                
            })
            .disposed(by: rx.disposeBag)
    }
    

}


extension ReportViewController: UITableViewDataSource, UITableViewDelegate {
    
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
