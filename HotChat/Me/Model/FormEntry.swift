//
//  FormEntry.swift
//  HotChat
//
//  Created by 风起兮 on 2020/9/4.
//  Copyright © 2020 风起兮. All rights reserved.
//

import UIKit
import SPAlertController
import ZLPhotoBrowser
import Reusable
import Photos


func writeImage(_ image: UIImage) -> URL! {
    
    let fileName =  ProcessInfo.processInfo.globallyUniqueString.appending(".png").replacingOccurrences(of: "-", with: "")
    let fileURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(fileName)
    
    try! image.pngData()?.write(to: fileURL)
    
    return fileURL
}



enum Section: Int, CaseIterable, CustomStringConvertible {
    case profilePhoto
    case photoAlbum
    case basicInformation
    case likeObject
    case introduce
    case interview
    case hobby
    
    var description: String {
        switch self {
        case .profilePhoto:
            return "头像"
        case .photoAlbum:
            return "相册"
        case .basicInformation:
            return "基本信息"
        case .likeObject:
            return "喜欢的对象"
        case .introduce:
            return "我的信息"
        case .interview:
            return "小编专访"
        case .hobby:
            return "我的爱好"
        }
    }
}

enum Hobby: String, CaseIterable, CustomStringConvertible {
    
    case motion
    case food
    case music
    case book
    case travel
    case movie
    
//    3运动 4美食 5音乐 6书籍 7旅行 8电影 9行业
    
    
    var type: Int {
        switch self {
        case .motion:
            return 3
        case .food:
            return 4
        case .music:
            return 5
        case .book:
            return 6
        case .travel:
            return 7
        case .movie:
            return 8
        }
    }
    
    var imageName: String {
        switch self {
        case .motion:
            return "me-movement"
        case .food:
            return "me-gourmet"
        case .music:
            return "me-music"
        case .book:
            return "me-books"
        case .travel:
            return "me-travel"
        case .movie:
            return "me-movie"
        }
    }
    
    
    var edit: String {
        switch self {
        case .motion:
            return "likeMotion"
        case .food:
            return "likeFood"
        case .music:
            return "likeMusic"
        case .book:
            return "likeBook"
        case .travel:
            return "likeTravel"
        case .movie:
            return "likeMovie"
        }
    }
    
    
    var description: String {
        switch self {
        case .motion:
            return "运动"
        case .food:
            return "美食"
        case .music:
            return "音乐"
        case .book:
            return "书籍"
        case .travel:
            return "旅行"
        case .movie:
            return "电影"
        }
    }
    
}


protocol FormEntry {
    func cell(_ tableView: UITableView, indexPath: IndexPath) -> UITableViewCell
}


class ProfilePhoto: FormEntry {
    
    var imageURL: URL?
    var score: String = "美如天仙"
    var description: String = "评分为精美，能快速获得异性的好感！并且系统会优先将你推荐至首页"
        
    let onPresenting = Delegate<(), UIViewController>()
    
    let onImageUpdated = Delegate<URL, Void>()
    
    func cell(_ tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        
        let cell  = tableView.dequeueReusableCell(for: indexPath, cellType: UserInfoProfilePhotoCell.self)
        
        render(cell)
        
        cell.profileImageView.isUserInteractionEnabled = true
        
        let tap  = UITapGestureRecognizer(target: self, action: #selector(tapProfileImageView))
        cell.profileImageView.addGestureRecognizer(tap)
        
        return cell
    }
    
    
    private func render(_ cell: UserInfoProfilePhotoCell) {
        cell.profileImageView.kf.setImage(with: imageURL)
        cell.scoreLabel.text = score
        cell.descriptionLabel.text = description
    }
    
    @objc func tapProfileImageView() {
        self.alert()
    }
    
    
    private func alert() {
        
        let alertController = SPAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.addAction(SPAlertAction(title: "更换", style: .default, handler: { [weak self] _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self?.imagePicker()
            }
        }))
                
        alertController.addAction(SPAlertAction(title: "取消", style: .cancel, handler: nil))
        
        guard let presentingViewController = onPresenting.call() else {
            return
        }
        
        presentingViewController.present(alertController, animated: true, completion: nil)
    }
    

