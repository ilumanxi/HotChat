//
//  GiftEffectsViewController.swift
//  HotChat
//
//  Created by 风起兮 on 2021/5/10.
//  Copyright © 2021 风起兮. All rights reserved.
//

import UIKit
import SVGAPlayer

class GiftEffectsController: NSObject {
    
    weak var owner: UIViewController?
    
    private(set) var isPlaying: Bool = false
    
    private(set) var gifts: [URL] = []
    
    @objc
    init(owner: UIViewController) {
        self.owner = owner
        super.init()
    }
    
    @objc
    func addQueue(_ gift: Gift) {
        if let url = GiftHelper.gitResourceURL( gift.id) {
            gifts.append(url)
            playerNextGift()
        }
    }
    
    private func player(_ gift: URL) {
        self.isPlaying = true
        let vc = GiftEffectsViewController(gift: gift)
        vc.finishedAnimation = { [weak self] in
            self?.isPlaying = false
            self?.playerNextGift()
        }
        
        if self.owner?.isKind(of: ChatViewController.self) ?? false {
            vc.onBack = { [weak self] in
                self?.owner?.presentedViewController?.dismiss(animated: false, completion: nil)
                self?.owner?.navigationController?.popViewController(animated: true)
            }
        }
        self.owner?.presentTopMost(vc, animated: false)
    }
    
    private func playerNextGift() {
        
        if isPlaying {
            return
        }
        
        if gifts.isEmpty {
            return
        }
        
        let gift = self.gifts.removeFirst()
        
        player(gift)
    }
}

class GiftEffectsViewController: UIViewController, SVGAPlayerDelegate {
    
    
    @IBOutlet weak var playerView: SVGAPlayer!
    
    let gift: URL
    
    var finishedAnimation: (() -> Void)?
    var onBack: (() -> Void)?
    
    @objc
    init(gift: URL) {
        self.gift = gift
        super.init(nibName: nil, bundle: nil)
        self.modalPresentationStyle = .overFullScreen
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        playerView.contentMode = .scaleAspectFill
        playerView.delegate = self

    }
    
    override func viewWillAppear(_ animated: Bool) {
        svgaParser.parse(with: gift) { videoItem in
            self.playerView.videoItem = videoItem
            self.playerView.startAnimation()
        } failureBlock: {  _ in
            self.dismiss(animated: false) { [weak self] in
                self?.finishedAnimation?()
            }
        }
        super.viewWillAppear(animated)
    }
    
    
    @IBAction func backButtonTapped(_ sender: Any) {
        dismiss(animated: false) { [weak self] in
            self?.onBack?()
        }
        
    }
    
    func svgaPlayerDidFinishedAnimation(_ player: SVGAPlayer!) {
        
        dismiss(animated: false) { [weak self] in
            self?.finishedAnimation?()
        }
    }

}
