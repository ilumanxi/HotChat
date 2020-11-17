//
//  EarningsDetailViewController.swift
//  HotChat
//
//  Created by 风起兮 on 2020/11/10.
//  Copyright © 2020 风起兮. All rights reserved.
//

import UIKit

class EarningsDetailViewController: UIViewController, LoadingStateType, IndicatorDisplay {
    
    
    var state: LoadingState = .initial {
        didSet {
            if isViewLoaded {
                showOrHideIndicator(loadingState: state)
            }
        }
    }
    
    
    let type: EarningType
    
    init(type: EarningType) {
        self.type = type
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let consumerAPI = Request<ConsumerAPI>()
    
    @IBOutlet weak var giftLabel: UILabel!
    
    @IBOutlet weak var imLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        refreshData()
    }
    
    
    @IBAction func pusGiftEarnings(_ sender: Any) {
        
        let vc = GiftEarningsViewController()
        navigationController?.pushViewController(vc, animated: true)
    }

    @IBAction func pusTalkEarnings(_ sender: Any) {
        
        let vc = TalkEarningsViewController()
        navigationController?.pushViewController(vc, animated: true)
    }

    func refreshData() {
        
        state = .refreshingContent
        
        consumerAPI.request(.countProfit(tag: type.rawValue), type: Response<[Earning]>.self)
            .verifyResponse()
            .subscribe(onSuccess: { [weak self] response in
                let gift = response.data?.first(where: { $0.type == 1 })
                
                let talk = response.data?.first(where: { $0.type == 2 })
                
                self?.giftLabel.text = gift?.energy.description
                self?.imLabel.text = talk?.energy.description
                self?.state = .contentLoaded
            }, onError: { [weak self] error in
                self?.state = .error
            })
            .disposed(by: rx.disposeBag)
    }
    

}
