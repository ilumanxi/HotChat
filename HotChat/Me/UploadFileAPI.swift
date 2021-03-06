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
    case violate(file: URL, type: Int, voiceDuration: TimeInterval)
    
}

extension UploadFileAPI: TargetType {
    
    var path: String {
        switch self {
        case .upload:
            return "upload/upload"
        case .uploadFile: 
            return "upload/uploadFile"
        case .violate:
            return "v1/violate/check"
        }
    }
    
    var task: Task {
        switch self {
        case .upload(let url):
            return .uploadMultipart([MultipartFormData(provider: .file(url), name: "image")])
        case .uploadFile(let url):
            return .uploadMultipart([MultipartFormData(provider: .file(url), name: "file")])
        case .violate(let file, let type, let voiceDuration):
            var parameters: [String : Any] = [:]
            parameters["type"] = type
            parameters["voiceDuration"] = voiceDuration
            return .uploadCompositeMultipart([MultipartFormData(provider: .file(file), name: "file")], urlParameters: parameters)
        }
    }
    
}


@objc class RemoteFile: NSObject, HandyJSON {
    
    var picId: Int = 0
    
    @objc var picUrl = ""
    
    var width: CGFloat = 0
    var height: CGFloat = 0
    
    var size: CGSize {
        return CGSize(width: width, height: height)
    }
    
    required override init() {
        super.init()
    }
}


@objc class UploadHelper: NSObject {
    
    static let upload  = Request<UploadFileAPI>()
    
    static let disposeObject = DisposeBag()
    
    // 1:图片,2:语音
    @objc class func violate(file: URL, type: Int, voiceDuration: TimeInterval, success: @escaping ([String : Any]) -> Void, failed: @escaping (NSError) -> Void) {
        upload.request(.violate(file: file, type: type, voiceDuration: voiceDuration), type: Response<[String : Any]>.self)
            .verifyResponse()
            .subscribe(onSuccess: { resonse in
                success(resonse.data ?? [:])
            }, onError: { error in
                failed(error as NSError)
            })
            .disposed(by: disposeObject)
    }
    
    @objc class func uploadImage(_ image: UIImage, success: @escaping (RemoteFile) -> Void, failed: @escaping (NSError) -> Void) {
        
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
