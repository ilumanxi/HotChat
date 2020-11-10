//
//  Dynamic.swift
//  HotChat
//
//  Created by 风起兮 on 2020/10/10.
//  Copyright © 2020 风起兮. All rights reserved.
//

import UIKit
import HandyJSON

struct Pagination<T: HandyJSON>: HandyJSON {

    var hasNext: Bool = false
    var page: Int = 0
    var list: [T]?
    
    /// 操作类型  0全新  1向下加载更多  2向上加载更多
    var handleType: Int = 1
}


class Dynamic: NSObject, HandyJSON {
    
    var dynamicId: String = ""
    var timeFormat: String = ""
    var content: String = ""
    var photoList: [RemoteFile] = []
    var isSelfZan: Bool = false
    var zanNum: Int = 0
    var giftNum: Int = 0
    var type: Int = 0
    var coverUrl: String = ""
    var userInfo: User!
    var commentCount: Int = 0
    var commentList: [[String: Any]]?
    
    required override init() {
        super.init()
    }
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
