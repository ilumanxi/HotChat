//
//  AccostViewController.swift
//  HotChat
//
//  Created by 风起兮 on 2021/1/8.
//  Copyright © 2021 风起兮. All rights reserved.
//

import UIKit

class AccostViewController: UIViewController {
    
    
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    init() {
        
        super.init(nibName: nil, bundle: nil)
        super.modalPresentationStyle = .overFullScreen
        super.modalTransitionStyle = .crossDissolve
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
    }


    func setupViews() {
        
        collectionView.allowsSelection = false
        collectionView.register(UINib(nibName: "AccostViewCell", bundle: nil), forCellWithReuseIdentifier: "AccostViewCell")
    }
    
    
    @IBAction func accostButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func closeButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}


extension AccostViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = (collectionView.frame.width - 20) / 3.0
        let height = (collectionView.frame.height - 10) / 2.0
        
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .zero
    }
    
}


extension AccostViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 6
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(for: indexPath, cellType: AccostViewCell.self)
        return cell
    }
    
    
}
