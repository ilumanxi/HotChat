//
//  FormEntry.swift
//  HotChat
//
//  Created by 风起兮 on 2020/9/4.
//  Copyright © 2020 风起兮. All rights reserved.
//

import UIKit
import SPAlertController
import Reusable
import Photos
import TZImagePickerController

func writeImage(_ image: UIImage) -> URL {
    
    let image = image.compressed(quality: 0.5)
    let fileName =  ProcessInfo.processInfo.globallyUniqueString.appending(".png").replacingOccurrences(of: "-", with: "")
    let fileURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(fileName)
    
    try! image?.pngData()?.write(to: fileURL)
    return fileURL
}

func writeImages(_ images: [UIImage]) -> [URL] {
    
    var urls: [URL] = []
    
    for image in images {
        urls.append(writeImage(image))
    }
    return urls
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
    var score: String = "评分：评分中"
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
    }
    
    @objc func tapProfileImageView() {
        self.alert()
    }
    
    
    private func alert() {
        
        guard let presentingViewController = onPresenting.call() else {
            return
        }
        
        let alertController = SPAlertController(title: nil, message: "", preferredStyle: .actionSheet)
        alertController.addAction(SPAlertAction(title: "更换", style: .default, handler: { [weak self] _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self?.photoPicker()
            }
        }))
                
        alertController.addAction(SPAlertAction(title: "取消", style: .cancel, handler: nil))
        
        presentingViewController.present(alertController, animated: true, completion: nil)
    }
    
    
    func photoPicker() {
        
        guard let presentingViewController = onPresenting.call() else {
            return
        }
        
        let imagePickerController = TZImagePickerController(maxImagesCount: 1, delegate: nil)!
        imagePickerController.allowPickingVideo = false
        imagePickerController.allowPickingImage = true
        imagePickerController.allowCrop = true
        
        let size = UIScreen.main.bounds.width

        let v = (UIScreen.main.bounds.height - size) / 2.0
        
        imagePickerController.cropRect = CGRect(x: 0, y: v, width: size, height: size)
        imagePickerController.scaleAspectFillCrop = true
        imagePickerController.didFinishPickingPhotosHandle = { [weak self] (photos,assets, isSelectOriginalPhoto) in
            if let image = photos?.first {
                let imageURL = writeImage(image)
                self?.onImageUpdated.call(imageURL)
            }
        }
        
        imagePickerController.modalPresentationStyle = .fullScreen
        presentingViewController.present(imagePickerController, animated: true, completion: nil)
    }
    
    
}


class PhotoAlbum: NSObject, FormEntry {

    let maximumSelectCount: Int
    let radio: Bool
    var medias: [Media]
    
    let contentInsert: UIEdgeInsets = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
    
    let onPresenting = Delegate<Void, UIViewController>()
    
    let onImageAdded = Delegate<[URL], Void>()
    
    let onImageChanged = Delegate<(URL, Int), Void>()
    
    let onImageDeleted = Delegate<Int, Void>()
    
    var imageChangedShow = true
    
    
    init(medias: [Media], maximumSelectCount: Int, radio: Bool = true) {
        self.medias = medias
        self.radio = radio
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
        
        guard let presentingViewController = onPresenting.call() else {
            return
        }
        
         if indexPath.item == medias.count { // add photo
            
            let count = radio ? 1 : maximumSelectCount - medias.count
            self.photoPicker(maxImagesCount: count) { [weak self] (images, _, _) in
                let urls = writeImages(images!)
                self?.onImageAdded.call(urls)
            }
            
         }
         else {
            let alertController = SPAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            if imageChangedShow {
                alertController.addAction(SPAlertAction(title: "更换", style: .default, handler: { [weak self] _ in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self?.photoPicker(maxImagesCount: 1, didFinishPickingPhotosHandle: { (images, _, _) in
                            if let image = images?.first {
                                let imageURL = writeImage(image)
                                self?.onImageChanged.call((imageURL, indexPath.item))
                            }
                        })
                    }
                }))
            }
            alertController.addAction(SPAlertAction(title: "删除", style: .default, handler: { [weak self] _ in
                self?.onImageDeleted.call(indexPath.item)
                
            }))
                    
            alertController.addAction(SPAlertAction(title: "取消", style: .cancel, handler: nil))
            

            
            presentingViewController.present(alertController, animated: true, completion: nil)
         }
    }
    
    func photoPicker(maxImagesCount: Int, didFinishPickingPhotosHandle:@escaping ([UIImage]?, [Any]?, Bool) -> Void) {
        
        guard let presentingViewController = onPresenting.call() else {
            return
        }
        
        let imagePickerController = TZImagePickerController(maxImagesCount: maxImagesCount, delegate: nil)!
        imagePickerController.allowPickingVideo = false
        imagePickerController.allowPickingImage = true
        imagePickerController.allowCrop = maxImagesCount == 1
        
        let size = UIScreen.main.bounds.width

        let v = (UIScreen.main.bounds.height - size) / 2.0
        
        imagePickerController.cropRect = CGRect(x: 0, y: v, width: size, height: size)
        imagePickerController.scaleAspectFillCrop = true
        imagePickerController.didFinishPickingPhotosHandle = didFinishPickingPhotosHandle
        
        imagePickerController.modalPresentationStyle = .fullScreen
        presentingViewController.present(imagePickerController, animated: true, completion: nil)
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

    let user: User
    
    init(user: User) {
        self.user = user
    }
    
    func cell(_ tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(for: indexPath, cellType: UserInfoBasicInformationCell.self)
        render(cell)
        
        return cell
    }
    
    private func render(_ cell: UserInfoBasicInformationCell) {
        cell.nameLabel.text = user.nick
        cell.certificationView.isHidden = user.realNameStatus != .ok
        cell.sexView.setSex(user)
        cell.followLabel.text = user.userFollowNum.description
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
