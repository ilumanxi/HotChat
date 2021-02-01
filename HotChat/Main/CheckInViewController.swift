//
//  CheckInViewController.swift
//  HotChat
//
//  Created by 风起兮 on 2020/12/7.
//  Copyright © 2020 风起兮. All rights reserved.
//

import UIKit

class CheckInViewController: UIViewController, IndicatorDisplay {
    
    
    @IBOutlet weak var detailTextLabel: UILabel!
    
    @IBOutlet weak var resultTitleLabel: UILabel!
    
    @IBOutlet weak var resultTextLabel: UILabel!
    
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    @IBOutlet weak var checkInButton: UIButton!
    
    
    @IBOutlet weak var checkInView: UIView!
    
    @IBOutlet weak var checkInSucceedView: UIView!
    
    var day: Int = 0
    
    var data: [[CheckIn]] = [] {
        didSet {
            collectionView.reloadData()
        }
    }
    
    let API = Request<CheckInAPI>()
    
    let onCheckInSucceed = Delegate<Void, Void>()
    
    init(day: Int) {
        self.day = day
        super.init(nibName: nil, bundle: nil)
        super.modalTransitionStyle = .crossDissolve
        super.modalPresentationStyle = .overFullScreen
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        
        API.request(.signList, type: Response<[CheckIn]>.self)
            .verifyResponse()
            .subscribe(onSuccess: { [unowned self] response in
                
                let sectionData = response.data!
                let f = sectionData.prefix(3).compactMap{$0}
                let s = sectionData.suffix(4).compactMap{$0}
                
                self.data = [f, s]
                
            }, onError: { error in
                
            })
            .disposed(by: rx.disposeBag)
        
    }
    
    
    func setupViews()  {
        self.detailTextLabel.text = "你已连续签到\(self.day)天"
        collectionView.register(UINib(nibName: "CheckInCell", bundle: nil), forCellWithReuseIdentifier: "CheckInCell")
    }
    
    @IBAction func checkInButtonTapped(_ sender: Any) {
        checkInButton.isEnabled = false
        API.request(.userSignIn, type: Response<CheckInResult>.self)
            .verifyResponse()
            .subscribe(onSuccess: { [weak self] response in
                self?.checkInView.isHidden = true
                
                if let data = response.data {
                    self?.resultTextLabel.text = data.content
                    self?.resultTitleLabel.text = data.isDouble ? "获得加倍签到奖励" : "获得签到奖励"
                }
                self?.checkInSucceedView.isHidden = false
                self?.onCheckInSucceed.call()
            }, onError: { [weak self] error in
                self?.dismiss(animated: false, completion: nil)
                self?.showMessageOnWindow(error)
            })
            .disposed(by: rx.disposeBag)
        
    }
    
    
    @IBAction func doneButtonTapped(_ sender: Any) {
        dismiss(animated: false, completion: nil)
    }
    
    
}


extension CheckInViewController: UICollectionViewDelegateFlowLayout {
    
    
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {

        return insetForSectionAt(section: section)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 60, height: 80)
    }
    
    func insetForSectionAt(section: Int) -> UIEdgeInsets {
        let count = CGFloat(data[section].count)
        
        let activateWidth =  60 * count + 10.0 * (count - 1.0)
        let x = (collectionView.bounds.width - activateWidth) / 2.0
        return UIEdgeInsets(top: 10, left: x, bottom: 0, right: x)
    }
}


extension CheckInViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data[section].count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let model = data[indexPath.section][indexPath.item]
        let cell = collectionView.dequeueReusableCell(for: indexPath, cellType: CheckInCell.self)
        cell.configuration(model)
        return cell
        
    }
}

extension CheckInCell {
    
    func configuration(_ data: CheckIn) {
        checkInImageView.isHidden = !data.status
                
        coinLabel.text = data.energy.description
        dayLabel.text = data.days.description
        backgroundColor = UIColor(hexString: "#F8F8F8")
    }
}
