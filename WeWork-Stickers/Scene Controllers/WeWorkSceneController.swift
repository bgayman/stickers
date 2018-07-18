//
//  WeWorkSceneController.swift
//  WeWork-Stickers
//
//  Created by brad.gayman on 7/18/18.
//  Copyright © 2018 B Gay. All rights reserved.
//

import SceneKit

final class WeWorkSceneController: NSObject, SceneController {

    func prepare(node: SCNNode) {

    }

    func makeScene() -> SCNScene {
        return SCNScene(named: "art.scnassets/weWorkScene.scn")!
    }

    func animateOn(node: SCNNode) {
        let root = node.childNode(withName: "plane", recursively: true)
        guard
            let mug = root?.childNode(withName: "mug", recursively: true)
        else { return }

        SCNTransaction.begin()
        SCNTransaction.animationDuration = 2.0
        mug.childNodes.forEach {
            $0.scale  = SCNVector3(1, 1, 1)
        }
        SCNTransaction.completionBlock = {
        }
        SCNTransaction.commit()
    }

    static var count = 0
}
