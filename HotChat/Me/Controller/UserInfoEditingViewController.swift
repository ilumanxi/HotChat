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


class UserInfoEditingViewController: UITableViewController, IndicatorDisplay, StoryboardCreate {
    
    static var storyboardNamed: String { return "Me" }
    let userAPI = Request<UserAPI>()
    
    let uploadAPI = Request<UploadFileAPI>()
    
    private var profilePhoto: ProfilePhoto {
        let entry = ProfilePhoto()
        entry.imageURL = URL(string: user.headPic)
        entry.onPresenting.delegate(on: self) { (self, _) in
             return self
        }
        entry.onImageUpdated.delegate(on: self) { (self, url) in
            self.showIndicatorOnWindow()
            
            self.upload(url)
                .map{ response -> [String : Any] in
                    return [
                        "type" : 3,
                        "headPic" : response.data!.first!.picUrl
                    ]
                }
                .flatMap { [unowned self] in
                    return self.editUserInfo($0)
                }
                .subscribe(onSuccess: { [weak self] response in
                    self?.hideIndicatorFromWindow()
                    if response.isSuccessd {
                        self?.user = response.data!
                    }
                    else {
                        self?.showMessageOnWindow(response.msg)
                    }
                }, onError: { [weak self]  error in
                    self?.hideIndicatorFromWindow()
                    self?.showMessageOnWindow(error.localizedDescription)
                })
                .disposed(by: self.rx.disposeBag)
            
        }
        
        return entry
    }
    
    private var photoAlbum: PhotoAlbum {
        let medias = user.photoList.compactMap{ Media(remote: URL(string: $0.picUrl)!, local: nil) }
        let entry = PhotoAlbum(medias: medias, maximumSelectCount: 8)
        entry.onPresenting.delegate(on: self) { (self, _) in
             return self
        }
        entry.onImageAdded.delegate(on: self) { (self, urls) in
            self.showIndicatorOnWindow()
            self.upload(urls.first!)
                .map{ response -> [String : Any] in
                    let photoList = (response.data!.toJSON() as [[String: Any]?]).compactMap{ $0 }
                    Log.print(type(of: photoList))
                    return [
                        "type" : 3,
                        "photoList" : photoList
                    ]
                }
                .flatMap{ [unowned self] in
                    self.editUserInfo($0)
                }
                .subscribe(onSuccess: { [weak self] response in
                    self?.user = response.data!
                    self?.hideIndicatorFromWindow()
                }, onError: { [weak self]  error in
                    self?.hideIndicatorFromWindow()
                    self?.showMessageOnWindow(error.localizedDescription)
                })
                .disposed(by: self.rx.disposeBag)
        }
        
        entry.onImageChanged.delegate(on: self) { (self, info) in
           let (url, index) = info
            self.upload(url)
                .map { response -> [String : Any]  in
                    let photos =  self.user.photoList
                    var photoList = photos.compactMap { photo -> [String : Any] in
                        return ["picId" : photo.picId, "picUrl" : photo.picUrl ]
                    }
                    
                    let photo = response.data!.first!
                    let picId =  photoList[index]["picId"] as! Int
                    photoList[index] = ["picId" : picId, "picUrl" : photo.picUrl ]
                    
                    let parameters: [String : Any] = [
                        "type" : 3,
                        "photoList" : photoList
                    ]
                    return parameters
                }
                .flatMap{ [unowned self] in
                    self.editUserInfo($0)
                }
                .subscribe(onSuccess: { [weak self] response in
                    self?.user = response.data!
                    self?.hideIndicatorFromWindow()
                }, onError: { [weak self]  error in
                    self?.hideIndicatorFromWindow()
                    self?.showMessageOnWindow(error.localizedDescription)
                })
                .disposed(by: self.rx.disposeBag)
        }
        
        entry.onImageDeleted.delegate(on: self) { (self, index) in
            
            let photo =  self.user.photoList[index]
    
            self.showIndicatorOnWindow()
            self.delPhoto(photo.picId)
                .subscribe(onSuccess: { [weak self] response in
                    self?.user = response.data!
                    self?.hideIndicatorFromWindow()
                }, onError: { [weak self]  error in
                    self?.hideIndicatorFromWindow()
                    self?.showMessageOnWindow(error.localizedDescription)
                })
                .disposed(by: self.rx.disposeBag)
        }
        
        return entry
    }
    
    
    func upload(_ url: URL) -> Single<Response<[RemoteFile]>> {
        return uploadAPI.request(.upload(url)).checkResponse()
    }
    
