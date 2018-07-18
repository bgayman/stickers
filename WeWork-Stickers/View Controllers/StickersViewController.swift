//
//  StickersViewController.swift
//  WeWork-Stickers
//
//  Created by B Gay on 7/18/18.
//  Copyright © 2018 B Gay. All rights reserved.
//

import UIKit

// MARK: - StickersViewController -
final class StickersViewController: UIViewController {

    // MARK: - Properties -
    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: - Lifecycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let stickerScannerViewController = segue.destination as? StickerScannerViewController {
            stickerScannerViewController.delegate = self
        }
    }
    
    // MARK: - Setup -
    private func setupUI() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.tintColor = UIColor.appRed

        tabBarController?.tabBar.tintColor = UIColor.appRed

        navigationItem.largeTitleDisplayMode = .always
        
        title = "Stickers"
        
        let nib = UINib(nibName: "\(StickerCollectionViewCell.self)", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "\(StickerCollectionViewCell.self)")
    }

}

extension StickersViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return StickerStack.shared.stickers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "\(StickerCollectionViewCell.self)", for: indexPath) as! StickerCollectionViewCell
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

extension StickersViewController: StickerScannerViewControllerDelegate {

    func stickerScannerViewController(_ viewController: StickerScannerViewController, didPressCloseWith addedStickers: [Sticker]) {
        viewController.dismiss(animated: true) { [weak self] in
            guard let strongSelf = self else {
                return
            }
            let cells = strongSelf.collectionView.visibleCells.compactMap { $0 as? StickerCollectionViewCell }.filter {
                guard let sticker = $0.sticker else { return false }
                return addedStickers.contains(sticker)
            }
            cells.forEach { $0.stickerImageView.transform = CGAffineTransform(scaleX: 0.6, y: 0.6) }
            UIView.animate(withDuration: 0.6, delay: 0.0, usingSpringWithDamping: 0.3, initialSpringVelocity: 0.0, options: [], animations: {
                cells.forEach {
                    $0.stickerImageView.image = $0.sticker?.stickerImage
                    $0.transform = .identity
                }
            })
        }
    }
}

