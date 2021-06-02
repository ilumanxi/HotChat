//
//  WalletProductViewCell.swift
//  HotChat
//
//  Created by 风起兮 on 2020/9/29.
//  Copyright © 2020 风起兮. All rights reserved.
//

import UIKit
import MagazineLayout

class WalletProductViewCell: UITableViewCell {
    
    let layout = MagazineLayout()
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var rechargeLabel: UILabel!
    
    @IBOutlet weak var serviceLabel: UILabel!
    
    let onSelectedIndexPath = Delegate<IndexPath, Void>()
    
    var products: [ItemProduct] = [] {
        didSet {
            collectionView.reloadData()
        }
    }
    
    override func awakeFromNib() {
        collectionView.setCollectionViewLayout(layout, animated: false)
        collectionView.register(UINib(nibName: "WalletProducItemCell", bundle: nil), forCellWithReuseIdentifier: "WalletProducItemCell")
        
        super.awakeFromNib()
    }
    
}

extension WalletProductViewCell: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        onSelectedIndexPath.call(indexPath)
    }
}

extension WalletProductViewCell: UICollectionViewDataSource {
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(for: indexPath, cellType: WalletProducItemCell.self)
        cell.item = products[indexPath.item]
        return cell
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return products.count
    }
}


// MARK: UICollectionViewDelegateMagazineLayout

extension WalletProductViewCell: UICollectionViewDelegateMagazineLayout {

 func collectionView(
   _ collectionView: UICollectionView,
   layout collectionViewLayout: UICollectionViewLayout,
   sizeModeForItemAt indexPath: IndexPath)
   -> MagazineLayoutItemSizeMode
 {
   return MagazineLayoutItemSizeMode(widthMode: .halfWidth, heightMode: .static(height: 92))
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
   return 10
 }

 func collectionView(
   _ collectionView: UICollectionView,
   layout collectionViewLayout: UICollectionViewLayout,
   verticalSpacingForElementsInSectionAtIndex index: Int)
   -> CGFloat
 {
   return 10
 }

 func collectionView(
   _ collectionView: UICollectionView,
   layout collectionViewLayout: UICollectionViewLayout,
   insetsForSectionAtIndex index: Int)
   -> UIEdgeInsets
 {
    return UIEdgeInsets(top: 1, left: 1, bottom: 1, right: 1)
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
