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
import RxSwift
import RxCocoa
import MBProgressHUD


class UserInfoEditingViewController: UITableViewController, Wireframe {
    
    
    let userAPI = RequestAPI<UserAPI>()
    
    private var profilePhoto: ProfilePhoto {
        let entry = ProfilePhoto()
        entry.imageURL = URL(string: user.headPic)
        entry.onPresenting.delegate(on: self) { (self, _) in
             return self
        }
        entry.onImageUpdated.delegate(on: self) { (self, _) in
            self.tableView.reloadData()
        }
        
        return entry
    }
    
    private var photoAlbum: PhotoAlbum {
        let photoURLs = user.photoList.compactMap{ URL(string: $0.picUrl)}
        let entry = PhotoAlbum(photoURLs: photoURLs, maximumSelectCount: 5)
        entry.onPresenting.delegate(on: self) { (self, _) in
             return self
        }
        entry.onImageUpdated.delegate(on: self) { (self, _) in
            self.tableView.reloadData()
        }
        return entry
    }
    
    private var basicInformation: BasicInformation {
        
        let date = Date(timeIntervalSince1970: user.birthday)
        let entry = BasicInformation(
            name: user.nick,
            sex: user.sex ?? .female,
            dateOfBirth: date,
            follow: 6,
            isCertification: true,
            ID: user.userId.description)
        
        return entry
    }
    
    private var likeObject: TagContent {
        
        let tags = user.labelList.compactMap { $0.label }
        let entry = TagContent(imageName: "me-like-object", tags: tags, placeholder: nil)
        return entry
    }
    
    private var introduce: Introduce {
        
        let entry = Introduce(title: "介绍", content:user.introduce, placeholder: "此用户很懒，什么都没有写")
        return entry
    }
    
    private var industry: Introduce  {
        let entry = Introduce(title: "行业", content: user.industryList.first?.label, placeholder: "此用户很懒，什么都没有写")
        return entry
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
        return (0..<count).map { i -> TagContent in
            let imageName = "me-\(Hobby.allCases[i].rawValue)"
            let placeholder = "添加你喜欢的\(Hobby.allCases[i].description)吧～"
            let tags = hobbyLabel[i].map{ $0.label }
            return TagContent(imageName: imageName, tags: tags, placeholder: placeholder)
        }
    }
    
    private var sections: [FormSection] = []
    
    var user: User! {
        didSet {
            refreshData()
        }
    }
    
    func refreshData() {
        
        if let _ = user {
            sections =  [
                FormSection(entries: [profilePhoto], headerText: "头像"),
                FormSection(entries: [photoAlbum], headerText: "相册"),
                FormSection(entries: [basicInformation], headerText: "基础信息"),
                FormSection(entries: [likeObject], headerText: "喜欢的女生"),
                FormSection(entries: [introduce, industry], headerText: "我的信息"),
                FormSection(entries: [AddContent()], headerText: "小编专访"),
                FormSection(entries: hobbys, headerText: "我的爱好")
            ]
        }
        else {
            sections = []
        }

        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        let hub = MBProgressHUD.showAdded(to: view, animated: true)
        hub.show(animated: true)
        userAPI.request(.userinfo, type: HotChatResponse<User>.self)
            .subscribe(onSuccess: { [weak self] response in
                hub.hide(animated: true)
                if response.isSuccessd {
                    self?.user = response.data
                }
                else {
                    self?.show(response.msg)
                }
            }, onError: { [weak self] error in
                self?.show(error.localizedDescription)
                hub.hide(animated: true)
            })
            .disposed(by: rx.disposeBag)
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 3 {
            self.performSegue(withIdentifier: "UserInfoLikeObjectViewController", sender: nil)
        }
        else if indexPath.section == 4 && indexPath.row == 0 {
            self.performSegue(withIdentifier: "UserInfoInputTextViewController", sender: nil)
        }
    }
 
}


extension UserInfoEditingViewController {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let vc = segue.destination as? UserBasicInformationViewController {
            vc.user = user
            vc.onUpdated.delegate(on: self) { (self, user) in
                self.user = user
            }
        }
        else if let vc = segue.destination as? UserInfoLikeObjectViewController {
            
            vc.onUpdated.delegate(on: self) { (self, user) in
                self.user = user
                self.navigationController?.popViewController(animated: true)
            }
        }
        
    }
}
