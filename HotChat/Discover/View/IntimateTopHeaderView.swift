//
//  IntimateTopHeaderView.swift
//  HotChat
//
//  Created by 风起兮 on 2021/4/25.
//  Copyright © 2021 风起兮. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class IntimateTopHeaderView: UIView {
    
    @IBOutlet weak var top1LeftAvatarView: UIButton!
    @IBOutlet weak var top1RightAvatarView: UIButton!
    @IBOutlet weak var top1TopNameLabel: UILabel!
    @IBOutlet weak var top1BottomNameLabel: UILabel!
    @IBOutlet weak var top1IntimacyButton: UIButton!
    
    @IBOutlet weak var top2LeftAvatarView: UIButton!
    @IBOutlet weak var top2RightAvatarView: UIButton!
    @IBOutlet weak var top2TopNameLabel: UILabel!
    @IBOutlet weak var top2BottomNameLabel: UILabel!
    @IBOutlet weak var top2IntimacyButton: UIButton!
    
    
    @IBOutlet weak var top3LeftAvatarView: UIButton!
    @IBOutlet weak var top3RightAvatarView: UIButton!
    @IBOutlet weak var top3TopNameLabel: UILabel!
    @IBOutlet weak var top3BottomNameLabel: UILabel!
    @IBOutlet weak var top3IntimacyButton: UIButton!
    
    let onNavigation = Delegate<Void, UINavigationController>()
    
    fileprivate var disposeObject:DisposeBag?
    
    func set(_ models: [IntimacyTop]){
        
        self.disposeObject = nil
        
        let disposeBag = DisposeBag()
        
        if models.count > 0 {
            let model = models[0]
            top1LeftAvatarView.kf.setImage(with: URL(string: model.userInfo.headPic), for: .normal)
            top1RightAvatarView.kf.setImage(with: URL(string: model.girlInfo.headPic), for: .normal)
            top1TopNameLabel.text = model.userInfo.nick
            top1BottomNameLabel.text = model.girlInfo.nick
            top1BottomNameLabel.alpha = 1
            let formatter = NumberFormatter()
            let string = formatter.string(from: NSNumber(value: model.userIntimacy))!
            let text = "亲密度\(string)℃"
            top1IntimacyButton.setTitle(text, for: .normal)
            top1IntimacyButton.alpha =  AppAudit.share.rankingListStatus ? 0 : 1
            
           
            
            top1LeftAvatarView.rx.controlEvent(.touchUpInside)
                .subscribe(onNext: { [weak self] _ in
                    self?.pushUser(model.userInfo)
                })
                .disposed(by: disposeBag)
            
            top1RightAvatarView.rx.controlEvent(.touchUpInside)
                .subscribe(onNext: { [weak self] _ in
                    self?.pushUser(model.girlInfo)
                })
                .disposed(by: disposeBag)
        }
        else {
            let image = UIImage(named: "top-avatar")
            
            top1LeftAvatarView.setImage(image, for: .normal)
            top1RightAvatarView.setImage(image, for: .normal)
            top1TopNameLabel.text = "虚位以待"
            top1BottomNameLabel.text = "虚位以待"
            top1BottomNameLabel.alpha = 0
            top1IntimacyButton.setTitle("虚位以待", for: .normal)
            top1IntimacyButton.alpha = 0
        }
        
        if models.count > 1 {
            let model = models[1]
            top2LeftAvatarView.kf.setImage(with: URL(string: model.userInfo.headPic), for: .normal)
            top2RightAvatarView.kf.setImage(with: URL(string: model.girlInfo.headPic), for: .normal)
            top2TopNameLabel.text = model.userInfo.nick
            top2BottomNameLabel.text = model.girlInfo.nick
            top2BottomNameLabel.alpha = 1
            let formatter = NumberFormatter()
            let string = formatter.string(from: NSNumber(value: model.userIntimacy))!
            let text = "亲密度\(string)℃"
            top2IntimacyButton.setTitle(text, for: .normal)
            top2IntimacyButton.alpha = AppAudit.share.rankingListStatus ? 0 : 1
            
            top2LeftAvatarView.rx.controlEvent(.touchUpInside)
                .subscribe(onNext: { [weak self] _ in
                    self?.pushUser(model.userInfo)
                })
                .disposed(by: disposeBag)
            
            top2RightAvatarView.rx.controlEvent(.touchUpInside)
                .subscribe(onNext: { [weak self] _ in
                    self?.pushUser(model.girlInfo)
                })
                .disposed(by: disposeBag)
        }
        else {
            let image = UIImage(named: "top-avatar")
            
            top2LeftAvatarView.setImage(image, for: .normal)
            top2RightAvatarView.setImage(image, for: .normal)
            top2TopNameLabel.text = "虚位以待"
            top2BottomNameLabel.text = "虚位以待"
            top2BottomNameLabel.alpha = 0
            top2IntimacyButton.setTitle("虚位以待", for: .normal)
            top2IntimacyButton.alpha = 0
        }
        
        if models.count > 2 {
            let model = models[2]
            top3LeftAvatarView.kf.setImage(with: URL(string: model.userInfo.headPic), for: .normal)
            top3RightAvatarView.kf.setImage(with: URL(string: model.girlInfo.headPic), for: .normal)
            top3TopNameLabel.text = model.userInfo.nick
            top3BottomNameLabel.text = model.girlInfo.nick
            top3BottomNameLabel.alpha = 1
            let formatter = NumberFormatter()
            let string = formatter.string(from: NSNumber(value: model.userIntimacy))!
            let text = "亲密度\(string)℃"
            top3IntimacyButton.setTitle(text, for: .normal)
            top3IntimacyButton.alpha = AppAudit.share.rankingListStatus ? 0 : 1
            
            top3LeftAvatarView.rx.controlEvent(.touchUpInside)
                .subscribe(onNext: { [weak self] _ in
                    self?.pushUser(model.userInfo)
                })
                .disposed(by: disposeBag)
            
            top3RightAvatarView.rx.controlEvent(.touchUpInside)
                .subscribe(onNext: { [weak self] _ in
                    self?.pushUser(model.girlInfo)
                })
                .disposed(by: disposeBag)
        }
        else {
            let image = UIImage(named: "top-avatar")
            
            top3LeftAvatarView.setImage(image, for: .normal)
            top3RightAvatarView.setImage(image, for: .normal)
            top3TopNameLabel.text = "虚位以待"
            top3BottomNameLabel.text = "虚位以待"
            top3BottomNameLabel.alpha = 0
            top3IntimacyButton.setTitle("虚位以待", for: .normal)
            top3IntimacyButton.alpha = 0
        }
        
        self.disposeObject = disposeBag
        
    }
    
    func pushUser(_ user: User) {
        
        if AppAudit.share.rankingListStatus {
            return
        }
        
        guard let navigationController = onNavigation.call() else { return }
        let vc = UserInfoViewController()
        vc.user = user
        navigationController.pushViewController(vc, animated: true)
    }
    
}
