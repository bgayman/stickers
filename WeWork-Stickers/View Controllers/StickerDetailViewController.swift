//
//  StickerDetailViewController.swift
//  WeWork-Stickers
//
//  Created by brad.gayman on 7/18/18.
//  Copyright © 2018 B Gay. All rights reserved.
//

import UIKit
import SceneKit
import SafariServices

// MARK: - StickerDetailViewController -
final class StickerDetailViewController: UIViewController {

    static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .medium
        dateFormatter.doesRelativeDateFormatting = true
        return dateFormatter
    }()

    // MARK: - Outlets -
    @IBOutlet weak var sceneView: SCNView!
    @IBOutlet weak var infoStackView: UIStackView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var moreButton: UIButton!
    @IBOutlet weak var captionLabel: UILabel!
    
    // MARK: - Properties -
    let sticker: Sticker
    
    lazy var shareBarButton: UIBarButtonItem = {
        let shareBarButton = UIBarButtonItem(image: UIImage(named: "icShare")!, style: .plain, target: self, action: #selector(didPressShare(_:)))
        return shareBarButton
    }()
    
    lazy var locationBarButton: UIBarButtonItem = {
        let locationBarButton = UIBarButtonItem(image: UIImage(named: "icLocation")!, style: .plain, target: self, action: #selector(didPressLocation(_:)))
        return locationBarButton
    }()

    init(sticker: Sticker) {
        self.sticker = sticker
        super.init(nibName: "\(StickerDetailViewController.self)", bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let sceneController = sticker.sceneController
        guard let node = sceneView.scene?.rootNode else { return }
        sceneController.animateOn(node: node)
    }

    // MARK: - Setup -
    private func setupUI() {
        navigationItem.largeTitleDisplayMode = .never
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]

        title = sticker.title

        descriptionLabel.font = UIFont.appFont(textStyle: .body, weight: .medium)
        descriptionLabel.textColor = UIColor.white
        descriptionLabel.text = sticker.description
        captionLabel.font = UIFont.appFont(textStyle: .caption1, weight: .semibold)
        captionLabel.textColor = UIColor.white.withAlphaComponent(0.8)
        if let date = UserDefaults.appGroup?.date(for: sticker) {
            let dateString = StickerDetailViewController.dateFormatter.string(from: date)
            captionLabel.text = "Added \(dateString)"
        }

        moreButton.titleLabel?.font = UIFont.appFont(textStyle: .headline, weight: .bold)
        moreButton.tintColor = UIColor.appRed
        moreButton.addTarget(self, action: #selector(didPressMore(_:)), for: .touchUpInside)

        navigationItem.rightBarButtonItems = sticker.location == nil ? [shareBarButton] : [shareBarButton, locationBarButton]

        let sceneController = sticker.sceneController
        let scene = sceneController.makeScene()

        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        scene.rootNode.addChildNode(cameraNode)

        cameraNode.position = SCNVector3(0.0, 1.5, 0.5)

        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light?.type = .omni
        lightNode.position = SCNVector3(0, 10, 10)
        scene.rootNode.addChildNode(lightNode)
        sceneView.allowsCameraControl = true

        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = .ambient
        ambientLightNode.light!.color = UIColor.darkGray
        scene.rootNode.addChildNode(ambientLightNode)

        sceneView.scene = scene
        sceneView.backgroundColor = .black
        if let node = scene.rootNode.childNode(withName: "plane", recursively: true) {
            node.geometry?.firstMaterial?.diffuse.contents = sticker.stickerTextureImage ?? sticker.stickerImage
            node.geometry?.firstMaterial?.isDoubleSided = true
            node.geometry?.firstMaterial?.transparency = 1.0
            cameraNode.constraints = [SCNLookAtConstraint(target: node)]
        } else {
            let plane = SCNPlane(width: sticker.size.width, height: sticker.size.height)
            let node = SCNNode(geometry: plane)
            node.geometry?.firstMaterial?.diffuse.contents = sticker.stickerTextureImage ?? sticker.stickerImage
            node.eulerAngles = SCNVector3(-CGFloat.pi * 0.5, 0.0, 0.0)
            node.geometry?.firstMaterial?.isDoubleSided = true
            node.name = "plane"
            scene.rootNode.addChildNode(node)
            cameraNode.constraints = [SCNLookAtConstraint(target: node)]
        }

        scene.rootNode.childNode(withName: "plane", recursively: true)?.scale = SCNVector3(10.0, 10.0, 10.0)
        sceneController.prepare(node: scene.rootNode)
    }

    @objc
    private func didPressMore(_ sender: UIButton) {
        let safariViewController = SFSafariViewController(url: sticker.wikiLink)
        safariViewController.preferredControlTintColor = UIColor.appRed
        present(safariViewController, animated: true)
    }

    @objc
    private func didPressShare(_ sender: UIBarButtonItem) {
        let activityController = UIActivityViewController(activityItems: [sticker.stickerImage], applicationActivities: nil)
        activityController.popoverPresentationController?.barButtonItem = sender
        present(activityController, animated: true)
    }

    @objc
    private func didPressLocation(_ sender: UIBarButtonItem) {
        let stickerLocationViewController = StickerLocationViewController(sticker: sticker)
        let navVC = UINavigationController(rootViewController: stickerLocationViewController)
        navVC.modalPresentationStyle = .popover
        navVC.popoverPresentationController?.barButtonItem = sender
        present(navVC, animated: true)
    }
}
