//
//  GiftAPI.swift
//  HotChat
//
//  Created by 风起兮 on 2020/11/17.
//  Copyright © 2020 风起兮. All rights reserved.
//

import Moya
import RxSwift
import MJExtension
import Alamofire
import SSZipArchive

enum GiftAPI {
    case giftList
    case giftNumConfig
}

extension GiftAPI: TargetType {

    var path: String {
        switch self {
        case .giftList:
            return "Gift/giftList"
        case .giftNumConfig:
            return "Gift/giftNumConfig"
        }
    }
    
    var task: Task {
        
        let parameters: [String : Any]
        switch self {
        case .giftList:
            parameters = [:]
        case .giftNumConfig:
            parameters = [:]
        }
        return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)
    }
    
}



@objc class GiftHelper: NSObject {
    
    static let API  = Request<GiftAPI>()
    
    static let disposeObject = DisposeBag()
    
    static let key = "GiftHelper.cacheGifCountConfig"
    
    @objc class var cacheGifCountConfig: [GiftCountDescription]? {
        
        get {
            let json = UserDefaults.standard.object(forKey: key) as? [[String: Any]]
            return json?.compactMap{ GiftCountDescription.deserialize(from: $0) }
        }
        set {
            guard let data = newValue else {
                UserDefaults.standard.set(nil, forKey: key)
                return
            }
           let json =  data.compactMap { $0.toJSON() }
           UserDefaults.standard.set(json, forKey: key)
        }
    }
    
    @objc class func giftNumConfig(success: @escaping ([GiftCountDescription]) -> Void, failed: @escaping (Error) -> Void) {
        
        API.request(.giftNumConfig, type: Response<[GiftCountDescription]>.self)
            .verifyResponse()
            .subscribe(onSuccess: {  response in
                let data = response.data ?? []
                cacheGifCountConfig = data
                success(data)
            }, onError: { error in
                failed(error)
            })
            .disposed(by: disposeObject)
    }
    
    static let userSettingsAPI  = Request<UserSettingsAPI>()
    
    static let component = "GiftSpecialEffectsResources"
    
    static func gitResourceURL(_ giftID: String) -> URL? {
        var destination = cachesDirectoryURL(component)
        destination.appendPathComponent("\(giftID).svga")
        if FileManager.default.fileExists(atPath: destination.path) {
            return destination
        }
        return nil
    }
    
    static func cachesDirectoryURL(_ component: String) -> URL {
        
        let directoryURLs = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
        
        let url = directoryURLs.first?.appendingPathComponent(component)
        
        return url!
    }
    
    public typealias Destination = (_ temporaryURL: URL,
                                    _ response: HTTPURLResponse) -> (destinationURL: URL, options: Alamofire.DownloadRequest.Options)
    
    @objc static func giftDownResources() {
        userSettingsAPI.request(.downResources, type: Response<[String : Any]>.self)
            .verifyResponse()
            .subscribe(onSuccess: { respone in
                let file = cachesDirectoryURL("\(component).zip")
                
                if let data = respone.data, let downUrl = data["downUrl"] as? String, let md5 = data["md5"] as? String, md5File(file) != md5  {
                    downloadGiftResources(url: downUrl)
                }
            }, onError: { error in
                print(error)
            })
            .disposed(by: disposeObject)
    }
    
    static func  destination (
        _ temporaryURL: URL,
        _ response: HTTPURLResponse) -> (destinationURL: URL, options: Alamofire.DownloadRequest.Options) {
        let url = cachesDirectoryURL("\(component).zip")
        return (url, .removePreviousFile)
    }
    
    
    static func downloadGiftResources(url: String)  {
        
        AF.download(url, to: destination)
            .responseURL { downloadResponse in
                do {
                    let path = downloadResponse.value!.path
                    
                    let destination = cachesDirectoryURL(component)
                    try SSZipArchive.unzipFile(atPath: path, toDestination: destination.path, overwrite: true, password: nil)
                } catch let e {
                    print(e)
                }
            }
        
    }
    
}

    
   