    private func imagePicker()  {
        
        let config = ZLPhotoConfiguration.default()
        config.maxSelectCount = 1
        config.allowSelectVideo = false
        config.maxPreviewCount = 0
        
        let imagePickerController = ZLPhotoPreviewSheet(selectedAssets: [])
        imagePickerController.selectImageBlock = { [weak self] (images, assets, isOriginal) in
            if let image = images.first {
                let imageURL = writeImage(image)!
                self?.onImageUpdated.call(imageURL)
            }
            debugPrint("\(images)   \(assets)   \(isOriginal)")
        }
        
        guard let presentingViewController = onPresenting.call() else {
            return
        }
        
        imagePickerController.showPhotoLibrary(sender: presentingViewController)
        
    }
    
}


class PhotoAlbum: NSObject, FormEntry {

    let maximumSelectCount: Int
    
    var medias: [Media]
    
    let contentInsert: UIEdgeInsets = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
    
    let onPresenting = Delegate<(), UIViewController>()
    
    let onImageAdded = Delegate<URL, Void>()
    
    let onImageChanged = Delegate<(URL, Int), Void>()
    
    let onImageDeleted = Delegate<Int, Void>()
    
    var imageChangedShow = true
    
    
    init(medias: [Media], maximumSelectCount: Int) {
        self.medias = medias
        self.maximumSelectCount = maximumSelectCount
    }
    
    func cell(_ tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(for: indexPath, cellType: UserInfoPhotoAlbumCell.self)
        
        render(cell)
        return cell
    }
    
    private func render(_ cell: UserInfoPhotoAlbumCell) {
        cell.collectionViewHeightConstraint.constant = photoAlbumHeight
        cell.collectionView.delegate = self
        cell.collectionView.dataSource = self
        cell.collectionView.reloadData()
    }
}

extension PhotoAlbum: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var photoAlbumCount: Int {
        return min(medias.count + 1, maximumSelectCount)
    }
    
    var photoAlbumHeight: CGFloat {
        return CGFloat(maxRow) * itemWidth + CGFloat(lineIntervals) * itemInterval + contentInsert.top + contentInsert.bottom
    }
    
    
    var maxColumns:Int {
        return 4
    }
    
    
    /// 行间隙数
    var lineIntervals:Int{
        return maxRow - 1
    }
    
    /// 行数
    var maxRow: Int {
        let maxRow =  Int((Float(photoAlbumCount) / Float(maxColumns)).rounded(.up))
        return   maxRow > 0 && maxRow < 1 ? 1 : maxRow
    }
    
     var itemInterval: CGFloat {
          return 5
    }
    
    var itemSize: CGSize {
        let hv = itemWidth
        return CGSize(width: hv, height: hv)
    }
    
    var maximumWidth: CGFloat {
        return UIScreen.main.bounds.width
    }
    
    
    
    var itemWidth: CGFloat {
        return (maximumWidth - CGFloat(maxColumns - 1) * itemInterval - contentInsert.left - contentInsert.right) / CGFloat(maxColumns)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return  photoAlbumCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(for: indexPath, cellType: UserInfoMediaCell.self)
        
        if indexPath.item == medias.count { // add photo
            let image = UIImage(named: "add-gray")
            cell.imageView.contentMode = .center
            cell.imageView.image =  image
        }
        else {
            let media = medias[indexPath.item]
            cell.imageView.contentMode = .scaleAspectFill
            cell.imageView.kf.setImage(with: media.local ?? media.remote)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
         if indexPath.item == medias.count { // add photo
            imagePicker { [weak self] images, _, _ in
                if let image = images.first {
                    let imageURL = writeImage(image)!
                    self?.onImageAdded.call(imageURL)
                }
            }
         }
         else {
            let alertController = SPAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            if imageChangedShow {
                alertController.addAction(SPAlertAction(title: "更换", style: .default, handler: { [weak self] _ in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self?.imagePicker{ [weak self] images, _, _ in
                            if let image = images.first {
                                let imageURL = writeImage(image)!
                                self?.onImageChanged.call((imageURL, indexPath.item))
                            }
                        }
                    }
                }))
            }
            alertController.addAction(SPAlertAction(title: "删除", style: .default, handler: { [weak self] _ in
                self?.onImageDeleted.call(indexPath.item)
                
            }))
                    
            alertController.addAction(SPAlertAction(title: "取消", style: .cancel, handler: nil))
            
            guard let presentingViewController = onPresenting.call() else {
                return
            }
            
            presentingViewController.present(alertController, animated: true, completion: nil)
         }
    }
    
    private func imagePicker(_ selectImageBlock: @escaping ( ([UIImage], [PHAsset], Bool) -> Void )) {
        
        let config = ZLPhotoConfiguration.default()
        config.maxSelectCount = 1
        config.allowSelectVideo = false
        config.maxPreviewCount = 0
                
        
        let imagePickerController = ZLPhotoPreviewSheet(selectedAssets: [])
        imagePickerController.selectImageBlock = selectImageBlock
        
        guard let presentingViewController = onPresenting.call() else {
            return
        }
        
        imagePickerController.showPhotoLibrary(sender: presentingViewController)
    }
        
}

