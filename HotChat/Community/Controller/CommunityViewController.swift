//
//  CommunityViewController.swift
//  HotChat
//
//  Created by 风起兮 on 2020/9/9.
//  Copyright © 2020 风起兮. All rights reserved.
//

import UIKit
import HBDNavigationBar
import SegementSlide
import RxCocoa
import RxSwift
import NSObject_Rx
import Reusable
import Blueprints
import Kingfisher
    
class CommunityViewController: UIViewController {
    
    let dynamicAPI = Request<DynamicAPI>()
    
    var dynamics: [Dynamic] = [] {
        didSet {
            collectionView.reloadData()
        }
    }
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.backgroundColor = UIColor.groupTableViewBackground
        
        configureVerticalLayout()
        
        
        dynamicAPI.request(.recommendList, type: Response<Pagination<Dynamic>>.self)
            .subscribe(onSuccess: { [weak self] response in
                self?.dynamics = response.data?.list ?? []
                Log.print(response)
                
            }, onError: { error in
                Log.print(error)
            })
            .disposed(by: rx.disposeBag)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let cell = sender as? UICollectionViewCell, let indexPath = collectionView.indexPath(for: cell) else {
            return
        }
        
        if let vc = segue.destination as? DynamicDetailViewController {
            
            vc.user = dynamics[indexPath.item].userInfo
        }
        
    }
    
    let layoutCellIdentifier = "DynamicViewCell"
}


extension CommunityViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    var itemsPerRow: CGFloat {
        return 2
    }
    
    var minimumInteritemSpacing: CGFloat {
        return 10
    }
    
    var minimumLineSpacing: CGFloat {
        return 10
    }
    
    var sectionInsets: UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 10, bottom: 60, right: 10)
    }
    
    func configureVerticalLayout() {
        let verticalBlueprintLayout = VerticalBlueprintLayout(
          itemsPerRow: itemsPerRow,
          height: 100,
          minimumInteritemSpacing: minimumInteritemSpacing,
          minimumLineSpacing: minimumLineSpacing,
          sectionInset: sectionInsets,
          stickyHeaders: false,
          stickyFooters: false
        )

        UIView.animate(withDuration: 0.5) { [weak self] in
            self?.collectionView.collectionViewLayout = verticalBlueprintLayout
            self?.view.setNeedsLayout()
            self?.view.layoutIfNeeded()
        }
    }
    
    func layoutCellCalculatedSize(forItemAt indexPath: IndexPath) -> CGSize {
        
        guard let layoutCellForSize = collectionView.dequeueReusableCell(withReuseIdentifier: layoutCellIdentifier, for: indexPath) as? DynamicViewCell else {
            fatalError("Failed to load Xib from bundle named: \(layoutCellIdentifier)")
        }
        let data =  dynamics[indexPath.item]
        layoutCellForSize.textLabel.text = data.content
        layoutCellForSize.setNeedsLayout()
        layoutCellForSize.layoutIfNeeded()
        let cellWidth = widthForCellInCurrentLayout()
        let cellHeight: CGFloat = 0
        let cellTargetSize = CGSize(width: cellWidth, height: cellHeight)
        let cellSize = layoutCellForSize.contentView.systemLayoutSizeFitting(
            cellTargetSize,
            withHorizontalFittingPriority: UILayoutPriority(900),
            verticalFittingPriority: .fittingSizeLevel)
        return cellSize
    }

    func widthForCellInCurrentLayout() -> CGFloat {
        var cellWidth = collectionView.frame.size.width - (sectionInsets.left + sectionInsets.right)
        if itemsPerRow > 1 {
            cellWidth -= minimumInteritemSpacing * (itemsPerRow - 1)
        }
        return floor(cellWidth / itemsPerRow)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dynamics.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: layoutCellIdentifier, for: indexPath) as? DynamicViewCell else {
            fatalError("Failed to load Xib from bundle named: \(layoutCellIdentifier)")
        }
        
        let data =  dynamics[indexPath.item]
        
        cell.textLabel.text = data.content
        cell.imageView.kf.setImage(with: URL(string: data.coverUrl))
        cell.nicknameLabel.text = data.userInfo.nick
        cell.profileImageView.kf.setImage(with: URL(string: data.userInfo.headPic))
        cell.likeLabel.text = data.zanNum.description
        cell.likeButton.isSelected = data.isSelfZan
        cell.layer.cornerRadius = 8
        
        cell.onLikeClicked.delegate(on: self) { (self, _) in
            self.like(data)
        }
        
        return cell
    }
    

    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return layoutCellCalculatedSize(forItemAt: indexPath)
    }
    
    func like(_ dynamic: Dynamic)  {
        
        dynamicAPI.request(.zan(dynamic.dynamicId), type: Response<[String : Any]>.self)
            .subscribe(onSuccess: {[weak self] response in
               
                guard let index = self?.dynamics.lastIndex(where: { $0.dynamicId == dynamic.dynamicId }),
                      let zanNum = response.data?["zanNum"] as? Int,
                      let isSelfZan = response.data?["type"] as? Bool else {
                    return
                }
                
                self?.dynamics.modifyElement(at: index, { element in
                    element.zanNum = zanNum
                    element.isSelfZan = isSelfZan
                })
                self?.collectionView.reloadData()
                
                Log.print(response)
            }, onError: { error in
                Log.print(error)
            })
            .disposed(by: rx.disposeBag)
        
    }
    
}
