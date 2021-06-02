//
//  PlayerView.swift
//  HotChat
//
//  Created by 风起兮 on 2021/6/1.
//  Copyright © 2021 风起兮. All rights reserved.
//

import UIKit
import AVFoundation

class PlayerView: UIView {
    // MARK: Properties
    
    var player: AVPlayer? {
        get {
            return playerLayer.player
        }
        
        set {
            playerLayer.player = newValue
        }
    }
    
    var playerLayer: AVPlayerLayer {
        return layer as! AVPlayerLayer
    }
    
    override class var layerClass: AnyClass {
        return AVPlayerLayer.self
    }
}
