//
//  AccostViewController.swift
//  HotChat
//
//  Created by 风起兮 on 2021/1/8.
//  Copyright © 2021 风起兮. All rights reserved.
//

import UIKit
import Kingfisher

class AccostViewController: UIViewController, IndicatorDisplay, LoadingStateType {
  
    @IBOutlet weak var collectionView: UICollectionView!
    
    init() {
        
        super.init(nibName: nil, bundle: nil)
        super.modalPresentationStyle = .overFullScreen
        super.modalTransitionStyle = .crossDissolve
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var state: LoadingState = .initial {
        didSet {
            showOrHideIndicator(loadingState: state, in: collectionView)
        }
    }
    
    let chatGreetAPI = Request<ChatGreetAPI>()
    
    var data: [User] =  []
    var selectedData: [User] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
        refreshData()
    }
    
    func refreshData() {
        state = .refreshingContent
        
        chatGreetAPI.request(.accostList, type: Response<[User]>.self)
            .verifyResponse()
            .subscribe(onSuccess: { [unowned self] response in
                self.data = response.data ?? []
                self.selectedData = self.data
                self.collectionView.reloadData()
                self.state = self.data.isEmpty ? .noContent : .contentLoaded
            }, onError: {  [unowned self] error in
                self.state = .error
            })
            .disposed(by: rx.disposeBag)
    }


    func setupViews() {
        collectionView.register(UINib(nibName: "AccostViewCell", bundle: nil), forCellWithReuseIdentifier: "AccostViewCell")
    }
    
    
    @IBAction func accostButtonTapped(_ sender: UIButton) {
        if selectedData.isEmpty {
            dismiss(animated: true, completion: nil)
            return
        }

        let userIdList = selectedData.compactMap{ $0.userId }
        sender.showLoader()
        chatGreetAPI.request(.userAccost(userIdList: userIdList), type: ResponseEmpty.self)
            .verifyResponse()
            .subscribe(onSuccess: { [unowned self] response in
                sender.hideLoader()
                self.dismiss(animated: true, completion: nil)
                self.showMessageOnWindow(response.msg)
            }, onError: { [unowned self] error in
                sender.hideLoader()
                self.show(error)
            })
            .disposed(by: rx.disposeBag)
    }
    
    
    @IBAction func closeButtonTapped(_ sender: UIButton) {
        
        dismiss(animated: true, completion: nil)
    }
    
}


extension AccostViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = (collectionView.frame.width - 20) / 3.0
        let height = (collectionView.frame.height - 10) / 2.0
        
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let user = data[indexPath.item]
        
        if selectedData.contains(user) {
            selectedData.removeAll { $0 == user }
        }
        else {
            selectedData.append(user)
        }

        collectionView.reloadData()
    }
}


extension AccostViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(for: indexPath, cellType: AccostViewCell.self)
        let user = data[indexPath.item]
        cell.setData(user, isSelected: selectedData.contains(user))
        return cell
    }
}

extension AccostViewCell {
    
    func setData(_ data: User, isSelected: Bool) {
        
        nicknameLabel.text = data.nick
        avatarImageView.kf.setImage(with: URL(string: data.headPic))
        checkBoxView.isHighlighted = isSelected
    }
}
