//
//  TalkHeaderView.swift
//  HotChat
//
//  Created by 风起兮 on 2021/3/23.
//  Copyright © 2021 风起兮. All rights reserved.
//

import UIKit
import SVGAPlayer
import FSPagerView

let svgaParser = SVGAParser()

class TalkHeaderView: UIView {
    
    
    @IBOutlet weak var voiceMatchView: SVGAPlayer!
    
    @IBOutlet weak var videoMatchView: SVGAPlayer!
    
    @IBOutlet weak var headlineView: UIView!
    
    @IBOutlet weak var headlineButton: UIButton!
    
    @IBOutlet weak var headlineCornerView: UIView!
    
    @IBOutlet weak var listView: UIView!
    
    var bannerView: FSPagerView!
    
    let onVoice = Delegate<Void, Void>()
    let onVideo = Delegate<Void, Void>()
    let onHeadline = Delegate<Void, Void>()
    let onTop = Delegate<TalkTypeTop, Void>()
    
    
    var talkTop: TalkTop! {
        didSet {
            bannerView.reloadData()
        }
    }
    
    override func awakeFromNib() {
        
        svgaParser.parse(withNamed: "voice_match", in: nil) { videoItem in
            self.voiceMatchView.videoItem = videoItem
            self.voiceMatchView.startAnimation()
        } failureBlock: { error in
            print(error)
        }
        
        svgaParser.parse(withNamed: "video_match", in: nil) { videoItem in
            self.videoMatchView.videoItem = videoItem
            self.videoMatchView.startAnimation()
        } failureBlock: { error in
            print(error)
        }
        
        
        
        bannerView =  FSPagerView(frame: listView.bounds)
        bannerView.scrollDirection = .vertical
        bannerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        bannerView.bounces = false
        bannerView.isScrollEnabled = false
        bannerView.itemSize = FSPagerViewAutomaticSize // Fill parent
//        bannerView.interitemSpacing = 24
        bannerView.register(UINib(nibName: "ListViewCell", bundle: nil), forCellWithReuseIdentifier: "ListViewCell")
        
        
        bannerView.backgroundColor = .clear
        bannerView.automaticSlidingInterval = 7
        bannerView.isInfinite = true
        bannerView.delegate = self
        bannerView.dataSource = self
        listView.addSubview(bannerView)
        
        super.awakeFromNib()
    }
    
    var banners: [Banner] = [] {
        didSet {
            bannerView.itemSize = bannerView.frame.insetBy(dx: 12, dy: 5).size
            bannerView.reloadData()
        }
    }

    @IBAction func voice(_ sender: Any) {
        onVoice.call()
    }
    
    
    
    @IBAction func video(_ sender: Any) {
        onVideo.call()
    }
    
    
    @IBAction func headlineButtonTapped(_ sender: Any) {
        onHeadline.call()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        
        let flipNext = Selector("flipNextWithSender:")
        
        bannerView.perform(flipNext, with: nil)
    }


}


extension TalkHeaderView: FSPagerViewDataSource, FSPagerViewDelegate {
    
    
    func numberOfItems(in pagerView: FSPagerView) -> Int {
        return talkTop?.data.count ?? 0
    }
    
    func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        
        
        let cell = pagerView.dequeueReusableCell(withReuseIdentifier: "ListViewCell", at: index) as!  ListViewCell
        
        cell.set(model: talkTop.data[index])

        return cell
    }
    
    func pagerView(_ pagerView: FSPagerView, didSelectItemAt index: Int) {
        
        onTop.call(talkTop.data[index])
    }
    
}
