//
//  StickerCollectionViewController.swift
//  stickerPack
//
//  Created by B Gay on 7/19/18.
//  Copyright © 2018 B Gay. All rights reserved.
//

import UIKit
import Messages

final class StickerCollectionViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        let nib = UINib(nibName: "\(MessageStickerCollectionViewCell.self)", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "\(MessageStickerCollectionViewCell.self)")
    }

}

extension StickerCollectionViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return StickerStack.shared.stickers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "\(MessageStickerCollectionViewCell.self)", for: indexPath) as! MessageStickerCollectionViewCell
        var sticker = StickerStack.shared.stickers[indexPath.item]
        sticker.dateAdded = UserDefaults.appGroup?.date(for: sticker)
        cell.sticker = sticker
        return cell
    }
    
    var height: CGFloat {
        guard collectionView.bounds.width > 500.0 else { return collectionView.bounds.width * 0.5 - 32.0 }
        return 195.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: height, height: height)
    }
}
