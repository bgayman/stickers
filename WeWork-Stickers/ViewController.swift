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
}

class ViewController: UIViewController, ARSCNViewDelegate {

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
            let scene = ARScenesBuilder.makeSanFranciscoScene()
            let bridge = scene.rootNode.childNode(withName: "bridge", recursively: true)
            bridge?.scale = SCNVector3(0.0075, 0.0075, 0.0075)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.animateOn(node: scene.rootNode)
            }
            return scene.rootNode
        }
        let scene = ARScenesBuilder.makeDoWhatYouLoveSignScene()
        return scene.rootNode
    }
    
    func animateOn(node: SCNNode) {
        guard
            let light = node.childNode(withName: "light", recursively: true),
            let light2 = node.childNode(withName: "light2", recursively: true),
            let fog = node.childNode(withName: "fog", recursively: true),
            let fog2 = node.childNode(withName: "fog2", recursively: true),
            let bridge = node.childNode(withName: "bridge", recursively: true)
        else { return }
        light.scale = SCNVector3Zero
        light2.scale = SCNVector3Zero
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 1.0
        for node in bridge.childNodes {
            node.scale = SCNVector3(1.1, 1.0, 1.0)
        }
        
        SCNTransaction.completionBlock = {
            self.animateLights(node: node)
            self.animateText(node: node)
        }
        light.scale = SCNVector3(1.0, 1.0, 1.0)
        light2.scale = SCNVector3(1.0, 1.0, 1.0)
        
        SCNTransaction.commit()
        
        let fogSystem = SCNParticleSystem(named: "Fog.scnp", inDirectory: nil)!
        let fogSystem2 = SCNParticleSystem(named: "Fog.scnp", inDirectory: nil)!
        fog.addParticleSystem(fogSystem)
        fog2.addParticleSystem(fogSystem2)
    }
    
    func animateLights(node: SCNNode) {
        guard let light = node.childNode(withName: "light", recursively: true),
            let light2 = node.childNode(withName: "light2", recursively: true) else { return }
        let material = light.geometry!.firstMaterial!
        let material2 = light2.geometry!.firstMaterial!
        
        // highlight it
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 1.5
        
        // on completion - unhighlight
        SCNTransaction.completionBlock = {
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 2.5
            material.emission.contents = UIColor.black
            material2.emission.contents = UIColor.black
            SCNTransaction.completionBlock = { [unowned self] in
                self.animateLights(node: node)
            }
            
            SCNTransaction.commit()
        }
        
        material.emission.contents = UIColor.red
        material2.emission.contents = UIColor.red
        
        SCNTransaction.commit()
    }
    
    func animateText(node: SCNNode) {
        guard
            let weWorkText = node.childNode(withName: "weWorkText", recursively: true),
            let w = weWorkText.childNode(withName: "W", recursively: true),
            let e = weWorkText.childNode(withName: "E", recursively: true),
            let w2 = weWorkText.childNode(withName: "W2", recursively: true),
            let o = weWorkText.childNode(withName: "O", recursively: true),
            let r = weWorkText.childNode(withName: "R", recursively: true),
            let k = weWorkText.childNode(withName: "K", recursively: true)
        else { return }
        
        let letters = [w, e, w2, o, r, k]
        let letter = letters[ViewController.count % letters.count]
        let material = letter.geometry?.firstMaterial
        // highlight it
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 0.75
        
        // on completion - unhighlight
        SCNTransaction.completionBlock = {
            ViewController.count += 1
            if ViewController.count >= letters.count && ViewController.count % letters.count == 0 {
                SCNTransaction.begin()
                SCNTransaction.animationDuration = 0.75
                letters.forEach {
                    $0.geometry?.firstMaterial?.emission.contents = UIColor.black
                }
                SCNTransaction.completionBlock = { [unowned self] in
                    self.animateText(node: node)
                }
                
                SCNTransaction.commit()
            } else {
                self.animateText(node: node)
            }
            
        }
        
        material?.emission.contents = UIColor.white
        
        SCNTransaction.commit()
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
