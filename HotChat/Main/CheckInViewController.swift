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
    
    
    @IBOutlet weak var resultTextLabel: UILabel!
    
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    @IBOutlet weak var checkInButton: UIButton!
    
    
    @IBOutlet weak var checkInView: UIView!
    
    @IBOutlet weak var checkInSucceedView: UIView!
    
    var day: Int = 0
    
    var data: [CheckIn] = [] {
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
                self.data = response.data!
                
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
                self?.resultTextLabel.text = response.data?.content
                self?.checkInSucceedView.isHidden = false
                self?.onCheckInSucceed.call()
            }, onError: { [weak self] error in
                self?.dismiss(animated: false, completion: nil)
                self?.showMessageOnWindow(error.localizedDescription)
            })
            .disposed(by: rx.disposeBag)
        
    }
    
    
    @IBAction func doneButtonTapped(_ sender: Any) {
        dismiss(animated: false, completion: nil)
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if touches.first?.view == view {
            dismiss(animated: false, completion: nil)
        }
    }
}


extension CheckInViewController: UICollectionViewDataSource {
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let model = data[indexPath.row]
        let cell = collectionView.dequeueReusableCell(for: indexPath, cellType: CheckInCell.self)
        cell.configuration(model)
        return cell
        
    }
}

extension CheckInCell {
    
    func configuration(_ data: CheckIn) {
        checkInImageView.isHidden = !data.status
        
        let attrString = NSMutableAttributedString(string: data.energy.description)
        
        let attr: [NSAttributedString.Key : Any] = [
            .font: UIFont.systemFont(ofSize: 18, weight: .bold),
            .foregroundColor: UIColor(hexString: "#FFE456"),
            .strokeColor: UIColor(hexString: "#EF9925"),
            .strokeWidth: -6]
        
        attrString.addAttributes(attr, range: NSRange(location: 0, length: attrString.length))
        iconLabel.attributedText = attrString
        dayLabel.text = data.days.description
        textLabel.text = data.title
        backgroundColor = UIColor(hexString: "#F8F8F8")
    }
}
