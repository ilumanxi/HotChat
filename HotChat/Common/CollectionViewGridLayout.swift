//
//  CollectionViewGridLayout.swift
//  TodayNews
//
//  Created by 风起兮 on 2020/6/1.
//  Copyright © 2020 hrscy. All rights reserved.
//

import UIKit


public class CollectionViewGridLayout: UICollectionViewLayout {
    
    /// item元素宽度
    private(set) var itemWidth:CGFloat = 0
    
    public var itemHeight: CGFloat = 0 {
        didSet{
            invalidateLayout()
        }
    }
    
    private var auxiliaryItemHeight: CGFloat {
        
        return itemHeight == 0 ? itemWidth : itemHeight;
    }
    
    /// 每行最大列数
    public var maxColumns:Int = 4 {
        didSet{
            invalidateLayout()
        }
    }
    
    public var sectionInsert: UIEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20) {
        didSet{
            invalidateLayout()
        }
    }
    
    /// 行间隙数
    public var lineIntervals:Int{
        return maxRow - 1
    }
    
    /// 行数
    public var maxRow:Int{
        let maxRow =  maxCount / maxColumns
        return   maxRow > 0 && maxRow < 1 ? 1 : maxRow
    }
    /// 总数量
    public var maxCount:Int {
        return (self.collectionView?.dataSource?.collectionView(self.collectionView!, numberOfItemsInSection: 0))!
    }
    /// item元素间距
    public var itemInterval:CGFloat = 5 {
        didSet{
           invalidateLayout()
        }
    }
    
    public var itemLineInterval:CGFloat = 5 {
        didSet{
           invalidateLayout()
        }
    }
    
    override public func prepare() {
        super.prepare()
        itemWidth = (self.collectionView!.bounds.width - CGFloat(maxColumns - 1) * itemInterval - sectionInsert.left - sectionInsert.right) / CGFloat(maxColumns)
    }
    
    public override var collectionViewContentSize: CGSize {
        let boundHeight = CGFloat(maxRow) * auxiliaryItemHeight + CGFloat(lineIntervals) * itemLineInterval + sectionInsert.top + sectionInsert.bottom
        return CGSize(width: self.collectionView!.bounds.width, height: boundHeight)
    }
    
    override public func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return !collectionView!.bounds.equalTo(newBounds)
    }
    
    
    override public func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let layoutAttributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
        let row = indexPath.item / maxColumns
        let col = indexPath.item % maxColumns
        let x =  CGFloat(col) * itemWidth + CGFloat(col) * itemInterval + sectionInsert.left
        let y =  CGFloat(row) * auxiliaryItemHeight + CGFloat(row) * itemLineInterval + sectionInsert.top
        layoutAttributes.frame = CGRect(x: x, y: y, width: itemWidth, height: auxiliaryItemHeight)
        return layoutAttributes
    }
    
    override public func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var layoutAttributes = [UICollectionViewLayoutAttributes]()
        
        for item in 0..<maxCount{
            layoutAttributes.append(self.layoutAttributesForItem(at: IndexPath(item: item, section: .zero))!)
        }
        return layoutAttributes
    }

}
