//
//  CommentsViewController.swift
//  Comments
//
//  Created by 风起兮 on 2021/3/2.
//

import UIKit
import PanModal

    
class CommentsViewController: UIViewController {
    
    
    @IBOutlet weak var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        registerItem()

    }
    
    private func registerItem() {
        let nib = UINib(nibName: "CommentViewCell", bundle: nil)
        tableView.register(nib, forHeaderFooterViewReuseIdentifier: "CommentViewCell")
        tableView.register(nib, forCellReuseIdentifier: "CommentViewCell")
    }
    
    
    @IBAction func inputAction(_ sender: Any) {
        
        let vc = InputViewController()
        present(vc, animated: true, completion: nil)
    }
    
}

extension CommentsViewController: UITableViewDataSource {
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        3
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommentViewCell", for: indexPath)
        
        if indexPath.row == 0 {
            cell.layoutMargins = .zero
            cell.separatorInset = UIEdgeInsets(top: 0, left: 48 + 15, bottom: 0, right: 0)
        }
        else {
            
            cell.layoutMargins = UIEdgeInsets(top: 0, left: 48 + 15, bottom: 0, right: 0)
            cell.separatorInset = UIEdgeInsets(top: 0, left: UIView.layoutFittingExpandedSize.width, bottom: 0, right: 0)
        }
        
        
        return cell
        
    }
    
    
}





extension CommentsViewController: PanModalPresentable {
    
    var panScrollable: UIScrollView? {
        return nil
    }
    
    var longFormHeight: PanModalHeight {
        
        if traitCollection.verticalSizeClass == .compact {
            
        }
        
        let scale: CGFloat = 407.0 / 667.0
        
        return .contentHeight(UIScreen.main.bounds.height * scale)
    }
    
    var panModalBackgroundColor: UIColor {
        return UIColor.black.withAlphaComponent(0.5)
    }
    
    var showDragIndicator: Bool {
        return false
    }
    
    
}
