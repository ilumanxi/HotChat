//
//  PairCallViewController.swift
//  HotChat
//
//  Created by 风起兮 on 2021/1/28.
//  Copyright © 2021 风起兮. All rights reserved.
//

import UIKit
import SVGAPlayer

class PairCallViewController: UIViewController {
    
    
    @IBOutlet weak var player: SVGAPlayer!
    
    static let parser = SVGAParser()
    
    let textColor = UIColor(hexString: "#EC4F81")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "缘分匹配"

        navigationItem.leftBarButtonItems =  [UIBarButtonItem(image: UIImage(named: "back-red"), style: .plain, target: self, action: #selector(back))]
        navigationBarAlpha = 0
        navigationBarTitleColor = textColor
        
        PairCallViewController.parser.parse(withNamed: "pair", in: nil) { videoItem in
            self.player.videoItem = videoItem
            self.player.startAnimation()
        } failureBlock: { error in
            print(error)
        }

        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()
    }

    @objc func back() {
        if let navController =  self.presentingViewController as? UINavigationController  {
            if let videoController = navController.viewControllers.first(where: { $0 is VideoCallViewController}) as? VideoCallViewController {
                videoController.hangupClick()
            }

            if let audioController = navController.viewControllers.first(where: { $0 is AudioCallViewController }) as? AudioCallViewController {
                audioController.hangupClick()
            }
        }
        else if let videoController = self.parent?.parent as? VideoCallViewController {
            videoController.hangupClick()
        }
        else if let audioController = self.parent?.parent as? AudioCallViewController {
            audioController.hangupClick()
        }
        else {
            navigationController?.popViewController(animated: true)
        }
    }

}
