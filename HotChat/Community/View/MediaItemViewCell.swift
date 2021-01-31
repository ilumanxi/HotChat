//
//  MediaItemViewCell.swift
//  HotChat
//
//  Created by 风起兮 on 2021/1/30.
//  Copyright © 2021 风起兮. All rights reserved.
//

import UIKit

class MediaItemViewCell: UICollectionViewCell {

    
    @IBOutlet weak var imageView: UIImageView!
    
    
    @IBOutlet weak var playImageView: UIImageView!
    
    let onDelete = Delegate<MediaItemViewCell, Void>()
    
    
    @IBAction func deleteButtonTapped(_ sender: Any) {
        
        onDelete.call(self)
    }
    
    
    
}
