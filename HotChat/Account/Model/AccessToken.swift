//
//  AccessToken.swift
//  HotChat
//
//  Created by 风起兮 on 2020/9/21.
//  Copyright © 2020 风起兮. All rights reserved.
//

import Foundation

protocol AccessTokenType {}


struct AccessToken: Codable, AccessTokenType, Equatable {

    /// The value of the access token.
    let value: String
    
    enum CodingKeys: String, CodingKey {
        case value = "token"
    }
    
    /// :nodoc:
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        value = try container.decode(String.self, forKey: .value)
    }

    // Internal helper for creating a new token object while retaining current ID Token when refreshing.
    init(value: String){
        self.value = value
    }

    /// :nodoc:
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(value, forKey: .value)
    }
}
