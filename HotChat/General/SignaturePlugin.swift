//
//  RequestSignaturePlugin.swift
//  HotChat
//
//  Created by 风起兮 on 2020/9/23.
//  Copyright © 2020 风起兮. All rights reserved.
//

import Moya

final class SignaturePlugin {

    let salt: String
    
    private let signKey = "sign"

    /// Initializes a NetworkLoggerPlugin.
    public init(salt: String) {
        self.salt = salt
    }
}


// MARK: - PluginType
extension SignaturePlugin: PluginType {
   
    func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
        
        if shouldRequest(request) {
            return prepareSignRequest(request)
        }
        
        return request
    }
    
    
    var prefixs: [String] {
        
        return ["login"]
    }
    
    func shouldRequest(_ request: URLRequest) -> Bool {
        
        guard  let url = request.url, let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return false
        }
        
        let path = urlComponents.path
                
        for prefix in prefixs where path.contains(prefix) {
            
            return  true
        }
        
        return false
    }
    

    func prepareSignRequest(_ request: URLRequest) -> URLRequest {
        
        let httpMethod = (request.httpMethod ?? "").uppercased()
        
        if httpMethod == "POST" {
            
            var request = request
            
            var jsonObject = requestParameters(request)
            
            jsonObject[signKey] = parametersSignature(jsonObject, salt: salt)
            
            let data = try! JSONSerialization.data(withJSONObject: jsonObject, options: .fragmentsAllowed)
            
            request.httpBody = data
            
            return request
        }
        else {
            
            let parameters = requestParameters(request)
            let signString = parametersSignature(parameters, salt: salt)
            
            var urlComponents = URLComponents(url: request.url!, resolvingAgainstBaseURL: false)!
            var queryItems = urlComponents.queryItems ?? []
            queryItems.append(URLQueryItem(name: signKey, value: signString))

            urlComponents.queryItems  = queryItems

            return try! URLRequest(url: urlComponents.url!, method: .get)
        }
    }
    
    func signParameters(_ parameters: [String : Any], salt: String) -> [String : Any] {
        
        let sign = parametersSignature(parameters, salt: salt)
        
        var params: [String : Any] = parameters
    
        params["sign"] = sign
        
        return params
    }
    
    func parametersSignature(_ parameters: [String : Any], salt: String) -> String {
        var result = [String]()
        
        jsonToAscendingArray(parameters, result: &result)

        var string = result
            .sorted(by: <)
            .joined(separator: "&")

        string.append("&\(salt)")

        return string.md5().uppercased()

    }
    
    func jsonToAscendingArray(_ json: [String : Any], parentKey: String = "", result: inout [String])  { // Comparable
        
        let keys = [String] (json.keys)
        
        for key in keys {
            
            let fullKey =  parentKey.isEmpty ? key : "\(parentKey).\(key)"
            
            let value = json[key]!
            
            if let v =  value as? [[String: Any]] {
                
                for json in v {
                    jsonToAscendingArray(json, parentKey:fullKey ,result: &result)
                    
                }
            }
            else if let v =  value as? [CustomStringConvertible] {
                
                let strs = v
                    .map{$0.description}
                    .joined(separator: "")
                
                result.append("\(fullKey)=\(strs)")
            }
                
            else if let v =  value as? [String : Any] {
                jsonToAscendingArray(v, parentKey: fullKey, result: &result)
            }
            else if let v =  value as? CustomStringConvertible , !v.description.isEmpty {//, !v.description.isEmpty
                result.append("\(fullKey)=\(v)")
            }
        }
        
    }
    
    
    private func httpBodyString(_ request: URLRequest) -> String {
    
        guard let httpBody = request.httpBody else {
            return ""
        }
        
        return String(data: httpBody, encoding: .utf8) ?? ""
    }
    
    private func requestParameters(_ request: URLRequest) -> [String : Any] {
        
        var parameters = [String : Any]()
        
        guard let url = request.url else {
            return parameters
        }
        
        let httpMethod = (request.httpMethod ?? "").uppercased()
        
        if httpMethod == "POST", let httpBody = request.httpBody {
           
            return  try! JSONSerialization.jsonObject(with: httpBody, options: .allowFragments) as! [String : Any]
        }
        
        let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)!
                
        guard let queryItems = urlComponents.queryItems  else {
            return parameters
        }
        
        for item in queryItems {
            parameters.updateValue(item.value ?? "" , forKey: item.name)
        }
        
        return parameters
    }
}
