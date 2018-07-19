//
//  MonterreySceneController.swift
//  WeWork-Stickers
//
//  Created by B Gay on 7/19/18.
//  Copyright © 2018 B Gay. All rights reserved.
//

import SceneKit

final class MonterreySceneController: NSObject, SceneController {
    
    func prepare(node: SCNNode) {
        
    }
    
    func makeScene() -> SCNScene {
        return SCNScene(named: "art.scnassets/monterreyScene.scn")!
    }
    
    func animateOn(node: SCNNode) {
        let root = node.childNode(withName: "plane", recursively: true)
        
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 2.0
        root?.childNodes.forEach {
            $0.scale  = SCNVector3(0.009, 0.009, 0.009)
        }
        SCNTransaction.completionBlock = {
        }
        SCNTransaction.commit()
    }
    
    static var count = 0
}
