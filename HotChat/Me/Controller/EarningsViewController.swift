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
    let balance: EarningMonth
    
    init(current: EarningMonth, last: EarningMonth, balance: EarningMonth) {
        self.current = current
        self.last = last
        self.balance = balance
    }
    
    func cell(_ tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(for: indexPath, cellType: EarningCell.self)
        cell.currentMonthEnergyLabel.text = current.energy
        
        cell.lastMonthEnergyLabel.text = last.energy
        cell.balanceEnergyLabel.text = balance.energy
        
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
//        applyImageBackgroundToTheNavigationBar()
    }
    
    /// Configures the navigation bar to use an image as its background.
    func applyImageBackgroundToTheNavigationBar() {
   
        guard let bounds = navigationController?.navigationBar.bounds else { return }
        
        var backImageForDefaultBarMetrics =
            UIImage.gradientImage(bounds: bounds,
                                  colors: [UIColor(hexString: "#0BB7DC").cgColor, UIColor(hexString: "#5159F8").cgColor])
        var backImageForLandscapePhoneBarMetrics =
            UIImage.gradientImage(bounds: bounds,
                                  colors: [UIColor(hexString: "#0BB7DC").cgColor, UIColor(hexString: "#5159F8").cgColor])
        
        /** Both of the above images are smaller than the navigation bar's size.
            To enable the images to resize gracefully while keeping their content pinned to the bottom right corner of the bar, the images are
            converted into resizable images width edge insets extending from the bottom up to the second row of pixels from the top, and from the
            right over to the second column of pixels from the left. This results in the topmost and leftmost pixels being stretched when the images
            are resized. Not coincidentally, the pixels in these rows/columns are empty.
         */
        backImageForDefaultBarMetrics =
            backImageForDefaultBarMetrics.resizableImage(
                withCapInsets: UIEdgeInsets(top: 0,
                                            left: 0,
                                            bottom: backImageForDefaultBarMetrics.size.height - 1,
                                            right: backImageForDefaultBarMetrics.size.width - 1))
        backImageForLandscapePhoneBarMetrics =
            backImageForLandscapePhoneBarMetrics.resizableImage(
                withCapInsets: UIEdgeInsets(top: 0,
                                            left: 0,
                                            bottom: backImageForLandscapePhoneBarMetrics.size.height - 1,
                                            right: backImageForLandscapePhoneBarMetrics.size.width - 1))
        
        /** Use the appearance proxy to customize the appearance of UIKit elements. However changes made to an element's appearance
            proxy do not affect any existing instances of that element currently in the view hierarchy. Normally this is not an issue because you
            will likely be performing your appearance customizations in -application:didFinishLaunchingWithOptions:.
            However, this example allows you to toggle between appearances at runtime which necessitates applying appearance customizations
            directly to the navigation bar.
        */
        
        // Uncomment this line to use the appearance proxy to customize the appearance of UIKit elements.
        // let navigationBarAppearance =
        //      UINavigationBar.appearance(whenContainedInInstancesOf: [UINavigationController.self])

        /** The bar metrics associated with a background image determine when it is used.
            Use the background image associated with the Default bar metrics when a more suitable background image can't be found.
         
            The shorter variant of the navigation bar, that is used on iPhone when in landscape, uses the background image associated
            with the LandscapePhone bar metrics.
         */

        let navigationBarAppearance = self.navigationController!.navigationBar
        navigationBarAppearance.setBackgroundImage(backImageForDefaultBarMetrics, for: .default)
        navigationBarAppearance.setBackgroundImage(backImageForLandscapePhoneBarMetrics, for: .compact)
    }
    
    func setupViews()  {
        title = "我的收益"
        
        
        let recordItem = UIBarButtonItem(title: "明细", style: .plain, target: self, action: #selector(pushExpensesRecord))
        recordItem.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .normal)
        navigationItem.rightBarButtonItem = recordItem
        navigationBarAlpha = 0
        navigationBarTintColor = .white
        navigationBarTitleColor = .white
        
        tableView.sectionHeaderHeight = 10
        tableView.sectionFooterHeight = .leastNonzeroMagnitude
        tableView.register(UINib(nibName: "EarningCell", bundle: nil), forCellReuseIdentifier: "EarningCell")
        tableView.register(UINib(nibName: "EarningDetailCell", bundle: nil), forCellReuseIdentifier: "EarningDetailCell")
    }
    
    
    func setupSections()  {

        guard let data = data else { return }
        
        let month = EarningMonthFormEntry(current: data.currentMonth, last: data.lastMonth, balance: data.balanceEnergy)
        
     
       let weeks =  data.weekList
            .compactMap {
                EarningWeekFormEntry(week: $0)
            }
        
        let entries: [FormEntry] = [month] + weeks
        
        self.sections = entries.compactMap {
            FormSection(entries: [$0])
        }
        
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
        
        let cell = sections[indexPath.section].formEntries[indexPath.row].cell(tableView, indexPath: indexPath)
        
        if let insetGroupedCell = cell as? InsetGroupedCell {
            insetGroupedCell.rectCorner = .allCorners
        }
        
        return cell
    }
    
    
    
}
