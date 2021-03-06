//
//  FormSection.swift
//  HotChat
//
//  Created by 风起兮 on 2020/9/4.
//  Copyright © 2020 风起兮. All rights reserved.
//

import UIKit

class FormSection {
    
    var formEntries: [FormEntry]
    let headerText: String?
    let footerText: String?
    
    var renderer: FormSectionRenderer!
    
    init(entries: [FormEntry], headerText: String? = nil,  footerText: String? = nil) {
        self.formEntries = entries
        self.headerText = headerText
        self.footerText = footerText
        self.renderer = FormSectionRenderer(section: self)
    }
}

class FormSectionRenderer {
    
    weak var section: FormSection?
    
    
    init(section: FormSection) {
        self.section = section
    }
    
    func headerView(_ tableView: UITableView, section: Int) -> UIView {
        let header = tableView.dequeueReusableHeaderFooterView(UserInfoEditingHeaderView.self)!
        
        render(header)
        
        return header
    }
    
    private func render(_ header: UserInfoEditingHeaderView) {
        
        header.titleLabel.text = section?.headerText
    }
}

