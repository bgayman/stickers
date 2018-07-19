//
//  StickersViewController.swift
//  WeWork-Stickers
//
//  Created by B Gay on 7/18/18.
//  Copyright © 2018 B Gay. All rights reserved.
//

import UIKit
import ARKit

// MARK: - StickersViewController -
final class StickersViewController: UIViewController {

    // MARK: - Outlets -
    @IBOutlet weak var collectionView: UICollectionView!

    // MARK: - Properties -
    private lazy var longPressGesture: UILongPressGestureRecognizer = {
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(didLongPress(_:)))
        longPressGesture.minimumPressDuration = 1.0
        return longPressGesture
    }()
    
    // MARK: - Lifecycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
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
        if !ARFaceTrackingConfiguration.isSupported {
            var viewControllers = tabBarController?.viewControllers
            viewControllers?.remove(at: 1)
            tabBarController?.setViewControllers(viewControllers, animated: false)
        }

        navigationItem.largeTitleDisplayMode = .always
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)
        title = "Stickers"
        
        let nib = UINib(nibName: "\(StickerCollectionViewCell.self)", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "\(StickerCollectionViewCell.self)")
        collectionView.addGestureRecognizer(longPressGesture)
    }

    private func showDeleteAlert(from view: UIView, for indexPath: IndexPath) {
        let alertController = UIAlertController(title: "Remove", message: "Remove this sticker?", preferredStyle: .actionSheet)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        let delete = UIAlertAction(title: "Delete", style: .destructive) { (_) in
            UserDefaults.appGroup?.remove(StickerStack.shared.stickers[indexPath.item])
            self.collectionView.reloadItems(at: [indexPath])
        }
        alertController.addAction(cancel)
        alertController.addAction(delete)
        alertController.popoverPresentationController?.sourceView = view
        alertController.popoverPresentationController?.sourceRect = CGRect(x: view.bounds.midX - 5.0, y: view.bounds.maxY - 5, width: 10.0, height: 5)
        alertController.popoverPresentationController?.permittedArrowDirections = [.up]
        alertController.view.tintColor = UIColor.appRed
        present(alertController, animated: true)
    }

    // MARK: - Actions -
    @objc
    private func didLongPress(_ sender: UILongPressGestureRecognizer) {
        let location = sender.location(in: collectionView)
        guard let indexPath = collectionView.indexPathForItem(at: location),
            UserDefaults.appGroup?.date(for: StickerStack.shared.stickers[indexPath.item]) != nil
        else { return }
        showDeleteAlert(from: collectionView.cellForItem(at: indexPath) ?? view, for: indexPath)
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

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let sticker = StickerStack.shared.stickers[indexPath.item]
        guard UserDefaults.appGroup?.date(for: sticker) != nil else { return }
        let stickerDetailVC = StickerDetailViewController(sticker: sticker)
        stickerDetailVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(stickerDetailVC, animated: true)
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
            let indexPaths = addedStickers
            .compactMap { StickerStack.shared.stickers.index(of: $0) }
            .map { IndexPath(item: $0, section: 0) }
            strongSelf.collectionView.reloadItems(at: indexPaths)
        }
    }
}

