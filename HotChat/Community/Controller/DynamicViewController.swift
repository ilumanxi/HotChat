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


class DynamicViewController: UITableViewController, IndicatorDisplay, StoryboardCreate {
    
    static var storyboardNamed: String { return "Community" }
    
    let uploadAPI = Request<UploadFileAPI>()
    
    let dynamicAPI = Request<DynamicAPI>()
    
    fileprivate var formEntries: [FormEntry] = []
    
    var text: String? {
        didSet {
//            reloadData()
        }
    }
    
    var medias: [Media] = [] {
        didSet {
            reloadData()
        }
    }
    
    
    var textInput: TextIput {
        let entry = TextIput(text: text)
        entry.onTextUpdated.delegate(on: self) { (self, text) in
            self.text = text
        }
        return entry
    }
    
    
    var photoAlbum: PhotoAlbum {
        let entry = PhotoAlbum(medias: medias, maximumSelectCount: 8, radio: false)
        entry.imageChangedShow = false
        entry.onPresenting.delegate(on: self) { (self, _) -> UIViewController in
            return self
        }
        
        entry.onImageDeleted.delegate(on: self) { (self, index) in
            self.medias.remove(at: index)
        }
        entry.onImageAdded.delegate(on: self) { (self, urls) in
            let newAdd: [Media] =  urls.compactMap{ Media(remote: nil, local: $0) }
            self.medias.append(contentsOf: newAdd)
        }
        return entry
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        reloadData()
    }
    
    
    func reloadData() {
        
        formEntries = [
            textInput,
            photoAlbum
        ]
        tableView.reloadData()
    }

    // MARK: - Table view data source


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return formEntries.count
    }

  
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        return formEntries[indexPath.row].cell(tableView, indexPath: indexPath)
    }
    
    
    @IBAction func dimisss(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
    func uploadMedia(_ media: Media) -> Single<Media> {
        if media.remote == nil {
            return uploadAPI
                .request(.upload(media.local!), type: Response<[RemoteFile]>.self)
                .verifyResponse()
                .map{ urls in
                    media.remote = URL(string: urls.data?.first?.picUrl ?? "")
                    return media
                }
        }
        else {
            return .just(media)
        }
    }
    
    @IBAction func send(_ sender: Any) {
        
        var parameters: [String : Any] = [:]
        
        guard let text = text, !text.isEmpty else {
            showMessageOnWindow("请输入文字")
            return
        }
        
        if medias.isEmpty {
            showMessageOnWindow("请添加图片")
            return
        }
        
        parameters["content"] = text
        
       
        let urls: [Single<Media>] =   medias.compactMap(uploadMedia)
        showIndicatorOnWindow()
        Observable.from(urls)
            .flatMap{$0}
            .subscribe(onError: { [weak self] error in
                self?.hideIndicatorFromWindow()
                self?.show(error.localizedDescription)
            }, onCompleted: { [weak self] in
                guard let self = self else { return }
                
                let mediaList = self.medias
                    .compactMap {
                        ["picUrl": $0.remote!.absoluteString]
                    }
        
                if self.medias.first!.isImage {
                    parameters["type"] = 1
                    parameters["photoList"] = mediaList
                }
                else {
                    parameters["type"] = 2
                    parameters["liveList"] = mediaList
                }
        
                
                self.dynamicAPI.request(.releaseDynamic(parameters), type: ResponseEmpty.self)
                    .subscribe(onSuccess: { [weak self] response in
                        self?.hideIndicatorFromWindow()
                        self?.showMessageOnWindow(response.msg)
                        if response.isSuccessd {
                            self?.dismiss(animated: true, completion: nil)
                        }
                    }, onError: { [weak self] error in
                        self?.hideIndicatorFromWindow()
                        self?.showMessageOnWindow(error.localizedDescription)
                    })
                    .disposed(by: self.rx.disposeBag)
                
            })
            .disposed(by: rx.disposeBag)
        
        
        
        

    }
}
