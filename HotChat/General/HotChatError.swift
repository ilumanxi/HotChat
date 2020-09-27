//
//  HotChatError.swift
//  HotChat
//
//  Created by 风起兮 on 2020/9/21.
//  Copyright © 2020 风起兮. All rights reserved.
//

import Foundation


enum HotChatError: Error {
    
    enum AuthorizeErrorReason {
        
        /// An error occurs while accessing the keychain. It prevents the LINE SDK from
        ///  loading data from or writing data to the keychain. Code 3012.
        /// - status: The `OSStatus` number system gives.
        case keychainOperation(status: OSStatus)
        
        /// The retrieved authorization information from the keychain cannot be converted to valid data. Code 3013.
        case invalidDataInKeychain
    }
    
    enum UploadFileErrorReason {
        case generaError(string: String)
    }
    
    
    public enum GeneralErrorReason {
        /// Cannot convert `string` to valid data with `encoding`. Code 4001.
        case conversionError(string: String, encoding: String.Encoding)

        /// The method is invoked with an invalid parameter. Code 4002.
        case parameterError(parameterName: String, description: String)

    }
    
    /// An error occurred while authorizing a user.
    case authorizeFailed(reason: AuthorizeErrorReason)
    
    /// The retrieved authorization information from the keychain cannot be converted to valid data. Code 3013.
    case invalidDataInKeychain
    
    
    /// An error occurred while performing another process in the HotChat
    case generalError(reason: GeneralErrorReason)
    
    case uploadFileError(reason: UploadFileErrorReason)
    
}
