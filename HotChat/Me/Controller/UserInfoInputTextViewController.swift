//
//  UserInfoInputTextViewController.swift
//  HotChat
//
//  Created by 风起兮 on 2020/9/2.
//  Copyright © 2020 风起兮. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class UserInfoInputTextViewController: UITableViewController, Wireframe {
    
    var content: (title: String, topic: String?, text: String?)!
    
    
    @IBOutlet weak var topicLabel: UILabel!
    
    
    @IBOutlet weak var textView: UITextView!
    
    
    @IBOutlet weak var inputTextCountLabel: UILabel!
    
    var maximumTextCount = 100
    
    let onSaved = Delegate<String, Void>()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        bindSignal()
        
        setupUI()
        
    }
    
    
    static func loadFromStoryboard() -> Self {
        
        let storyboard = UIStoryboard(name: "Me", bundle: nil)
        
        let identifier = String(describing: Self.self)
        
        return  storyboard.instantiateViewController(withIdentifier: identifier) as! Self
        
    }
    
    
    func bindSignal() {
        let textSignal = textView.rx.text.orEmpty.asDriver()
        
        textSignal
            .filter {[unowned self] in
                $0.length > self.maximumTextCount
            }
            .map { [unowned self] in
                ($0 as NSString).substring(to: self.maximumTextCount)
            }
            .drive(textView.rx.text)
            .disposed(by: rx.disposeBag)
        
        textSignal
            .map{ [unowned self] in
                "\($0.length)/\(self.maximumTextCount)"
            }
            .drive(inputTextCountLabel.rx.text)
            .disposed(by: rx.disposeBag)
    }

    func setupUI()  {
        title = content.title
        topicLabel.text = content.topic
        textView.text = content.text
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.row == 0 && content.topic == .none {
            return 0
        }
        
        return super.tableView(tableView, heightForRowAt: indexPath)
    }
    
    @IBAction func doneAction(_ sender: Any) {
        onSaved.call(textView.text ?? "")
    }
    
}

