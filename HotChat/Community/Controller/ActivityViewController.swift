//
//  ActivityViewController.swift
//  HotChat
//
//  Created by 风起兮 on 2021/3/26.
//  Copyright © 2021 风起兮. All rights reserved.
//

import UIKit

class ActivityViewController: UIViewController {
    
    
    @IBOutlet weak var coinButton: UIButton!
    
    @IBOutlet weak var energyButton: UIButton!
    
    
    @IBOutlet weak var countdownLabel: UILabel!
    
    @IBOutlet weak var doneButton: UIButton!
    
    let onDone = Delegate<Void, Void>()
    
    
    let activity: Activity
    init(activity: Activity) {
        self.activity = activity
        super.init(nibName: nil, bundle: nil)
        super.modalTransitionStyle = .crossDissolve
        super.modalPresentationStyle = .overFullScreen
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let API = Request<UserActivityAPI>()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        coinButton.setTitle("\(activity.tanbi)T币", for: .normal)
        energyButton.setTitle("\(activity.energy)能量值", for: .normal)
        
        setDisplay()
        
        activity.timerCountdown
            .subscribe(onNext: { [unowned self] second in
                self.countdownLabel.text = "{下次奖励倒计时\( TimeInterval(second).toDownClock())}"
                
            },  onCompleted: { [weak self] in
                self?.setDisplay()
            })
            .disposed(by: rx.disposeBag)

    }
    
    func setDisplay() {
        if activity.canReceive {
            countdownLabel.isHidden = true
            doneButton.isHidden = false
        }
        else {
            countdownLabel.isHidden = false
            doneButton.isHidden = true
        }
    }

    
    @IBAction func doneButtonTapped(_ sender: Any) {
        doneButton.isUserInteractionEnabled = false
        API.request(.receiveReward, type: Response<Activity>.self)
            .verifyResponse()
            .subscribe(onSuccess: { [weak self] response in
                self?.doneButton.isUserInteractionEnabled = true
                if response.data?.isSuccessd ?? false {
                    self?.onDone.call()
                }
                else {
                    
                }
            }, onError: { [weak self] error in
                self?.doneButton.isUserInteractionEnabled = false
            })
            .disposed(by: rx.disposeBag)
    }
    

    @IBAction func closeButtonTapped(_ sender: Any) {
        
        dismiss(animated: true, completion: nil)
    }
    

}
