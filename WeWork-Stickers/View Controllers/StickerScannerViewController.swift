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

    // MARK: - Properties -
    weak var delegate: StickerScannerViewControllerDelegate?
    private var addedStickers = [Sticker]()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        configuration.maximumNumberOfTrackedImages = 1
        
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
    }

    // MARK: - Actions -
    @objc
    private func didPressClose(_ sender: UIButton) {
        delegate?.stickerScannerViewController(self, didPressCloseWith: addedStickers)
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
        let sceneController = sticker.sceneController
        let scene = sceneController.makeScene()
        sceneController.prepare(node: scene.rootNode)
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
