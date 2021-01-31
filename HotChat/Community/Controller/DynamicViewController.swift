//
//  DynamicViewController.swift
//  HotChat
//
//  Created by 风起兮 on 2020/10/10.
//  Copyright © 2020 风起兮. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import MagazineLayout
import TZImagePickerController

class Media: NSObject {
    var remote: URL?
    var local: URL?
    
    init(remote: URL?, local: URL?) {
        self.remote = remote
        self.local = local
    }
    
    var display: URL? {
        if local != nil {
            return local
        }
        else {
            return remote
        }
        
    }
}

extension Media {
    
    var mimeType: String? {
        
        guard let url = local else { return nil }
        
        let semaphore = DispatchSemaphore(value: 0)
        
        var mimeType: String? = nil
        
        let dataTask = URLSession.shared.dataTask(with: url) { (_, response, _) in
            mimeType = response?.mimeType
            semaphore.signal()
        }
        dataTask.resume()
        _ = semaphore.wait(timeout: DispatchTime.distantFuture)
        return mimeType
    }
    
    var isImage: Bool  {
        return mimeType?.contains("image") ?? false
    }
    
}



class MediaItem: NSObject {
    
    let image: UIImage
    let asset:  PHAsset
    
    var photo: Media?
    
    var video: Media?
    
    init(asset:  PHAsset, image: UIImage) {
        self.asset = asset
        self.image = image
    }
}


extension MediaItem {
    
    var isImage: Bool  {
        return asset.mediaType == .image
    }
    
    var isVideo: Bool  {
        return asset.mediaType == .video
    }
}



class DynamicViewController: UIViewController, IndicatorDisplay {
    
    
    let uploadAPI = Request<UploadFileAPI>()
    
    let dynamicAPI = Request<DynamicAPI>()
    
    
    let onSened = Delegate<Void, Void>()
    
    let limitLength = 200
    
    @IBOutlet weak var textView: PlaceholderTextView!
    @IBOutlet weak var limitedCountLabel: UILabel!
    
    @IBOutlet weak var buttonView: UIView!
    
