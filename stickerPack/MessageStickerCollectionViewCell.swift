//
//  MessageStickerCollectionViewCell.swift
//  stickerPack
//
//  Created by B Gay on 7/19/18.
//  Copyright © 2018 B Gay. All rights reserved.
//

import UIKit
import Messages

class MessageStickerCollectionViewCell: UICollectionViewCell {

    var stickerView: MSStickerView!
    @IBOutlet weak var templateImageView: UIImageView!
    
    var sticker: Sticker? {
        didSet {
            guard let stickerPath = Bundle.main.path(forResource: "\(sticker?.imageName ?? "")Sticker", ofType: "png") else {
                print("No sticker path")
                return
            }
            let stickerURL = URL(fileURLWithPath: stickerPath)
            templateImageView.image = sticker?.stickerTemplateImage
            do {
                stickerView.sticker = sticker?.dateAdded == nil ? nil : try MSSticker(contentsOfFileURL: stickerURL, localizedDescription: sticker?.title ?? "")
            } catch {
                print(error)
            }
            
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let stickerView = MSStickerView()
        stickerView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stickerView)
        stickerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20.0).isActive = true
        stickerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20.0).isActive = true
        stickerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20.0).isActive = true
        stickerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20.0).isActive = true
        self.stickerView = stickerView
        templateImageView.tintColor = UIColor.appBeige
    }

}
