//
//  LoadingState.swift
//  HotChat
//
//  Created by 风起兮 on 2020/10/13.
//  Copyright © 2020 风起兮. All rights reserved.
//

import Foundation


@objc enum LoadingState: Int {
    /// The initial state.
    case initial
    /// The first load of content.
    case loadingContent
    /// Subsequent loads after the first.
    case refreshingContent
    /// After content is loaded successfully.
    case contentLoaded
    /// No content is available.
    case noContent
    /// An error occurred while loading content.
    case error
    
    var isLoading: Bool {
        return self == .loadingContent || self == .refreshingContent
    }
    
    
    static var validTransitions: [LoadingState :[LoadingState]] {
        
        return [
            .initial: [.loadingContent],
            .loadingContent: [.contentLoaded, .noContent, .error],
            .refreshingContent: [.contentLoaded, .noContent, .noContent],
            .contentLoaded: [.refreshingContent, .noContent, .noContent],
            .noContent: [.refreshingContent, .contentLoaded, .noContent],
            .error: [.loadingContent, .refreshingContent, .noContent, .contentLoaded]
        ]
        
    }
    
    func applyState(state: LoadingState) -> Bool {
        
        return true
    }
    
    enum LoadStateError: Error {
        case modify(String)
    }
    
    func validateTransition(from fromState: LoadingState, to toState: LoadingState) throws -> LoadingState {
        
        let validTransitions = LoadingState.validTransitions[fromState]!
        
        if !validTransitions.contains(toState){
            
            throw LoadStateError.modify("IllegalStateTransition: cannot transition from \(fromState) to \(toState)")
        }
        
        return  toState
    }
    
}