    let layout = MagazineLayout()
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var collectionViewHeightConstraint: NSLayoutConstraint!
    
    
    var medias: [MediaItem] = [] {
        didSet {
            updateViews()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        observerState()
        updateViews()
    }
    
    func updateViews() {
        buttonView.isHidden = !medias.isEmpty
        collectionView.isHidden = medias.isEmpty
        collectionViewHeightConstraint.constant = collectionViewHeight(for: CGFloat(self.medias.count + 1))
        collectionView.reloadData()
    }
    
    func observerState() {
        
        let textSignal =  textView.rx.text.orEmpty.share(replay: 1)
        
        let textLengthSignal =  textSignal
            .map{ ($0 as NSString).length }
            .share(replay: 1)
        
        textSignal
            .filter { [unowned self] text in
                text.length > self.limitLength
            }
            .map{ [unowned self] text in
                (text as NSString).substring(to: self.limitLength)
            }
            .bind(to: textView.rx.text)
            .disposed(by: rx.disposeBag)
        
        
        textLengthSignal
            .map{ [unowned self] length in
                "\(length)/\(self.limitLength)"
            }
            .bind(to: limitedCountLabel.rx.text)
            .disposed(by: rx.disposeBag)
    }
    

    func setupViews() {
        collectionView.register(UINib(nibName: "MediaItemAddViewCell", bundle: nil), forCellWithReuseIdentifier: "MediaItemAddViewCell")
        collectionView.register(UINib(nibName: "MediaItemViewCell", bundle: nil), forCellWithReuseIdentifier: "MediaItemViewCell")
        collectionView.setCollectionViewLayout(layout, animated: false)
        
        collectionViewHeightConstraint.constant = collectionViewHeight(for: CGFloat(max(self.medias.count, 1)))
        
        let closeItem = UIBarButtonItem(title: "取消", style: .plain, target: self, action: #selector(dimisss))
        let sendItem = UIBarButtonItem(title: "发表", style: .plain, target: self, action: #selector(send))
        
        navigationItem.leftBarButtonItem = closeItem
        navigationItem.rightBarButtonItem = sendItem
    }
    
    let sectionInset: UIEdgeInsets = UIEdgeInsets(top: 0, left: 15, bottom: 20, right: 15)
    let itemsPerRow: CGFloat = 4
    let horizontalSpacing: CGFloat = 10
    let verticalSpacing: CGFloat = 10
    
    private var itemSize: CGSize {
        let itemSize = (UIScreen.main.bounds.width - (sectionInset.left + sectionInset.right) - (itemsPerRow - 1) * horizontalSpacing) / itemsPerRow
        return CGSize(width: itemSize, height: itemSize)
    }
    
    func collectionViewHeight(for itemsCount: CGFloat) -> CGFloat {
        
        let rows = (itemsCount / itemsPerRow).rounded(.up)
        
        let height = sectionInset.top + sectionInset.bottom +  itemSize.height * rows + (rows - 1) * verticalSpacing
        
        return height
    }
    
        
    @objc func dimisss() {
        dismiss(animated: true, completion: nil)
    }

    func prepare(_ media: MediaItem) -> Single<MediaItem> {
        return  Single<MediaItem>.create { (observer) -> Disposable in
            if media.asset.mediaType == .video {
                if media.video == nil  {
                    let url = writeImage(media.image)
                    media.photo = Media(remote: nil , local: url)
                    self.requestVideoURL(asset: media.asset) { result in
                        switch result {
                        case .success(let url):
                            media.video = Media(remote: nil , local: url)
                            observer(.success(media))
                        case .failure(let error):
                            observer(.error(error))
                        }
                    }
                }
                else {
                    observer(.success(media))
                }
            }
            else {
                if media.photo == nil  {
                    let url = writeImage(media.image)
                    media.photo = Media(remote: nil , local: url)
                }
                observer(.success(media))
            }
            return Disposables.create()
        }
        
    }
    
    func upload(_ media: MediaItem) -> Single<MediaItem> {
        if media.asset.mediaType == .image {
           return prepare(media).flatMap(uploadImage)
        }
        else {
            let photo = prepare(media).flatMap(uploadImage)
            let video = prepare(media).flatMap(uploadVideo)
            return Single<MediaItem>.zip(photo, video) { (p, v) -> MediaItem in
                return p
            }
        }
    }
    
    func uploadImage(_ media: MediaItem) -> Single<MediaItem> {
        if media.photo?.remote == nil {
            return uploadAPI
                .request(.upload(media.photo!.local!), type: Response<[RemoteFile]>.self)
                .verifyResponse()
                .map{ urls in
                    media.photo?.remote = URL(string: urls.data?.first?.picUrl ?? "")
                    return media
                }
        }
        else {
            return .just(media)
        }
    }
    
    func uploadVideo(_ media: MediaItem) -> Single<MediaItem> {
        if media.video?.remote == nil {
            return uploadAPI
                .request(.uploadFile(media.video!.local!), type: Response<[[String : Any]]>.self)
                .verifyResponse()
                .map{ urls in
                    let urlString = urls.data?.first?["fileUrl"] as? String
                    media.video?.remote = URL(string: urlString ?? "")
                    return media
                }
        }
        else {
            return .just(media)
        }
    }
    
    
    @IBAction func videoButtonTapped(_ sender: Any) {
        
        let imagePickerController = TZImagePickerController(maxImagesCount: 1, delegate: nil)!
        imagePickerController.allowPickingVideo = true
        imagePickerController.allowPickingImage = false
        imagePickerController.videoMaximumDuration = 15
        
        imagePickerController.didFinishPickingVideoHandle = { [unowned self] (coverImage, asset) in
            
            self.medias.append(MediaItem(asset: asset!, image: coverImage!))
        }
            
        imagePickerController.modalPresentationStyle = .fullScreen
        present(imagePickerController, animated: true, completion: nil)
    }
    
    let maximumCount = 9
    
    
    @IBAction func photoButtonTapped(_ sender: Any) {
        
        let maxImagesCount =  maximumCount - self.medias.count
        
        let imagePickerController = TZImagePickerController(maxImagesCount: maxImagesCount, delegate: nil)!
        imagePickerController.allowPickingVideo = false
        imagePickerController.allowPickingImage = true
        
        imagePickerController.didFinishPickingPhotosHandle = { [unowned self] (images, assets, isSelectOriginalPhoto) in
            
            guard let images = images, let assets = assets else {
                return
            }
            
            var items: [MediaItem] = []
            
            for i in 0..<images.count {
                items.append(MediaItem(asset: assets[i] as! PHAsset, image: images[i]))
            }
            medias.append(contentsOf: items)
        }
        
        imagePickerController.modalPresentationStyle = .fullScreen
        present(imagePickerController, animated: true, completion: nil)
    }
    
    
    func requestVideoURL(asset: PHAsset, block: @escaping (Swift.Result<URL, Error>) -> Void) {
       
        let videoFileName = "\(UUID().uuidString).mp4".replacingOccurrences(of: "-", with: "").replacingOccurrences(of: "/", with: "")
        let outputURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(videoFileName)
        
        let options = PHVideoRequestOptions()
        options.isNetworkAccessAllowed = true
        options.deliveryMode = .automatic
        options.progressHandler = { progress, _, _, _ in
            // The handler may originate on a background queue, so
            // re-dispatch to the main queue for UI work.
        }
        
        PHImageManager.default().requestExportSession(
            forVideo: asset,
            options: options,
            exportPreset: AVAssetExportPreset640x480)
            { (exportSession, info) in
                guard let exportSession = exportSession else {
                    return
                }
                exportSession.outputFileType = .mp4
                exportSession.outputURL = outputURL
                exportSession.exportAsynchronously(completionHandler: {
                    switch exportSession.status {
                    case .unknown, .waiting, .exporting:
                        break
                    case .completed:
                        Thread.safeAsync {
                            block(.success(outputURL))
                        }
                    case .cancelled, .failed:
                        Thread.safeAsync {
                            block(.failure(exportSession.error!))
                        }
                    @unknown default:
                        break
                    }
                })
            }
    }
    
    @objc func send() {
        
        var parameters: [String : Any] = [:]
        
        guard let text = textView.text, !text.isEmpty else {
            showMessageOnWindow("请添加文字")
            return
        }
        
        if medias.isEmpty {
            showMessageOnWindow("请添加图片/视频")
            return
        }
        
        parameters["content"] = text
        

        let urls: [Single<MediaItem>] =  medias.compactMap(upload)
        showIndicatorOnWindow()
        Observable.from(urls)
            .flatMap{$0}
            .subscribe(onError: { [weak self] error in
                self?.hideIndicatorFromWindow()
                self?.show(error)
            }, onCompleted: { [weak self] in
                guard let self = self else { return }
                
                if self.medias.first!.isImage {
                    parameters["type"] = 1
                    parameters["photoList"] = self.medias
                        .compactMap {
                            ["picUrl": $0.photo!.remote!.absoluteString]
                        }
                }
                else {
                    parameters["type"] = 2
                    parameters["videoUrl"] = self.medias.first!.video!.remote!.absoluteString
                    parameters["videoCoverUrl"] = self.medias.first!.photo!.remote!.absoluteString
                }
                
                self.dynamicAPI.request(.releaseDynamic(parameters), type: ResponseEmpty.self)
                    .verifyResponse()
                    .subscribe(onSuccess: { [weak self] response in
                        self?.hideIndicatorFromWindow()
                        self?.showMessageOnWindow(response.msg)
                        self?.onSened.call()
                        self?.dismiss(animated: true, completion: nil)
                    }, onError: { [weak self] error in
                        self?.hideIndicatorFromWindow()
                        self?.showMessageOnWindow(error)
                    })
                    .disposed(by: self.rx.disposeBag)

            })
            .disposed(by: rx.disposeBag)
        
    }
}

extension DynamicViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if !medias.isEmpty && medias.first!.asset.mediaType == .video {
            return
        }
        
        if indexPath.item < medias.count { // 图片点击
            
        }
        else {
            photoButtonTapped("")
        }
        
    }
}


// MARK: UICollectionViewDelegateMagazineLayout

extension DynamicViewController: UICollectionViewDelegateMagazineLayout {

