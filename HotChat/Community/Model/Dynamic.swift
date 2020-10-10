//
//  Dynamic.swift
//  HotChat
//
//  Created by 风起兮 on 2020/10/10.
//  Copyright © 2020 风起兮. All rights reserved.
//

import UIKit
import HandyJSON


struct Dynamic: HandyJSON {
    var dynamicId: String = ""
    var content: String = ""
    var isSelfZan: Bool = false
    var zanNum: Int = 0
    var type: Int = 0
    var coverUrl: String = ""
    var userInfo: User!
}


class TextIput: FormEntry {
    
    let text: String?
    
    let onTextUpdated = Delegate<String?, Void>()
    
    
    init(text: String?) {
        self.text = text
    }
    
    func cell(_ tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(for: indexPath, cellType: TextInputViewCell.self)
        render(cell)
        return cell
    }
    
    private func render(_ cell: TextInputViewCell) {

        cell.textView.text = text
        
        cell.onTextUpdated.delegate(on: self) { (self, text) in
            self.onTextUpdated.call(text)
        }
    }
    
}
