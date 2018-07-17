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

protocol SceneManager {
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

final class NewYorkSceneManager: NSObject, SceneManager {

    func makeScene() -> SCNScene {
        return ARScenesBuilder.makeNewYorkScene()
    }
    
    func animateOn(node: SCNNode) {
        guard
            let text = node.childNode(withName: "text", recursively: true),
            let weWorkText = text.childNode(withName: "weWorkText", recursively: true),
            let newYorkText = text.childNode(withName: "newYorkText", recursively: true),
            let city = node.childNode(withName: "city", recursively: true)
        else { return }
        
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 0.5
        weWorkText.childNodes.forEach {
            $0.scale  = SCNVector3(1, 1, 1)
        }
        newYorkText.childNodes.forEach {
            $0.scale = SCNVector3(1, 1, 1)
        }
        city.childNodes.forEach {
            $0.scale = SCNVector3(1, 2.5, 1)
        }
        SCNTransaction.completionBlock = {}
        SCNTransaction.commit()
    }
}


final class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    static var count = 0
    
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
            let sceneManager = SanFranciscoSceneManager()
            let scene = sceneManager.makeScene()
            let bridge = scene.rootNode.childNode(withName: "bridge", recursively: true)
            bridge?.scale = SCNVector3(0.0075, 0.0075, 0.0075)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                sceneManager.animateOn(node: scene.rootNode)
            }
            return scene.rootNode
        } else if anchor.name == "newYork" {
            let sceneManager = NewYorkSceneManager()
            let scene = sceneManager.makeScene()
            let text = scene.rootNode.childNode(withName: "text", recursively: true)
            let city = scene.rootNode.childNode(withName: "city", recursively: true)
            text?.scale = SCNVector3(0.0075, 0.0075, 0.0075)
            city?.scale = SCNVector3(0.0075, 0.0075, 0.0075)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                sceneManager.animateOn(node: scene.rootNode)
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
