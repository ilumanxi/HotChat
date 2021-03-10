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
    var count: Int = 0
    
    /// 操作类型  0全新  1向下加载更多  2向上加载更多
    var handleType: Int = 1
}

enum DynamicType: Int, HandyJSONEnum {
    case image = 1
    case video = 2
}

extension DynamicType {
    var image: UIImage? {
        switch self {
        case .image:
            return UIImage(named: "dynamic-type-image")
        case .video:
            return UIImage(named: "dynamic-type-video")
        }
    }
}

class DynamicVideo: NSObject, HandyJSON {
    
    var coverUrl: String = ""
    var url: String = ""
    
    var width: CGFloat = 0
    var height: CGFloat = 0
    
    var size: CGSize {
        return CGSize(width: width, height: height)
    }
    
    required override init() {
        super.init()
    }
}

extension Dynamic: PlayerItem {
    
    var url: String {
        video?.url ?? ""
    }
    
    var uid: String {
        return dynamicId
    }
    
    
}

class Dynamic: NSObject, HandyJSON {
    
    var dynamicId: String = ""
    var timeFormat: String = ""
    var content: String = ""
    var photoList: [RemoteFile] = []
    var video: DynamicVideo?
    var type: DynamicType = .image
    var isSelfZan: Bool = false
    var zanNum: Int = 0
    var giftNum: Int = 0
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
