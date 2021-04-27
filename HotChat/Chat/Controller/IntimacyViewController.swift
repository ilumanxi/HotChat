//
//  IntimacyViewController.swift
//  HotChat
//
//  Created by 风起兮 on 2021/4/23.
//  Copyright © 2021 风起兮. All rights reserved.
//

import UIKit


class IntimacyViewController: UIViewController, IndicatorDisplay, LoadingStateType {
    
    var state: LoadingState = .initial {
        didSet {
            showOrHideIndicator(loadingState: state)
        }
    }
    
    let tableHeaderView = IntimacyHeaderView.loadFromNib()
    
    @IBOutlet weak var tableView: UITableView!
    
    let onStorage = Delegate<Void, Void>()
    
    let API = Request<IntimacyAPI>()
    
    var data: [IntimacyInfo] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    let userID: String
    init(userID: String) {
        self.userID = userID
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshData()
    }
    
    func refreshData() {
        
        if data.isEmpty {
            state = .refreshingContent
        }
        
        API.request(.intimacyInfo(toUserId: userID), type: Response<[IntimacyInfo]>.self)
            .verifyResponse()
            .subscribe(onSuccess: { [unowned self] response in
                self.data = response.data ?? []
                self.state = self.data.isEmpty ? .noContent : .contentLoaded
            }, onError: { [unowned self] error in
                if self.data.isEmpty {
                    self.state = .error
                }
            })
            .disposed(by: rx.disposeBag)
    }
    
    
    @IBAction func storageButtonTapped(_ sender: Any) {
        onStorage.call()
    }
    
    func setupUI() {
        tableView.tableHeaderView = tableHeaderView
        tableView.backgroundColor = .clear
        tableView.register(UINib(nibName: "IntimacyCell", bundle: nil), forCellReuseIdentifier: "IntimacyCell")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let targetSize = CGSize(width: tableView.frame.width, height: UIView.layoutFittingCompressedSize.height)
        let size = tableHeaderView.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: UILayoutPriority(900), verticalFittingPriority: .fittingSizeLevel)
        tableHeaderView.frame = CGRect(origin: .zero, size: size)
        tableView.tableHeaderView = tableHeaderView
    }
}


extension IntimacyViewController: UITableViewDataSource, UITableViewDelegate {
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return .leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(for: indexPath, cellType: IntimacyCell.self)
        cell.layer.cornerRadius = 10
        cell.clipsToBounds = true
        cell.set(data[indexPath.section])
        return cell
    }
}
