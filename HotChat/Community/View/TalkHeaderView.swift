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
import RxSwift
import RxCocoa

let svgaParser = SVGAParser()

class TalkHeaderView: UIView {
    
    
    @IBOutlet weak var voiceMatchView: SVGAPlayer!
    
    @IBOutlet weak var videoMatchView: SVGAPlayer!
    
    @IBOutlet weak var headlineView: UIView!
    
    @IBOutlet weak var headlineButton: UIButton!
    
    @IBOutlet weak var headlineCornerView: UIView!
    
    @IBOutlet weak var headlineContentView: GradientView!
    
    @IBOutlet weak var headlineCotentLabel: UILabel!
    
    @IBOutlet weak var marqueeView: UIView!
    
    @IBOutlet weak var listView: UIView!
    
    var bannerView: FSPagerView!
    
    let onVoice = Delegate<Void, Void>()
    let onVideo = Delegate<Void, Void>()
    let onHeadline = Delegate<Void, Void>()
    let onTop = Delegate<TalkTypeTop, Void>()
    let onUser = Delegate<String, Void>()
    
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
        
        marqueeVerticalCompleted()
        
        marqueeHorizontalCompleted()
       
        super.awakeFromNib()
    }
    
    
    /// 特殊
    fileprivate var horizontalMarquees: [Marquee] = []
    
    /// 普通
    fileprivate var verticalMarquees: [Marquee] = []
    
    var isHorizontalMarqueeFinished = true
    
    var isVerticalMarqueeFinished = true
    
    func addMarquee(_ marquee: Marquee) {
        
        if marquee.type == 1 || marquee.type == 2 { // 普通、 特殊
            verticalMarquees.append(marquee)
            if isVerticalMarqueeFinished {
                addMarqueeVerticalNext()
            }
            
        }
        else if marquee.type == 0 { // 头条
            horizontalMarquees.append(marquee)
            if isHorizontalMarqueeFinished {
                addMarqueeHorizontalNext()
            }
        }
    }
    
    
    func addMarqueeHorizontalNext() {
        if !isHorizontalMarqueeFinished {
            return
        }
        
        if horizontalMarquees.isEmpty {
            return
        }
        
        let marquee = horizontalMarquees.removeFirst()
        addMarqueeHorizontal(marquee)
        
    }
    
    private func addMarqueeHorizontal(_ marquee: Marquee) {
        isHorizontalMarqueeFinished = false
        headlineView.isUserInteractionEnabled = true
        
        let attributedText = horizontalAttributedText(marquee: marquee, seconds: marquee.stayTime)
        
        for gestureRecognizer in headlineCotentLabel.gestureRecognizers ?? [] {
            headlineCotentLabel.removeGestureRecognizer(gestureRecognizer)
        }
        
        headlineCotentLabel.isUserInteractionEnabled = true
        headlineCotentLabel.attributedText = attributedText
        
        headlineCotentLabel.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer()
        tap.rx.event
            .subscribe(onNext: { [weak self] _ in
                self?.onUser.call(marquee.fromUserId)
            })
            .disposed(by: rx.disposeBag)
        headlineCotentLabel.addGestureRecognizer(tap)
        
        addMarqueeHorizontalAnimation()
        
        let countdown =  Observable<Int>.countdown(marquee.stayTime).share()
        countdown
            .map { [unowned self] seconds in
                return self.horizontalAttributedText(marquee: marquee, seconds: seconds)
            }
            .bind(to: headlineCotentLabel.rx.attributedText)
            .disposed(by: rx.disposeBag)
        
        countdown
            .subscribe(onCompleted: { [weak self] in
                self?.isHorizontalMarqueeFinished = true
                self?.marqueeHorizontalCompleted()
            })
            .disposed(by: rx.disposeBag)
        
    }
    
    func addMarqueeHorizontalAnimation() {
        
        headlineContentView.transform = CGAffineTransform(translationX: headlineView.bounds.width, y: 0)
        headlineContentView.isHidden = false
        UIView.animate(withDuration: 0.25) {
            self.headlineContentView.transform = CGAffineTransform.identity
        } completion: { _ in

        }
       
    }
    
    func addMarqueeVerticalNext() {
        
        if !isVerticalMarqueeFinished {
            return
        }
        
        if verticalMarquees.isEmpty {
            return
        }
        
        let marquee = verticalMarquees.removeFirst()
        addMarqueeVertical(marquee)
    }
    
    
    @objc func marqueeHorizontalCompleted() {
        headlineContentView.isHidden = true
        headlineContentView.transform = CGAffineTransform(translationX: headlineView.bounds.width, y: 0)
        headlineView.isUserInteractionEnabled = false
        
        if !horizontalMarquees.isEmpty {
            addMarqueeHorizontalNext()
        }
    }
    
    @objc func marqueeVerticalCompleted() {
        
        if verticalMarquees.isEmpty {
            let _ = addMarqueeVerticalLabel(attributedText: NSAttributedString(string: "Hi~接下来的动态信息，第一时间掌握交友秘诀哦。"))
            addMarqueeVerticalAnimation()
        }
        else {
            addMarqueeVerticalNext()
        }
        
    }
    
    private func addMarqueeVertical(_ marquee: Marquee) {
        isVerticalMarqueeFinished = false
        
        let attributedText = verticalAttributedText(marquee: marquee, seconds: marquee.stayTime)
        
        let label =  addMarqueeVerticalLabel(attributedText: attributedText)
        addMarqueeVerticalAnimation()
        
        label.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer()
        tap.rx.event
            .subscribe(onNext: { [weak self] _ in
                self?.onUser.call(marquee.fromUserId)
            })
            .disposed(by: label.rx.disposeBag)
        label.addGestureRecognizer(tap)
        
        let countdown =  Observable<Int>.countdown(marquee.stayTime).share()
        
        countdown
            .map { [unowned self] seconds in
                return self.verticalAttributedText(marquee: marquee, seconds: seconds)
            }
            .bind(to: label.rx.attributedText)
            .disposed(by: label.rx.disposeBag)
        
        countdown
            .subscribe(onCompleted: { [weak self] in
                self?.isVerticalMarqueeFinished = true
                self?.marqueeVerticalCompleted()
            })
            .disposed(by: label.rx.disposeBag)
        
    }
    
    
    
    func verticalAttributedText(marquee: Marquee, seconds: Int) -> NSAttributedString {
        
        let string = NSMutableAttributedString()
        string.append(NSAttributedString(string: marquee.fromUserName, attributes: [NSAttributedString.Key.foregroundColor : UIColor(hexString: "#F5A700")]))
        string.append(NSAttributedString(string: "送"))
        string.append(NSAttributedString(string: marquee.toUserName, attributes: [NSAttributedString.Key.foregroundColor : UIColor(hexString: "#F5A700")]))
        string.append(NSAttributedString(string: "\(marquee.giftCount)个"))
        string.append(NSAttributedString(string: marquee.giftName, attributes: [NSAttributedString.Key.foregroundColor : UIColor(hexString: "#E3300D")]))
        string.append(NSAttributedString(string: "，掌声祝福，鼓掌，鼓掌，鼓掌"))
        if marquee.stayTime > 1 {
            string.append(NSAttributedString(string:"（\(seconds)s）", attributes: [NSAttributedString.Key.foregroundColor : UIColor(hexString: "#E3300D")]))
        }
        return string
    }
    
    func horizontalAttributedText(marquee: Marquee, seconds: Int) -> NSAttributedString {
        let string = NSMutableAttributedString()
        string.append(NSAttributedString(string: marquee.fromUserName, attributes: [NSAttributedString.Key.foregroundColor : UIColor(hexString: "#F5A700")]))
        string.append(NSAttributedString(string: "：\(marquee.noticeText ?? "")"))
        if marquee.stayTime > 1 {
            string.append(NSAttributedString(string:"（\(seconds)s）", attributes: [NSAttributedString.Key.foregroundColor : UIColor(hexString: "#E3300D")]))
        }
        return string
    }
    
    
    func addMarqueeVerticalAnimation() {
        
        UIView.animate(withDuration: 0.25) {
            for view in self.marqueeView.subviews {
                var frame = view.frame
                frame.origin.y -= self.marqueeView.bounds.height
                view.frame = frame
            }
            
        } completion: { _ in
            for view in self.marqueeView.subviews {
                
                if view.frame.minY < 0 {
                    view.removeFromSuperview()
                }
            }
        }
    }
    
    // "Hi~接下来的动态信息，第一时间掌握交友秘诀哦。"
    func addMarqueeVerticalLabel(attributedText: NSAttributedString) -> UILabel {
        
        let frame = CGRect(x: 0, y: marqueeView.bounds.height, width: marqueeView.bounds.width, height: marqueeView.bounds.height);
        
        let label = UILabel(frame: frame)
        label.numberOfLines = 2
        label.textAlignment = .left
        label.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        label.font = .systemFont(ofSize: 13, weight: .medium)
        label.textColor = UIColor(hexString: "#333333")
        label.attributedText = attributedText
        marqueeView.addSubview(label)
        return label
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