    func editUserInfo(_ parameters: [String : Any]) -> Single<Response<User>> {
        return userAPI.request(.editUser(value: parameters)).checkResponse()
    }
    
    func delPhoto(_ picId: Int) -> Single<Response<User>> {
        return userAPI.request(.delPhoto(picId: picId)).checkResponse()
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
        return (0..<count).map { i -> TagContent in
            let placeholder = "添加你喜欢的\(Hobby.allCases[i].description)吧～"
            let tags = hobbyLabel[i].map{ $0.label }
            return TagContent(imageName: Hobby.allCases[i].imageName, tags: tags, placeholder: placeholder)
        }
    }
    
    private var sections: [FormSection] = []
    
    var user: User! = User() {
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
                FormSection(entries: tips + [AddContent()], headerText: "小编专访"),
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
        refreshData()
        
        self.showIndicatorOnWindow()
        userAPI.request(.userinfo(userId: nil), type: Response<User>.self)
            .checkResponse()
            .subscribe(onSuccess: { [weak self] response in
                self?.user = response.data
                self?.hideIndicatorFromWindow()
            }, onError: { [weak self] error in
                self?.hideIndicatorFromWindow()
                self?.showMessageOnWindow(error.localizedDescription)
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
            
            self.performSegue(withIdentifier: "UserInfoInputTextViewController", sender: sections[indexPath.section].formEntries[indexPath.row])
        }
        else if indexPath.section == 4 && indexPath.row == 1 {
            industryEdit()
        }
        else if indexPath.section == 5 {
            
            if let entry = sections[indexPath.section].formEntries[indexPath.row] as? InfoInterview {
                self.performSegue(withIdentifier: "UserInfoInputTextViewController", sender: entry)
            }
            else {
                topicAdd()
            }
        }
        else if indexPath.section == 6 {
            hobbyEdit(Hobby.allCases[indexPath.row])
        }
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        if let entry = sections[indexPath.section].formEntries[indexPath.row] as? InfoInterview {
            
            return [
                UITableViewRowAction(style: .destructive, title: "删除", handler: { [weak self] (action, indexPath) in
                    self?.topicDelete(entry.topic)
                })
            ]
        }
        
        return nil
    }
        
    func topicDelete(_ topic: Topic) {
        
        self.showIndicatorOnWindow()
        userAPI.request(.delQuestion(labelId: topic.labelId), type: Response<User>.self)
            .checkResponse()
            .subscribe(onSuccess: { [weak self] response in
                self?.user = response.data
                self?.hideIndicatorFromWindow()
            }, onError: { [weak self]  error in
                self?.hideIndicatorFromWindow()
                self?.showMessageOnWindow(error.localizedDescription)
            })
            .disposed(by: rx.disposeBag)
    }
    
    func topicAdd()  {
        
        let vc = TitleViewController()
        vc.title = "小编专访"
        
        navigationController?.pushViewController(vc, animated: true)

        
        self.showIndicatorOnWindow()
        userAPI.request(.userConfig(type: 2), type: Response<[Topic]>.self)
            .subscribe(onSuccess: { [weak self] response in
                vc.tips = response.data ?? []
                self?.hideIndicatorFromWindow()
            }, onError: { [weak self] error in
                self?.hideIndicatorFromWindow()
                self?.showMessageOnWindow(error.localizedDescription)
            })
            .disposed(by: rx.disposeBag)
        
        vc.onSaved.delegate(on: self) { (self, topic) in
            self.userAPI.request(.editTips(labelId: topic.id, content: topic.content), type: Response<User>.self)
                .subscribe(onSuccess: { response in
                    self.user = response.data
                    self.navigationController?.popToViewController(self, animated: true)
                    self.hideIndicatorFromWindow()
                }, onError: { error in
                    self.hideIndicatorFromWindow()
                    self.showMessageOnWindow(error.localizedDescription)
                })
                .disposed(by: vc.rx.disposeBag)
        }
    }
    
    func hobbyEdit(_ hobby: Hobby) {
        let vc = LabelViewController()
        vc.title = hobby.description
        vc.maximumCount = 10
        vc.onSaved.delegate(on: self) { (self, labels) in
            
            let ids = labels.compactMap{ $0.id.description }.joined(separator: ",")
            
            let params: [String : Any] = [
                "type" : 2,
                hobby.edit : ids
            ]
            
            self.showIndicatorOnWindow()
            self.editUserInfo(params)
                .subscribe(onSuccess: { [unowned self] response in
                    self.user = response.data
                    self.navigationController?.popToViewController(self, animated: true)
                    self.hideIndicatorFromWindow()
                }, onError: { [weak self] error in
                    self?.hideIndicatorFromWindow()
                    self?.showMessageOnWindow(error.localizedDescription)
                })
                .disposed(by: vc.rx.disposeBag)
        }
        
        navigationController?.pushViewController(vc, animated: true)
        
        
        self.showIndicatorOnWindow()
        userAPI.request(.userConfig(type: hobby.type), type: Response<[LikeTag]>.self)
            .checkResponse()
            .subscribe(onSuccess: { [weak self] response in
                vc.labels = response.data ?? []
                self?.hideIndicatorFromWindow()
            }, onError: { [weak self] error in
                self?.hideIndicatorFromWindow()
                self?.show(error.localizedDescription)
            })
            .disposed(by: rx.disposeBag)
    }
    
    func industryEdit() {
        let vc = LabelViewController()
        vc.title = "行业"
        vc.onSaved.delegate(on: self) { (self, labels) in
            
            let industry = labels.compactMap{ $0.id.description }.joined(separator: ",")
            
            let params: [String : Any] = [
                "type" : 2,
                "industry" : industry
            ]
            
            
            self.showIndicatorOnWindow()
            self.editUserInfo(params)
                .subscribe(onSuccess: { [unowned self] response in
                    self.user = response.data
                    self.navigationController?.popToViewController(self, animated: true)
                    self.hideIndicatorFromWindow()
                    
                }, onError: { [weak self] error in
                    self?.hideIndicatorFromWindow()
                    self?.showMessageOnWindow(error.localizedDescription)
                })
                .disposed(by: vc.rx.disposeBag)
        }
        
        navigationController?.pushViewController(vc, animated: true)
        
        self.showIndicatorOnWindow()
        userAPI.request(.userConfig(type: 9), type: Response<[LikeTag]>.self)
            .checkResponse()
            .subscribe(onSuccess: { [weak  self] response in
                vc.labels = response.data ?? []
                self?.hideIndicatorFromWindow()
            }, onError: { [weak self] error in
                self?.hideIndicatorFromWindow()
                self?.showMessageOnWindow(error.localizedDescription)
            })
            .disposed(by: rx.disposeBag)
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
        else if let vc = segue.destination as? UserInfoInputTextViewController, let _ = sender as? Introduce {
            vc.content = (introduce.title, nil, introduce.content)
            vc.onSaved.delegate(on: self) { (self, text) in
                let params: [String : Any] = [
                    "type": 2,
                    "introduce" : text
                ]
                
                self.showIndicatorOnWindow()
                self.editUserInfo(params)
                    .subscribe(onSuccess: { [unowned self] response in
                        self.user = response.data
                        self.navigationController?.popToViewController(self, animated: true)
                        self.hideIndicatorFromWindow()
                    }, onError: { [weak self] error in
                        self?.hideIndicatorFromWindow()
                        self?.showMessageOnWindow(error.localizedDescription)
                       
                    })
                    .disposed(by: vc.rx.disposeBag)
            }
        }
        else if let vc = segue.destination as? UserInfoInputTextViewController, let entry = sender as? InfoInterview {
            vc.content = ("你的回答", entry.topic.label, entry.topic.content)
            vc.onSaved.delegate(on: self) { (self, text) in
                
                self.showIndicatorOnWindow()
                self.userAPI.request(.editTips(labelId: entry.topic.labelId, content: text), type: Response<User>.self)
                    .checkResponse()
                    .subscribe(onSuccess: { [unowned self] response in
                        self.user = response.data
                        self.navigationController?.popToViewController(self, animated: true)
                        self.hideIndicatorFromWindow()
                    }, onError: { [weak self] error in
                        self?.hideIndicatorFromWindow()
                        self?.show(error.localizedDescription)
                    })
                    .disposed(by: vc.rx.disposeBag)
            }
        }
        
    }
}