class Information: FormEntry {
    
    let user: User
    
    init(user: User) {
        self.user = user
    }
    
    func cell(_ tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(for: indexPath, cellType: InformationCell.self)
        render(cell)
        
        return cell
    }
    
    private func render(_ cell: InformationCell) {
        cell.idLabel.attributedText = attributedText(text: "ID：", detailText: user.userId.description)
        cell.industryLabel.attributedText = attributedText(text: "职业：", detailText: user.industryList.first?.label ?? "未知职业")
        cell.introduceLabel.attributedText = attributedText(text: "个性签名：", detailText: user.introduce.isEmpty ? "此用户很懒，什么都没有写" : user.introduce)

    }
    
    func attributedText(text: String, detailText: String) -> NSAttributedString {
        
        let string = "\(text)\(detailText)" as NSString
        let attributedString = NSMutableAttributedString(string: string as String)
        attributedString.addAttributes([.foregroundColor: UIColor.textBlack], range: string.range(of: text))
        attributedString.addAttributes([.foregroundColor: UIColor.textGray], range: string.range(of: detailText))
        
        return attributedString
    }
    
    
}

class BasicInformation: FormEntry {

    var name: String
    let sex: Sex
    var dateOfBirth: Date
    let follow: Int
    let isCertification: Bool
    let ID: String
    
    var age: Int {
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year], from: dateOfBirth, to: Date())
        return dateComponents.year!
    }
    
    init(name: String, sex: Sex, dateOfBirth: Date, follow: Int, isCertification: Bool, ID: String) {
        self.name = name
        self.sex = sex
        self.dateOfBirth = dateOfBirth
        self.follow = follow
        self.isCertification  = isCertification
        self.ID = ID
    }
    
    func cell(_ tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(for: indexPath, cellType: UserInfoBasicInformationCell.self)
        render(cell)
        
        return cell
    }
    
    private func render(_ cell: UserInfoBasicInformationCell) {
        cell.nameLabel.text = name
        cell.certificationView.backgroundColor = isCertification ? .red : .borderGray
        cell.sexImageView.image = sex.image
        cell.ageLabel.text = age.description
        cell.followLabel.text = follow.description
    }
    
}

class InfoInterview: FormEntry {

    let topic: Topic
    
    init(topic: Topic) {
        self.topic = topic
    }
    
    func cell(_ tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(for: indexPath, cellType: UserInfoInterviewCell.self)
        render(cell)
        
        return cell
        
    }
    
    private func render(_ cell: UserInfoInterviewCell) {
        
        cell.titleLabel.text = topic.label
        cell.contentLabel.text = topic.content
    }
}

class TagContent: FormEntry {

    let imageName: String
    var tags: [String]
    var placeholder: String?
    
    init(imageName: String, tags: [String], placeholder: String?) {
        self.imageName = imageName
        self.tags = tags
        self.placeholder = placeholder
    }
    
    func cell(_ tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(for: indexPath, cellType: UserInfoTagCell.self)
        render(cell)
        
        return cell
    }
    
    private func render(_ cell: UserInfoTagCell) {
        
        cell.iconImageView.image = UIImage(named: imageName)
        cell.placeholderButton.setTitle(placeholder, for: .normal)
        cell.tagListView.removeAllTags()
    
        if tags.isEmpty {
            cell.tagListView.isHidden = true
            cell.placeholderButton.isHidden = false
        }
        else {
            cell.tagListView.addTags(tags)
            cell.tagListView.isHidden = false
            cell.placeholderButton.isHidden = true
        }
    }
    
}

class Introduce: FormEntry {
    
    let title: String
    var content: String?
    var placeholder: String
    
    init(title: String, content: String?, placeholder: String) {
        self.title = title
        self.content = content
        self.placeholder = placeholder
    }
    
    func cell(_ tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(for: indexPath, cellType: UserInfoIntroduceCell.self)
        render(cell)
        
        return cell
    }
    
    private func render(_ cell: UserInfoIntroduceCell) {
        
        cell.titleLabel.text = title
        
        if let text = content, !text.isEmpty {
            cell.contentLabel.text = text
        }
        else {
            cell.contentLabel.text = placeholder
        }
    }
}


class AddContent: FormEntry {
    
    func cell(_ tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        return cell
    }
    
}
