//
//  ViewController.swift
//  WeWork-Stickers
//
//  Created by B Gay on 7/14/18.
//  Copyright © 2018 B Gay. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

// MARK: - ARImageGroupName -
struct ARImageGroupName {
    static let stickers = "Stickers"
}

protocol StickerScannerViewControllerDelegate: AnyObject {
    func stickerScannerViewController(_ viewController: StickerScannerViewController, didPressCloseWith addedStickers: [Sticker])
}

// MARK: - StickerScannerViewController -
final class StickerScannerViewController: UIViewController {

    // MARK: - Outlets -
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var closeButtonVisualEffectView: UIVisualEffectView!
    @IBOutlet weak var refreshButton: UIButton!
    @IBOutlet weak var refreshVisualEffectView: UIVisualEffectView!
    @IBOutlet weak var infoVisualEffectView: UIVisualEffectView!
    @IBOutlet weak var infoStackView: UIStackView!
    @IBOutlet weak var infoImageView: UIImageView!
    @IBOutlet weak var infoTitleLabel: UILabel!
    @IBOutlet weak var infoDescriptionLabel: UILabel!
    
    // MARK: - Properties -
    weak var delegate: StickerScannerViewControllerDelegate?
    private var addedStickers = [Sticker]()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        sceneView.delegate = self
        
        let scene = SCNScene()
        
        sceneView.scene = scene
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARImageTrackingConfiguration()
        
        guard let trackingImages = ARReferenceImage.referenceImages(inGroupNamed: ARImageGroupName.stickers, bundle: Bundle.main) else {
            fatalError("No refrence images in bundle")
        }

        configuration.trackingImages = trackingImages
        configuration.maximumNumberOfTrackedImages = trackingImages.count
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    // MARK: - Private Methods -
    private func setupUI() {
        closeButton.tintColor = UIColor.appRed
        closeButton.addTarget(self, action: #selector(didPressClose(_:)), for: .touchUpInside)
        closeButtonVisualEffectView.layer.cornerRadius = closeButtonVisualEffectView.bounds.height * 0.5
        closeButtonVisualEffectView.layer.masksToBounds = true

        refreshButton.tintColor = UIColor.appRed
        refreshButton.addTarget(self, action: #selector(didPressRefresh(_:)), for: .touchUpInside)
        refreshVisualEffectView.layer.cornerRadius = refreshVisualEffectView.bounds.height * 0.5
        refreshVisualEffectView.layer.masksToBounds = true

        infoVisualEffectView.layer.cornerRadius = 20.0
        infoVisualEffectView.layer.masksToBounds = true

        infoImageView.isHidden = true
        infoTitleLabel.isHidden = true

        infoTitleLabel.font = UIFont.appFont(textStyle: .title3, weight: .heavy)
        infoTitleLabel.textColor = UIColor.black.withAlphaComponent(0.8)
        infoDescriptionLabel.font = UIFont.appFont(textStyle: .body, weight: .medium)
        infoDescriptionLabel.textAlignment = .center
        infoDescriptionLabel.text = "Scan sticker to add."
        infoDescriptionLabel.textColor = UIColor.black.withAlphaComponent(0.7)

        perform(#selector(dismissInfo(completion:)), with: nil, afterDelay: 2.0)
    }

    @objc
    private func dismissInfo(completion: (() -> Void)?) {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(dismissInfo), object: nil)
        UIView.animate(withDuration: 0.5, animations: {
            self.infoVisualEffectView.contentView.alpha = 0.0
            self.infoVisualEffectView.effect = nil
        }) { (_) in
            completion?()
        }
    }

    private func showInfo(with sticker: Sticker) {
        if infoVisualEffectView.effect != nil {
            dismissInfo {
                self.showInfo(with: sticker)
            }
        } else {
            populatInfo(with: sticker)
            UIView.animate(withDuration: 0.5) {
                self.infoVisualEffectView.contentView.alpha = 1.0
                let visualEffect = UIBlurEffect(style: .light)
                self.infoVisualEffectView.effect = visualEffect
            }
            perform(#selector(dismissInfo(completion:)), with: nil, afterDelay: 3.0)
        }
    }

    private func populatInfo(with sticker: Sticker) {
        infoImageView.isHidden = false
        infoImageView.image = sticker.stickerImage
        infoTitleLabel.isHidden = false
        infoTitleLabel.text = sticker.title
        infoTitleLabel.textAlignment = .natural
        infoDescriptionLabel.text = sticker.description
        infoDescriptionLabel.textAlignment = .natural
    }

    // MARK: - Actions -
    @objc
    private func didPressClose(_ sender: UIButton) {
        delegate?.stickerScannerViewController(self, didPressCloseWith: addedStickers)
    }

    @objc
    private func didPressRefresh(_ sender: UIButton) {
        let configuration = ARImageTrackingConfiguration()

        guard let trackingImages = ARReferenceImage.referenceImages(inGroupNamed: ARImageGroupName.stickers, bundle: Bundle.main) else {
            fatalError("No refrence images in bundle")
        }

        configuration.trackingImages = trackingImages
        configuration.maximumNumberOfTrackedImages = 1

        // Run the view's session
        sceneView.session.run(configuration, options: [ARSession.RunOptions.removeExistingAnchors])
    }
}

// MARK: - ARSCNViewDelegate -
extension StickerScannerViewController: ARSCNViewDelegate {

    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        guard let anchor = anchor as? ARImageAnchor else { return nil }
        print(anchor.name ?? "NoName")
        guard let sticker = StickerStack.shared.stickers.first(where: { $0.identifier == anchor.name}) else {
            return SCNNode()
        }
        if UserDefaults.appGroup?.date(for: sticker) == nil {
            UserDefaults.appGroup?.add(sticker)
            addedStickers.append(sticker)
        }
        let sceneController = sticker.sceneController
        let scene = sceneController.makeScene()
        sceneController.prepare(node: scene.rootNode)
        DispatchQueue.main.async {
            self.showInfo(with: sticker)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            sceneController.animateOn(node: scene.rootNode)
        }
        return scene.rootNode
    }

    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        print(error)
    }

    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay

    }

    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required

    }
}
