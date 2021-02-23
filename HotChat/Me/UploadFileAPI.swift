//
//  UploadFileAPI.swift
//  HotChat
//
//  Created by 风起兮 on 2020/9/27.
//  Copyright © 2020 风起兮. All rights reserved.
//

import Foundation
import Moya
import HandyJSON
import RxSwift


enum UploadFileAPI {
    
    case upload(URL)
    case uploadFile(URL)
    
}

extension UploadFileAPI: TargetType {
    
    var path: String {
        switch self {
        case .upload:
            return "upload/upload"
        case .uploadFile: 
            return "upload/uploadFile"
        }
    }
    
    var task: Task {
        switch self {
        case .upload(let url):
            return .uploadMultipart([MultipartFormData(provider: .file(url), name: "image")])
        case .uploadFile(let url):
            return .uploadMultipart([MultipartFormData(provider: .file(url), name: "file")])
        }
    }
    
}


@objc class RemoteFile: NSObject, HandyJSON {
    
    var picId: Int = 0
    
    @objc var picUrl = ""
    
    required override init() {
        super.init()
    }
}


@objc class UploadHelper: NSObject {
    

    static let upload  = Request<UploadFileAPI>()
    
    static let disposeObject = DisposeBag()
    
    @objc class func  uploadImage(_ image: UIImage, success: @escaping (RemoteFile) -> Void, failed: @escaping (NSError) -> Void) {
        
        let url = writeImage(image)
        upload.request(.upload(url), type: Response<[RemoteFile]>.self)
            .verifyResponse()
            .subscribe(onSuccess: { response in
                success(response.data!.first!)
            }, onError: { error in
                failed(error as NSError)
            })
            .disposed(by: disposeObject)
    }
}
