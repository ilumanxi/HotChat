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


enum UploadFileAPI {
    
    case upload(URL)
    
}

extension UploadFileAPI: TargetType {

    var baseURL: URL {
        return Constant.APIHostURL
    }
    
    var path: String {
        
        return "upload/upload"
    }
    
    var method: Moya.Method {
        return .post
    }
    
    var sampleData: Data {
        return Data()
    }
    
    var task: Task {
        switch self {
        case .upload(let url):
            return .uploadMultipart([MultipartFormData(provider: .file(url), name: "image")])
        }
    }
    
    var headers: [String : String]? {
        return nil
    }
    
}


struct RemoteFile: HandyJSON {
    
    var picId: Int = 0
    
    var picUrl = ""
}
