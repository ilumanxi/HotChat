//
//  TalkEarningsViewController.swift
//  HotChat
//
//  Created by 风起兮 on 2020/11/5.
//  Copyright © 2020 风起兮. All rights reserved.
//

import UIKit

class TalkEarningsViewController: UIViewController, LoadingStateType, IndicatorDisplay {
    
    
    var state: LoadingState = .initial
    
    @IBOutlet weak var tableView: UITableView!
    
    let consumerAPI = Request<ConsumerAPI>()
    
    var data: [TalkEarning] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
        refreshData()
    }

    func refreshData() {
        state = .refreshingContent
        consumerAPI.request(.profitImList, type: Response<[TalkEarning]>.self)
            .verifyResponse()
            .subscribe(onSuccess: { [weak self] response in
                self?.data = response.data!
                self?.tableView.reloadData()
                self?.state = .contentLoaded
            }, onError: { [weak self] error in
                self?.state = .error
            })
            .disposed(by: rx.disposeBag)
        
    }
    
    func setupViews() {
        title = "聊天"
        tableView.register(UINib(nibName: "TalkEarningCell", bundle: nil), forCellReuseIdentifier: "TalkEarningCell")
    }
}

extension TalkEarningsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 102
    }
    
}

extension TalkEarningsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(for: indexPath, cellType: TalkEarningCell.self)
        cell.setTalkEarning(data[indexPath.row])
        return cell
    }
    
}

extension TalkEarningCell {
    
    func setTalkEarning(_ talkEarning: TalkEarning) {
        tilteLabel.text = talkEarning.title
        energyLabel.text = "+\(talkEarning.energy)"
        timeLabel.text = talkEarning.time
        timeLabel.isHidden = talkEarning.time.isEmpty
    }
}
