//
//  ActivityView.swift
//  HotChat
//
//  Created by 风起兮 on 2021/3/26.
//  Copyright © 2021 风起兮. All rights reserved.
//

import UIKit
import SVGAPlayer
import RxSwift
import RxCocoa

class ActivityView: UIView {

    
    @IBOutlet weak var player: SVGAPlayer!
    
    @IBOutlet weak var acitonButton: UIButton!
    
    
    override func awakeFromNib() {
        
        acitonButton.isUserInteractionEnabled = false
    
        super.awakeFromNib()
        
        let tap = UITapGestureRecognizer()
        addGestureRecognizer(tap)
        
        tap.rx.event
            .subscribe(onNext: { [unowned self ] _ in
                self.onReceive.call(self.activity)
            })
            .disposed(by: rx.disposeBag)
    }
    
    let onReceive = Delegate<Activity, Void>()
    
    
    var activity: Activity! {
        didSet {
            setDisplay()
        }
    }
    
    var disposeObject: DisposeBag?
    
    
    func setDisplay() {
        activity.startCountdown()
        
        if activity.canReceive { // 领奖励
            acitonButton.setTitle("领奖励", for: .normal)
            svgaParser.parse(withNamed: "new_user_receive", in: nil) { videoItem in
                self.player.videoItem = videoItem
                self.player.startAnimation()
            } failureBlock: { error in
                print(error)
            }
            
        }
        else { // 倒计时
            
            
            disposeObject = DisposeBag()
            
            svgaParser.parse(withNamed: "new_user_waiting", in: nil) { videoItem in
                self.player.videoItem = videoItem
                self.player.startAnimation()
            } failureBlock: { error in
                print(error)
            }
            
            activity.timerCountdown
                .map { TimeInterval($0).toDownClock() }
                .bind(to: acitonButton.rx.title(for: .normal))
                .disposed(by:disposeObject!)
            
            
            activity.timerCountdown
                .subscribe(onCompleted: { [weak self]  in
                    self?.acitonButton.setTitle("领奖励", for: .normal)
                    svgaParser.parse(withNamed: "new_user_receive", in: nil) { videoItem in
                        self?.player.videoItem = videoItem
                        self?.player.startAnimation()
                    } failureBlock: { error in
                        print(error)
                    }
                })
                .disposed(by:disposeObject!)
        }
        
    }
    
    
    override var intrinsicContentSize: CGSize {
        
        return CGSize(width: 113, height: 125)
    }

}
