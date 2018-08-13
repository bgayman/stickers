//
//  MetalCupSceneController.swift
//  WeWork-Stickers
//
//  Created by B Gay on 7/24/18.
//  Copyright © 2018 B Gay. All rights reserved.
//

import SceneKit

final class MetalCupSceneController: NSObject, SceneController {
    
    func prepare(node: SCNNode) {
        node.childNodes.first?.physicsBody = SCNPhysicsBody(type: SCNPhysicsBodyType.kinematic, shape: nil)
    }
    
    func makeScene() -> SCNScene {
        return SCNScene(named: "art.scnassets/metalCup.scn")!
    }
    
    func animateOn(node: SCNNode) {
    }
    
    static var count = 0
}
