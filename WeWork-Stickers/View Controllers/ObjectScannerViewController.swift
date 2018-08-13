//
//  ObjectScannerViewController.swift
//  WeWork-Stickers
//
//  Created by B Gay on 7/21/18.
//  Copyright © 2018 B Gay. All rights reserved.
//

import UIKit
import ARKit
import SceneKit

final class ObjectScannerViewController: UIViewController {

    @IBOutlet weak var sceneView: ARSCNView!
    var count = 0
    
    lazy var tapGesture: UITapGestureRecognizer = {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.didTap(_:)))
        return tapGesture
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        sceneView.delegate = self
        
        let scene = SCNScene()
        
        sceneView.scene = scene
        sceneView.addGestureRecognizer(tapGesture)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal, .vertical]
        
        guard let trackingObjects = ARReferenceObject.referenceObjects(inGroupNamed: ARImageGroupName.objects, bundle: Bundle.main) else {
            fatalError("No refrence images in bundle")
        }
        
        configuration.detectionObjects = trackingObjects
        configuration.isLightEstimationEnabled = true
        configuration.environmentTexturing = .automatic
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    private func setupUI() {
        
    }
    
    @objc
    private func didTap(_ sender: UITapGestureRecognizer) {
        let location = sender.location(in: sceneView)
        let results = sceneView.hitTest(location, types: [.existingPlane, .featurePoint])
        guard let result = results.first else { return }
        let anchor = ARAnchor(transform: result.worldTransform)
        sceneView.session.add(anchor: anchor)
    }

}

// MARK: - ARSCNViewDelegate -
extension ObjectScannerViewController: ARSCNViewDelegate {
    
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        if let anchor = anchor as? ARObjectAnchor {
//            print("\(anchor.referenceObject.center) center")
//            print("\(anchor.referenceObject.extent) extent")
//            print("\(anchor.referenceObject.name ?? "") name")
//            if anchor.referenceObject.name?.contains("cup") == true {
//                let sceneController = MonterreySceneController()
//                let scene = sceneController.makeScene()
//                sceneController.prepare(node: scene.rootNode)
//                sceneController.animateOn(node: scene.rootNode)
//                return scene.rootNode
//            } else {
//                let sceneController = DoWhatYouLoveSceneController()
//                let scene = sceneController.makeScene()
//                sceneController.prepare(node: scene.rootNode)
//                sceneController.animateOn(node: scene.rootNode)
//                return scene.rootNode
//            }
        } else if (anchor is ARPlaneAnchor) == false && (anchor is AREnvironmentProbeAnchor) == false {
            if count % 2 == 0 {
                let sceneController = CalcSceneController()
                let scene = sceneController.makeScene()
                sceneController.prepare(node: scene.rootNode)
                sceneController.animateOn(node: scene.rootNode)
                return scene.rootNode
                
            } else {
                let sceneController = MetalCupSceneController()
                let scene = sceneController.makeScene()
                sceneController.prepare(node: scene.rootNode)
                sceneController.animateOn(node: scene.rootNode)
                return scene.rootNode
            }
        }
        return SCNNode()
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let anchor = anchor as? ARPlaneAnchor,
            let device = MTLCreateSystemDefaultDevice() else { return }
        print("didUpdate")
        
        let plane = ARSCNPlaneGeometry(device: device)
        plane?.update(from: anchor.geometry)
        node.geometry = plane
        if anchor.alignment == .horizontal {
            node.geometry?.firstMaterial?.diffuse.contents = UIColor.blue.withAlphaComponent(0.0)
        } else {
            node.geometry?.firstMaterial?.diffuse.contents = UIColor.green.withAlphaComponent(0.0)
        }
        
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
