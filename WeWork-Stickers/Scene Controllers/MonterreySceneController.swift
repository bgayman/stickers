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

final class CalcSceneController: NSObject, SceneController {
    
    func prepare(node: SCNNode) {
        let root = node.childNode(withName: "calc", recursively: true)
        let display = root?.childNode(withName: "Display", recursively: true)
        let scene = CalcDisplayScene()
        display?.geometry?.firstMaterial?.diffuse.contents = scene
    }
    
    func makeScene() -> SCNScene {
        return SCNScene(named: "art.scnassets/calc.scn")!
    }
    
    func animateOn(node: SCNNode) {
        let root = node.childNode(withName: "calc", recursively: true)
        
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 0.5
        root?.scale = SCNVector3(0.022, 0.022, 0.022)
        SCNTransaction.completionBlock = {
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 0.5
            let buttons = root?.childNode(withName: "Buttons", recursively: true)
            buttons?.scale.y = 1
            SCNTransaction.commit()
        }
        SCNTransaction.commit()
    }
    
    static var count = 0
}
