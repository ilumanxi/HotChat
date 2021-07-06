//
//  PlayerManager.swift
//  HotChat
//
//  Created by 风起兮 on 2021/3/8.
//  Copyright © 2021 风起兮. All rights reserved.
//

import UIKit
//import AliyunPlayer

//protocol PlayerItem {
//
//    var url: String { get }
//    var uid: String { get }
//}
//
//
//class PlayerContainerView: UIView {
//
//}

//class PlayerManager: NSObject {
    
//    let listPlayer: AliListPlayer
//    let cacheConfig: AVPCacheConfig
//    private(set) var playerView: UIView
//    private(set) var currentIndex: Int = -1
//    @objc dynamic private(set) var playerStatus: AVPStatus = AVPStatusIdle
//    var canPlay: Bool = true
//
//    var items: [PlayerItem] = []
//
//    override init() {
//
//        AliListPlayer.setEnableLog(false)
//
//        listPlayer = AliListPlayer()
//        listPlayer.scalingMode = AVP_SCALINGMODE_SCALEASPECTFIT
//        cacheConfig = AVPCacheConfig()
//        cacheConfig.enable = true
//        playerView = PlayerContainerView()
//        super.init()
//        setupPlayer(listPlayer, config: cacheConfig, playerView: playerView)
//    }
//
//    func setupPlayer(_ player: AliListPlayer, config: AVPCacheConfig, playerView: UIView) {
//        player.delegate = self
//        player.playerView = playerView
//        player.isLoop = true
//        player.isAutoPlay = true
//        player.scalingMode = AVP_SCALINGMODE_SCALEASPECTFIT
//        player.setCacheConfig(config)
//
//    }
//
//    func stop() {
//        self.listPlayer.playerView.isHidden = true
//        listPlayer.stop()
//        playerStatus = AVPStatusStopped
//    }
//
//    func pause() {
//        self.listPlayer.isAutoPlay = false
//        self.listPlayer.pause()
//        self.playerStatus = AVPStatusPaused
//    }
//
//    func resume() {
//        if canPlay {
//            self.listPlayer.isAutoPlay = true
//            self.listPlayer.start()
//            self.playerStatus = AVPStatusStarted
//        }
//        else {
//            self.listPlayer.isAutoPlay = false
//            self.listPlayer.pause()
//            self.playerStatus = AVPStatusPaused
//        }
//    }
//
//    func clear(){
//        self.listPlayer.clear()
//        self.currentIndex = -1
//    }
//
//    func remove(at index: Int) {
//        self.items.remove(at: index)
//        self.currentIndex = -1
//    }
//
//    func add(playList items: [PlayerItem]) {
//        self.items.append(contentsOf: items)
//        for item in items {
//            self.listPlayer.addUrlSource(item.url, uid: item.uid)
//        }
//    }
//
//    func play(at index: Int) {
//
//        if self.items.isEmpty {
//            debugPrint("PlayerManager： 没有可供播放的资源")
//            return
//        }
//
//        if index < 0 || index >= self.items.count {
//            debugPrint("PlayerManager： 没有可供播放的资源[\(0)..<\(self.items.count)], index: \(index)")
//            return
//        }
//
//        self.currentIndex = index
//
//        let item = self.items[index]
//
//        self.listPlayer.move(to: item.uid)
//    }
//
//    func addPlayView(in view: UIView) {
//        self.listPlayer.playerView.isHidden = false
//        self.listPlayer.playerView.frame = view.bounds
//        self.listPlayer.playerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//        view.addSubview(self.listPlayer.playerView)
//    }
//
//    func removePlayView()  {
//        self.listPlayer.playerView.removeFromSuperview()
//        self.listPlayer.playerView.isHidden = true
//        self.listPlayer.stop()
//        self.currentIndex = -1
//    }
//}
//
//
//extension PlayerManager: AVPDelegate {
//
//    func onError(_ player: AliPlayer!, errorModel: AVPErrorModel!) {
//        if errorModel.code == ERROR_SERVER_VOD_UNKNOWN {
//
//        }
//    }
//
//    func onPlayerEvent(_ player: AliPlayer!, eventType: AVPEventType) {
//        switch eventType {
//        case AVPEventPrepareDone:
//            self.setPlayerScalingMode()
//        case AVPEventLoadingStart:
//            break
//        case AVPEventLoadingEnd:
//            break
//        case AVPEventFirstRenderedStart:
//            self.listPlayer.playerView.isHidden = false
//        default:
//            break
//        }
//    }
//
//    func onPlayerStatusChanged(_ player: AliPlayer!, oldStatus: AVPStatus, newStatus: AVPStatus) {
//        self.playerStatus = newStatus
//
//        switch newStatus {
//        case AVPStatusStarted:
//            break
//        case AVPStatusPaused:
//            break
//        default:
//            break
//        }
//    }
//
//    func onLoadingProgress(_ player: AliPlayer!, progress: Float) {
//
//        let progressValue = progress / 100.0
//
//        debugPrint(progressValue)
//    }
//
//
//    func setPlayerScalingMode() {
//
//        guard let trackInfo = self.listPlayer.getMediaInfo()?.tracks.first else { return }
//
//        let isPhoneX = (UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0) > 0
//
//        if trackInfo.videoWidth < trackInfo.videoHeight && isPhoneX {
//            self.listPlayer.scalingMode = AVP_SCALINGMODE_SCALEASPECTFILL
//        }
//        else {
//            self.listPlayer.scalingMode = AVP_SCALINGMODE_SCALEASPECTFIT;
//        }
//    }
    
//}
