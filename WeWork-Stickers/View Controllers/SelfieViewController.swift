//
//  SelfieViewController.swift
//  WeWork-Stickers
//
//  Created by brad.gayman on 7/18/18.
//  Copyright © 2018 B Gay. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import iCarousel
import Vivid

final class SelfieViewController: UIViewController, ARSCNViewDelegate {

    // MARK: - Outlets -
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var blurView: UIVisualEffectView!
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var carousel: iCarousel!
    
    // MARK: - Properties -
    lazy var statusViewController: StatusViewController = {
        return children.lazy.compactMap({ $0 as? StatusViewController }).first!
    }()
    
    lazy var context: CIContext = {
        let context = CIContext(mtlDevice: sceneView.device!)
        return context
    }()

    var session: ARSession {
        return sceneView.session
    }

    let filterQueue = DispatchQueue(label: "com.wework.stickerFilterQueue")
    var currentBuffer: CVPixelBuffer?
    var nodeForContentType = [VirtualContentType: VirtualFaceNode]()

    let contentUpdater = VirtualContentUpdater()

    var selectedVirtualContent: VirtualContentType = .glasses {
        didSet {
            contentUpdater.virtualFaceNode = nodeForContentType[selectedVirtualContent]
        }
    }

    // MARK: - Lifecycle -
    override func viewDidLoad() {
        super.viewDidLoad()

        // Set the view's delegate
        sceneView.delegate = contentUpdater
        sceneView.session.delegate = self
        sceneView.automaticallyUpdatesLighting = true

        createFaceGeometry()

        contentUpdater.virtualFaceNode = nodeForContentType[selectedVirtualContent]

        statusViewController.restartExperienceHandler = { [unowned self] in
            self.restartExperience()
        }
        
        carousel.type = .linear
        carousel.isVertical = false
        carousel.scrollSpeed = 0.4
        cameraButton.layer.borderWidth = 4.0
        cameraButton.layer.borderColor = UIColor.white.cgColor
        cameraButton.layer.cornerRadius = cameraButton.bounds.height * 0.5
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        UIApplication.shared.isIdleTimerDisabled = true
        resetTracking()
        statusViewController.showMessage("""
        Raise eyebrows to change content.
        """, autoHide: false)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        // Pause the view's session
        sceneView.session.pause()
    }

    // MARK: - Setup -
    func createFaceGeometry() {
        let device = sceneView.device!
        let glassesGeometry = ARSCNFaceGeometry(device: device)!
        let maskGeometry = ARSCNFaceGeometry(device: device)!
        nodeForContentType = [
            .glasses: GlassesOverlay(geometry: glassesGeometry),
            .stickerMask: Mask(geometry: maskGeometry),
        ]
    }

    func resetTracking() {
        guard ARFaceTrackingConfiguration.isSupported else { return }
        let configuration = ARFaceTrackingConfiguration()
        configuration.isLightEstimationEnabled = true
        session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }

    func restartExperience() {
        // Disable Restart button for a while in order to give the session enough time to restart.
        statusViewController.isRestartExperienceButtonEnabled = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            self.statusViewController.isRestartExperienceButtonEnabled = true
        }

        resetTracking()
    }

    func displayErrorMessage(title: String, message: String) {
        blurView.isHidden = false

        // Present an alert informing about the error that has occurred.
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let restartAction = UIAlertAction(title: "Restart Session", style: .default) { _ in
            alertController.dismiss(animated: true, completion: nil)
            self.blurView.isHidden = true
            self.resetTracking()
        }
        alertController.addAction(restartAction)
        present(alertController, animated: true, completion: nil)
    }
    
    private let cameraShutterSoundID: SystemSoundID = 1108
    
    @IBAction func didPressCameraButton(_ sender: UIButton) {
        let image = sceneView.snapshot()
        AudioServicesPlaySystemSoundWithCompletion(cameraShutterSoundID, nil)
        let selfieImageViewController = SelfieImageViewController()
        selfieImageViewController.image = image
        selfieImageViewController.modalPresentationStyle = .fullScreen
        present(selfieImageViewController, animated: false)
    }
}

// MARK: - ARSessionDelegate -
extension SelfieViewController: ARSessionDelegate {

    func session(_ session: ARSession, didFailWithError error: Error) {
        guard error is ARError else { return }

        let errorWithInfo = error as NSError
        let messages = [
            errorWithInfo.localizedDescription,
            errorWithInfo.localizedFailureReason,
            errorWithInfo.localizedRecoverySuggestion
        ]
        let errorMessage = messages.compactMap({ $0 }).joined(separator: "\n")

        DispatchQueue.main.async {
            self.displayErrorMessage(title: "The AR session failed.", message: errorMessage)
        }
    }

    func sessionWasInterrupted(_ session: ARSession) {
        blurView.isHidden = false
        statusViewController.showMessage("""
        SESSION INTERRUPTED
        The session will be reset after the interruption has ended.
        """, autoHide: false)
    }

    func sessionInterruptionEnded(_ session: ARSession) {
        blurView.isHidden = true

        DispatchQueue.main.async {
            self.resetTracking()
        }
    }
    
//    func session(_ session: ARSession, didUpdate frame: ARFrame) {
//        guard currentBuffer == nil, case .normal = frame.camera.trackingState else {
//            return
//        }
//        let orient = UIApplication.shared.statusBarOrientation
//        let viewportSize = sceneView.bounds.size
//        let transform = frame.displayTransform(for: orient, viewportSize: viewportSize).inverted()
//        self.currentBuffer = frame.capturedImage
//        filterQueue.async {
//            defer { self.currentBuffer = nil }
//            let image = CIImage(cvPixelBuffer: self.currentBuffer!).transformed(by: transform)
//            let filter = CIFilter(name: "CIGaussianBlur")
//            filter?.setValue(10.0, forKey: "inputRadius")
//            filter?.setValue(image, forKey: "inputImage")
//            let output = filter?.outputImage
//            self.sceneView.scene.background.contents = self.context.createCGImage(output!, from: image.extent)
//        }
//    }
}

extension SelfieViewController: iCarouselDelegate {
    
    func carouselCurrentItemIndexDidChange(_ carousel: iCarousel) {
        selectedVirtualContent = VirtualContentType.orderedValues[carousel.currentItemIndex]
    }
    
    func carousel(_ carousel: iCarousel, valueFor option: iCarouselOption, withDefault value: CGFloat) -> CGFloat {
        switch option {
            
        case .angle, .arc, .count, .fadeMax, .fadeMin, .fadeMinAlpha, .fadeRange, .offsetMultiplier, .showBackfaces, .wrap, .tilt, .visibleItems:
            return value
        case .radius:
            return 90.0 * CGFloat(VirtualContentType.orderedValues.count) * 0.25
        case .spacing:
            return value * 1.75
        }
    }
}

// MARK: - iCarouselDataSource -
extension SelfieViewController: iCarouselDataSource {
    
    func numberOfItems(in carousel: iCarousel) -> Int {
        return VirtualContentType.orderedValues.count
    }
    
    func carousel(_ carousel: iCarousel, viewForItemAt index: Int, reusing view: UIView?) -> UIView {
        let contentType = VirtualContentType.orderedValues[index]
        let imageView = UIImageView(image: UIImage(named: contentType.imageName))
        imageView.tintColor = UIColor.appRed
        return imageView
    }
}
