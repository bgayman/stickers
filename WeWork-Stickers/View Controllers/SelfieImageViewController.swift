//
//  SelfieImageViewController.swift
//  WeWork-Stickers
//
//  Created by B Gay on 7/19/18.
//  Copyright © 2018 B Gay. All rights reserved.
//

import UIKit

class SelfieImageViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var closeVisualEffectView: UIVisualEffectView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var shareVisualEffectView: UIVisualEffectView!
    @IBOutlet weak var shareButton: UIButton!
    
    var image: UIImage?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        closeVisualEffectView.layer.cornerRadius = closeVisualEffectView.bounds.height * 0.5
        closeVisualEffectView.layer.masksToBounds = true
        closeButton.tintColor = UIColor.appRed
        
        shareVisualEffectView.layer.cornerRadius = closeVisualEffectView.bounds.height * 0.5
        shareVisualEffectView.layer.masksToBounds = true
        shareButton.tintColor = UIColor.appRed
        
        imageView.image = image
    }
    
    
    @IBAction func didPressClose(_ sender: UIButton) {
        dismiss(animated: true)
        
    }
    
    @IBAction func didPressShare(_ sender: UIButton) {
        guard
            let image = self.image,
            let data = image.pngData()
        else { return }
        let activityController = UIActivityViewController(activityItems: [data as Any], applicationActivities: nil)
        activityController.popoverPresentationController?.sourceView = sender
        activityController.popoverPresentationController?.sourceRect = sender.bounds
        present(activityController, animated: true)
    }
    
    
}
