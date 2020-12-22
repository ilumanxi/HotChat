//
//  ReportAPI.swift
//  HotChat
//
//  Created by 风起兮 on 2020/10/14.
//  Copyright © 2020 风起兮. All rights reserved.
//

import Moya
import RxSwift
import RxCocoa


enum ReportAPI {
    case reportConfig(Int) //举报类型 1动态举报 2用户举报
    case userReport([String : Any])
    case dynamicReport(dynamicId: String, content: String)
    case oneKeyReport(reportUserId: String, img: String)
}

extension ReportAPI: TargetType {
    var baseURL: URL {
        return Constant.APIHostURL
    }
    
    var path: String {
        switch self {
        case .reportConfig:
            return "Report/reportConfig"
        case .userReport:
            return "Report/userReport"
        case .dynamicReport:
            return "Report/dynamicReport"
        case .oneKeyReport:
            return "Report/oneKeyReport"
        }
    }
    
    var method: Moya.Method {
        return .post
    }
    
    var sampleData: Data {
        return Data()
    }
    
    var task: Task {
        let parameters: [String : Any]
        
        switch self {
        case .reportConfig(let type):
            parameters = ["type" : type]
        case .userReport(let value):
            parameters = value
        case .dynamicReport(let dynamicId, let content):
            parameters = [
                "dynamicId" : dynamicId,
                "content" : content
            ]
        case .oneKeyReport(let reportUserId, let img):
            parameters = [
                "reportUserId" : reportUserId,
                "img" : img
            ]
        }
        
        let encoding: ParameterEncoding = (method == .post) ? JSONEncoding.default : URLEncoding.default
        
        return .requestParameters(parameters: parameters, encoding: encoding)
    }
    
    var headers: [String : String]? {
        return nil
    }
}


class ReportHelper: NSObject {
    
    let uploadFileAPI = Request<UploadFileAPI>()
    let reportAPI = Request<ReportAPI>()
    
    @objc func oneKeyReport(reportUserId: String, img: UIImage, success: @escaping ([String: Any]) -> Void, failed: @escaping (NSError) -> Void) {
        let url = writeImage(img)
        upload(url)
            .flatMap { [unowned self] response in
                 self.imageReport(reportUserId: reportUserId, img: response.data?.first?.picUrl ?? "")
            }
            .subscribe(onSuccess: { response in
                success(response.data!)
            }, onError: { error in
                failed(error as NSError)
            })
            .disposed(by: rx.disposeBag)
    }
    
    private func imageReport(reportUserId: String, img: String) -> Single<Response<[String : Any]>> {
        
        return reportAPI.request(.oneKeyReport(reportUserId: reportUserId, img: img)).verifyResponse()
    }
    
    private func upload(_ url: URL) -> Single<Response<[RemoteFile]>> {
        return uploadFileAPI.request(.upload(url)).verifyResponse()
    }
}
