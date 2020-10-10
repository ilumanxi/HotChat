//
//  TextInputViewCell.swift
//  HotChat
//
//  Created by 风起兮 on 2020/10/10.
//  Copyright © 2020 风起兮. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class TextInputViewCell: UITableViewCell {
    
    let onTextUpdated = Delegate<String?, Void>()
    
    @IBOutlet weak var textView: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        textView.rx.text
            .skip(1)
            .subscribe(onNext: { [weak self] text in
                self?.onTextUpdated.call(text)
            })
            .disposed(by: rx.disposeBag)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
