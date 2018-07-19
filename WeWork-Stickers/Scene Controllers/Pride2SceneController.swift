//
//  Pride2SceneController.swift
//  WeWork-Stickers
//
//  Created by B Gay on 7/18/18.
//  Copyright © 2018 B Gay. All rights reserved.
//

import SceneKit

final class Pride2SceneController: NSObject, SceneController {
    
    func prepare(node: SCNNode) {
    }
    
    func makeScene() -> SCNScene {
        return SCNScene(named: "art.scnassets/pride2Scene.scn")!
    }
    
    func animateOn(node: SCNNode) {
    }
    
    static var count = 0
}
