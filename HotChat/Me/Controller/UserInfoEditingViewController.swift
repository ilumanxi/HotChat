//
//  UserInfoEditingViewController.swift
//  HotChat
//
//  Created by 风起兮 on 2020/8/31.
//  Copyright © 2020 风起兮. All rights reserved.
//

import UIKit
import Photos
import Kingfisher


class UserInfoEditingViewController: UITableViewController {
    

    private lazy var profilePhoto: ProfilePhoto =  {
        let entry = ProfilePhoto()
        entry.onPresenting.delegate(on: self) { (self, _) in
             return self
        }
        entry.onImageUpdated.delegate(on: self) { (self, _) in
            self.tableView.reloadData()
        }
        return entry
    }()
    
    private lazy var photoAlbum: PhotoAlbum =  {
        let entry = PhotoAlbum(photoURLs: [], maximumSelectCount: 5)
        entry.onPresenting.delegate(on: self) { (self, _) in
             return self
        }
        entry.onImageUpdated.delegate(on: self) { (self, _) in
            self.tableView.reloadData()
        }
        return entry
    }()
    
    private lazy var basicInformation: BasicInformation = {
        
        let string = "1995/08/24"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd"
        let date = dateFormatter.date(from: string)!
        
        let entry = BasicInformation(
            name: "风起兮",
            sex: .man,
            dateOfBirth: date,
            follow: 6,
            isCertification: true,
            ID: "99999")
        
        return entry
    }()
    
    private lazy var likeObject: TagContent = {
        let entry = TagContent(imageName: "me-like-object", tags: ["女神范", "小可爱", "声音甜"], placeholder: nil)
        return entry
    }()
    
    private lazy var introduce: Introduce =  {
        let entry = Introduce(title: "介绍", content: nil, placeholder: "此用户很懒，什么都没有写")
        return entry
    }()
    
    private lazy var industry: Introduce =  {
        let entry = Introduce(title: "行业", content: "IT", placeholder: "此用户很懒，什么都没有写")
        return entry
    }()
    
    private lazy var hobbys: [TagContent] = {
        return Hobby.allCases.map { hobby -> TagContent in
            let imageName = "me-\(hobby.rawValue)"
            let placeholder = "添加你喜欢的\(hobby.description)吧～"
            return TagContent(imageName: imageName, tags: [], placeholder: placeholder)
        }
    }()
    
    private lazy var sections: [FormSection] = [
        FormSection(entries: [profilePhoto], headerText: "头像"),
        FormSection(entries: [photoAlbum], headerText: "相册"),
        FormSection(entries: [basicInformation], headerText: "基础信息"),
        FormSection(entries: [likeObject], headerText: "喜欢的女生"),
        FormSection(entries: [introduce, industry], headerText: "我的信息"),
        FormSection(entries: [AddContent()], headerText: "小编专访"),
        FormSection(entries: hobbys, headerText: "我的爱好")
    ]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }
    
    private func setupUI() {
        
        tableView.register(UserInfoEditingHeaderView.self, forHeaderFooterViewReuseIdentifier: "UserInfoEditingHeaderView")
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].formEntries.count
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return sections[section].renderer.headerView(tableView, section: section)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return sections[indexPath.section].formEntries[indexPath.row].cell(tableView, indexPath: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
 
}


