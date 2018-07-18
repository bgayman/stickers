//
//  StickerCollectionViewCell.swift
//  WeWork-Stickers
//
//  Created by B Gay on 7/18/18.
//  Copyright © 2018 B Gay. All rights reserved.
//

import UIKit

class StickerCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var shadowImageView: UIImageView!
    @IBOutlet weak var stickerImageView: UIImageView!
    
    var sticker: Sticker? {
        didSet {
            shadowImageView.image = sticker?.stickerTemplateImage
            stickerImageView.image = sticker?.dateAdded == nil ? nil : sticker?.stickerImage
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        shadowImageView.tintColor = UIColor.appBeige
    }

}
