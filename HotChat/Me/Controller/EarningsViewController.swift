//
//  EarningsViewController.swift
//  HotChat
//
//  Created by 风起兮 on 2020/11/5.
//  Copyright © 2020 风起兮. All rights reserved.
//

import UIKit
import SnapKit


enum EarningType: Int, CaseIterable {
    case today = 1
    case currentMonth = 2
    case lastMonth = 3
}


struct EarningMonthFormEntry: FormEntry {
    
    
    let current: EarningMonth
    let last: EarningMonth
    
    init(current: EarningMonth, last: EarningMonth) {
        self.current = current
        self.last = last
    }
    
    func cell(_ tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(for: indexPath, cellType: EarningCell.self)
        cell.currentMonthEnergyLabel.text = current.energy
        
        cell.lastMonthEnergyLabel.text = last.energy

        
        return cell
    }
    

}

struct EarningWeekFormEntry: FormEntry {

    let week: EarningWeek
    
    init(week: EarningWeek) {
        self.week = week
    }
    
    func cell(_ tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(for: indexPath, cellType: EarningDetailCell.self)
        
        cell.titleLabel.text = week.title
        
        for (i, stackView) in cell.containerStackView.subviews.enumerated()  where stackView is UIStackView {
            
            let model = week.list[i]
            let energyLabel = stackView.subviews.first as? UILabel
            energyLabel?.text = model.energy
            
            let titleLabel = stackView.subviews.last as? UILabel
            titleLabel?.text = model.title
        }
        
        return cell
    }
}

class EarningsViewController: UIViewController, LoadingStateType, IndicatorDisplay {
    
    
    var state: LoadingState = .initial {
        didSet {
            showOrHideIndicator(loadingState: state)
        }
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    let consumerAPI = Request<ConsumerAPI>()
    
    private var sections: [FormSection] = []
    
    private var data: EarningPreview!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        refreshData()
    }
    
    func setupViews()  {
        title = "我的收益"
        
        let recordItem = UIBarButtonItem(title: "明细", style: .plain, target: self, action: #selector(pushExpensesRecord))
        navigationItem.rightBarButtonItem = recordItem
        
        tableView.register(UINib(nibName: "EarningCell", bundle: nil), forCellReuseIdentifier: "EarningCell")
        tableView.register(UINib(nibName: "EarningDetailCell", bundle: nil), forCellReuseIdentifier: "EarningDetailCell")
    }
    
    
    func setupSections()  {

        guard let data = data else { return }
        
       let month = EarningMonthFormEntry(current: data.currentMonth, last: data.lastMonth)
        
     
       let weeks =  data.weekList
            .compactMap {
                EarningWeekFormEntry(week: $0)
            }
        
        let entries: [FormEntry] = [month] + weeks
        
        let section =  FormSection(entries: entries)
        
        self.sections = [section]
        
        tableView.reloadData()
    }
    
    func refreshData() {
        
        state = .refreshingContent
        consumerAPI.request(.countProfit, type: Response<EarningPreview>.self)
           .verifyResponse()
            .subscribe(onSuccess: { [weak self] response in
                self?.data  = response.data
                self?.setupSections()
                self?.state = .contentLoaded
                
            }, onError: { error in
                self.state = .error
            })
            .disposed(by: rx.disposeBag)
    }
    
    @objc private func pushExpensesRecord() {
        let vc = ConsumptionListController(type: .earnings)
        navigationController?.pushViewController(vc, animated: true)
    }

}

extension EarningsViewController: UITableViewDelegate {
    
    
}


extension EarningsViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return sections[section].formEntries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        return sections[indexPath.section].formEntries[indexPath.row].cell(tableView, indexPath: indexPath)
    }
    
    
    
}
