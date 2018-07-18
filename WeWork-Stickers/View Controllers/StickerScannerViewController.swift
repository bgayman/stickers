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

protocol SceneController {
    func prepare(node: SCNNode)
    func makeScene() -> SCNScene
    func animateOn(node: SCNNode)
}

struct ARImageGroupName {
    static let stickers = "Stickers"
}

struct ARScenesBuilder {
    static func makeDoWhatYouLoveSignScene() -> SCNScene {
        return SCNScene(named: "art.scnassets/doWhatYouLove3.scn")!
    }
    
    static func makeSanFranciscoScene() -> SCNScene {
        return SCNScene(named: "art.scnassets/sanFranciscoScene.scn")!
    }
    
    static func makeNewYorkScene() -> SCNScene {
        return SCNScene(named: "art.scnassets/newYorkScene.scn")!
    }
}


final class StickerScannerViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Create a new scene
        let scene = SCNScene()
        
        // Set the scene to the view
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

    // MARK: - ARSCNViewDelegate
    

    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        guard let anchor = anchor as? ARImageAnchor else { return nil }
        print(anchor.name ?? "NoName")
        if anchor.name == "sanFrancisco" {
            let sceneController = SanFranciscoSceneController()
            let scene = sceneController.makeScene()
            sceneController.prepare(node: scene.rootNode)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                sceneController.animateOn(node: scene.rootNode)
            }
            return scene.rootNode
        } else if anchor.name == "newYork" {
            let sceneController = NewYorkSceneController()
            let scene = sceneController.makeScene()
            sceneController.prepare(node: scene.rootNode)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                sceneController.animateOn(node: scene.rootNode)
            }
            return scene.rootNode
        }
        let scene = ARScenesBuilder.makeDoWhatYouLoveSignScene()
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

extension SCNNode {
    func blur() {
        let gaussianBlurFilter = CIFilter(name: "CIGaussianBlur")!
        gaussianBlurFilter.name = "blur"
        gaussianBlurFilter.setValue(2.0, forKey: "inputRadius")
        filters = (filters ?? []) + [gaussianBlurFilter]
    }
}