  func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    sizeModeForItemAt indexPath: IndexPath)
    -> MagazineLayoutItemSizeMode
  {
    return MagazineLayoutItemSizeMode(widthMode: .fourthWidth, heightMode: .static(height: itemSize.height))
  }

  func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    visibilityModeForHeaderInSectionAtIndex index: Int)
    -> MagazineLayoutHeaderVisibilityMode
  {
    return .hidden
  }

  func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    visibilityModeForFooterInSectionAtIndex index: Int)
    -> MagazineLayoutFooterVisibilityMode
  {
    return .hidden
  }

  func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    visibilityModeForBackgroundInSectionAtIndex index: Int)
    -> MagazineLayoutBackgroundVisibilityMode
  {
    return .hidden
  }

  func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    horizontalSpacingForItemsInSectionAtIndex index: Int)
    -> CGFloat
  {
    return horizontalSpacing
  }

  func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    verticalSpacingForElementsInSectionAtIndex index: Int)
    -> CGFloat
  {
    return verticalSpacing
  }

  func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    insetsForSectionAtIndex index: Int)
    -> UIEdgeInsets
  {
    return sectionInset
  }

  func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    insetsForItemsInSectionAtIndex index: Int)
    -> UIEdgeInsets
  {
    return .zero
  }

  func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    finalLayoutAttributesForRemovedItemAt indexPath: IndexPath,
    byModifying finalLayoutAttributes: UICollectionViewLayoutAttributes)
  {
    // Fade and drop out
    finalLayoutAttributes.alpha = 0
    finalLayoutAttributes.transform = .init(scaleX: 0.2, y: 0.2)
  }

}



extension DynamicViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if !medias.isEmpty && medias.first!.asset.mediaType == .video {
            return medias.count
        }
        
        return  min(medias.count + 1, maximumCount)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.item < medias.count {
            let media = medias[indexPath.item]
            
            let cell = collectionView.dequeueReusableCell(for: indexPath, cellType: MediaItemViewCell.self)
            cell.imageView.image = media.image
            cell.playImageView.isHidden = media.asset.mediaType == .image
            cellAddCorner(cell)
            cell.onDelete.delegate(on: self) { (self, _) in
                if let index = self.medias.firstIndex(where: { $0 == media }) {
                    self.medias.remove(at: index)
                }
            }
            
            return cell
        }
        else {
            let cell = collectionView.dequeueReusableCell(for: indexPath, cellType: MediaItemAddViewCell.self)
            cellAddCorner(cell)
            return cell
        }

    }
    
    
    func cellAddCorner(_ cell: UICollectionViewCell) {
        cell.layer.cornerRadius = 5
        cell.layer.borderWidth = 1
        cell.layer.borderColor = UIColor(hexString: "#F7F6F6").cgColor
    }
}
