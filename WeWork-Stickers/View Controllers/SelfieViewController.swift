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

final class SelfieViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var blurView: UIVisualEffectView!
    lazy var statusViewController: StatusViewController = {
        return children.lazy.compactMap({ $0 as? StatusViewController }).first!
    }()

    var session: ARSession {
        return sceneView.session
    }

    var nodeForContentType = [VirtualContentType: VirtualFaceNode]()

    let contentUpdater = VirtualContentUpdater()

    var selectedVirtualContent: VirtualContentType = .glasses {
        didSet {
            contentUpdater.virtualFaceNode = nodeForContentType[selectedVirtualContent]
        }
    }

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
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        UIApplication.shared.isIdleTimerDisabled = true
        resetTracking()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        // Pause the view's session
        sceneView.session.pause()
    }

    func createFaceGeometry() {
        let device = sceneView.device!
        let glassesGeometry = ARSCNFaceGeometry(device: device)!
        nodeForContentType = [
            .glasses: GlassesOverlay(geometry: glassesGeometry),
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
}

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
}
