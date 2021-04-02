//
//  InformationViewController.swift
//  HotChat
//
//  Created by 风起兮 on 2020/10/9.
//  Copyright © 2020 风起兮. All rights reserved.
//

import UIKit
import Aquaman

extension Sex {
    
    var headerText: String {
        
        switch self {
        case .female:
            return "类型"
        default:
            return "喜欢的类型"
        }
    }
    
}

class InformationViewController: UITableViewController, AquamanChildViewController, StoryboardCreate {
    
    
    var user: User! {
        didSet {
            refreshData()
        }
    }
    
    static var storyboardNamed: String { return "Me" }
    
    func aquamanChildScrollView() -> UIScrollView {
        return tableView
    }
    
    private var information: Information {
        
        let entry = Information(user: user)
        
        return entry
    }
    
    private var likeObject: TagContent {
        
        let tags = user.labelList.compactMap { $0.label }
        let entry = TagContent(imageName: "me-like-object", tags: tags, placeholder: nil)
        return entry
    }
    

    
    private var tips: [InfoInterview] {
        return  user.tipsList.compactMap{ InfoInterview(topic: $0) }
    }
    
    
    private var hobbyLabel: [[LikeTag]] {
        let lables = [
            user.motionList,
            user.foodList,
            user.musicList,
            user.bookList,
            user.travelList,
            user.movieList
        ]
        
        return lables
    }
    
    private var hobbys: [TagContent]  {
        let count = Hobby.allCases.count
        return (0..<count).compactMap { i -> TagContent? in
            let tags = hobbyLabel[i].map{ $0.label }
            if tags.isEmpty {
                return nil
            }
            let placeholder = "添加你喜欢的\(Hobby.allCases[i].description)吧～"
            return TagContent(imageName: Hobby.allCases[i].imageName, tags: tags, placeholder: placeholder)
        }
    }
    
    private var sections: [FormSection] = []
    
    
    lazy var userDataView: UserDataView = {
        let view = UserDataView.loadFromNib()
        view.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 290)
        return view
    }()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableHeaderView = userDataView
        
        refreshData()
        tableView.allowsSelection = false
        tableView.register(UserInfoEditingHeaderView.self, forHeaderFooterViewReuseIdentifier: "UserInfoEditingHeaderView")
    }
    
    func refreshData() {
        
        sections = []
        
        if let _ = user {
            
            
            var sections: [FormSection] = [
                FormSection(entries: [information], headerText: "ta的信息")
            ]
            
            if !user.labelList.isEmpty {
                sections.append(FormSection(entries: [likeObject], headerText: user.sex.headerText))
            }
            
            if !user.tipsList.isEmpty {
                sections.append(FormSection(entries: tips , headerText: "小编专访"))
            }
            
            if !hobbys.isEmpty {
                sections.append(FormSection(entries: hobbys, headerText: "ta的爱好"))
            }
            
            self.sections = sections
        }
       
        tableView.reloadData()
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
