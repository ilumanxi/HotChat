//
//  CommentFooterView.swift
//  HotChat
//
//  Created by 风起兮 on 2021/3/5.
//  Copyright © 2021 风起兮. All rights reserved.
//

import UIKit

class CommentFooterView: UITableViewHeaderFooterView {

    var section: Int!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var disclosureButton: UIButton!
    
    let onTapped = Delegate<Int, Void>()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let tapGesture  = UITapGestureRecognizer(target: self, action: #selector(toggleOpen(sender:)))
        addGestureRecognizer(tapGesture)
    }
    
    @objc func toggleOpen(sender: UITapGestureRecognizer) {
        onTapped.call(section)
        
    }
}
