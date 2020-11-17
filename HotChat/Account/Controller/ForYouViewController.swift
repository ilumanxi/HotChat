//
//  ForYouViewController.swift
//  HotChat
//
//  Created by 风起兮 on 2020/10/21.
//  Copyright © 2020 风起兮. All rights reserved.
//

import UIKit
import MagazineLayout

class ForYouViewController: UIViewController, StoryboardCreate, LoadingStateType, IndicatorDisplay {
    
    var state: LoadingState = .initial
    
    static var storyboardNamed: String { return "Account" }
    
    let sectionInset = UIEdgeInsets(top: 15, left: 16, bottom: 1, right: 16)
    
    let horizontalSpacing: CGFloat = 10
    
    let verticalSpacing: CGFloat = 10
    
    let itemsPerRow: CGFloat = 3
    
    private var itemSize: CGSize {
        let itemSize = (UIScreen.main.bounds.width - (sectionInset.left + sectionInset.right) - (itemsPerRow - 1) * horizontalSpacing) / itemsPerRow
        return CGSize(width: itemSize, height: itemSize)
    }
    
    let layout = MagazineLayout()
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.setCollectionViewLayout(layout, animated: true)
        }
    }
    
    var data: [User] = [] {
        didSet {
            collectionView.reloadData()
        }
    }
    
    var selectedData: [User] = []
    
    let accountAPI = Request<AccountAPI>()
    
    let userAPI = Request<UserAPI>()
    
    var sex: Sex = .male
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.hidesBackButton = true
        title = "为你推荐"

        if sex == .male {
            titleLabel.text = "你想遇上什么样的女生"
        }
        else {
            titleLabel.text = "快速与土豪哥哥关注吧"
        }
        
        refreshData()
    }
    
    func refreshData() {
        
        state = (state == .initial) ? .loadingContent : .refreshingContent
        accountAPI.request(.recommendList, type: Response<[User]>.self)
            .verifyResponse()
            .subscribe(onSuccess: { [weak self] response in
                self?.data = response.data ?? []
                self?.state = .contentLoaded
                
            }, onError: { [weak self] _  in
                self?.state = .error
            })
            .disposed(by: rx.disposeBag)
    }
    
    
    @IBAction func followButtonTapped(_ sender: Any) {
        
        let followList = selectedData.compactMap{ ["userId" : $0.userId] }
        
        if followList.isEmpty {
            UIApplication.shared.keyWindow?.setMainViewController()
        }
        else {
            userAPI.request(.batchFollow(followList: followList), type: ResponseEmpty.self)
                .verifyResponse()
                .subscribe(onSuccess: { _ in
                    UIApplication.shared.keyWindow?.setMainViewController()
                }, onError: { _ in
                    UIApplication.shared.keyWindow?.setMainViewController()
                })
                .disposed(by: rx.disposeBag)
        }
        
    }
    
}

extension ForYouViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let user = data[indexPath.item]
        
        if let index =  selectedData.firstIndex(where: { $0.userId == user.userId }) {
            selectedData.remove(at: index)
        }
        else {
            selectedData.append(user)
        }
        collectionView.reloadData()
    }
}

extension ForYouViewController: UICollectionViewDataSource {
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let user = data[indexPath.item]
        
        let cell = collectionView.dequeueReusableCell(for: indexPath, cellType: ForYouCell.self)
        cell.layer.cornerRadius = 8
        cell.avatarImageView.kf.setImage(with: URL(string: user.headPic))
        cell.boxImageView.isHighlighted = selectedData.contains{ $0.userId == user.userId }
        
        return cell
    }
    
}




// MARK: UICollectionViewDelegateMagazineLayout

extension ForYouViewController: UICollectionViewDelegateMagazineLayout {

 func collectionView(
   _ collectionView: UICollectionView,
   layout collectionViewLayout: UICollectionViewLayout,
   sizeModeForItemAt indexPath: IndexPath)
   -> MagazineLayoutItemSizeMode
 {
   return MagazineLayoutItemSizeMode(widthMode: .thirdWidth, heightMode: .static(height: itemSize.height))
//    return MagazineLayoutItemSizeMode(widthMode: .thirdWidth, heightMode: .dynamic)
 }

 func collectionView(
   _ collectionView: UICollectionView,
   layout collectionViewLayout: UICollectionViewLayout,
   visibilityModeForHeaderInSectionAtIndex index: Int)
   -> MagazineLayoutHeaderVisibilityMode
 {
   return .hidden
 }

 func collectionView(
   _ collectionView: UICollectionView,
   layout collectionViewLayout: UICollectionViewLayout,
   visibilityModeForFooterInSectionAtIndex index: Int)
   -> MagazineLayoutFooterVisibilityMode
 {
   return .hidden
 }

 func collectionView(
   _ collectionView: UICollectionView,
   layout collectionViewLayout: UICollectionViewLayout,
   visibilityModeForBackgroundInSectionAtIndex index: Int)
   -> MagazineLayoutBackgroundVisibilityMode
 {
   return .hidden
 }

 func collectionView(
   _ collectionView: UICollectionView,
   layout collectionViewLayout: UICollectionViewLayout,
   horizontalSpacingForItemsInSectionAtIndex index: Int)
   -> CGFloat
 {
   return horizontalSpacing
 }

 func collectionView(
   _ collectionView: UICollectionView,
   layout collectionViewLayout: UICollectionViewLayout,
   verticalSpacingForElementsInSectionAtIndex index: Int)
   -> CGFloat
 {
   return verticalSpacing
 }

 func collectionView(
   _ collectionView: UICollectionView,
   layout collectionViewLayout: UICollectionViewLayout,
   insetsForSectionAtIndex index: Int)
   -> UIEdgeInsets
 {
   return sectionInset
 }

 func collectionView(
   _ collectionView: UICollectionView,
   layout collectionViewLayout: UICollectionViewLayout,
   insetsForItemsInSectionAtIndex index: Int)
   -> UIEdgeInsets
 {
   return .zero
 }

 func collectionView(
   _ collectionView: UICollectionView,
   layout collectionViewLayout: UICollectionViewLayout,
   finalLayoutAttributesForRemovedItemAt indexPath: IndexPath,
   byModifying finalLayoutAttributes: UICollectionViewLayoutAttributes)
 {
   // Fade and drop out
   finalLayoutAttributes.alpha = 0
   finalLayoutAttributes.transform = .init(scaleX: 0.2, y: 0.2)
 }

}

