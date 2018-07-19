//
//  SaoPauloSceneController.swift
//  WeWork-Stickers
//
//  Created by B Gay on 7/19/18.
//  Copyright © 2018 B Gay. All rights reserved.
//

import SceneKit

final class SaoPauloSceneController: NSObject, SceneController {
    
    func prepare(node: SCNNode) {
        
    }
    
    func makeScene() -> SCNScene {
        return SCNScene(named: "art.scnassets/saoPauloScene.scn")!
    }
    
    func animateOn(node: SCNNode) {
        let root = node.childNode(withName: "plane", recursively: true)
        guard
            let background = root?.childNode(withName: "background", recursively: true),
            let structure = root?.childNode(withName: "structure", recursively: true)
        else { return }
        
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 2.0
        background.childNodes.forEach {
            guard $0.name != "plane" else { return }
            $0.scale  = SCNVector3(1, 1, 1)
        }
        structure.childNodes.forEach {
            $0.scale  = SCNVector3(1, 1, 1)
        }
        SCNTransaction.completionBlock = {
        }
        SCNTransaction.commit()
    }
    
    static var count = 0
}
