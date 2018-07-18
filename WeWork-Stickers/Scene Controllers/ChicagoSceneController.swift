//
//  ChicagoSceneController.swift
//  WeWork-Stickers
//
//  Created by brad.gayman on 7/18/18.
//  Copyright © 2018 B Gay. All rights reserved.
//

import SceneKit

final class ChicagoSceneController: NSObject, SceneController {

    func prepare(node: SCNNode) {
        if let root = node.childNode(withName: "plane", recursively: true),
           let lights = root.childNode(withName: "lights", recursively: true),
           let stars = root.childNode(withName: "stars", recursively: true),
           let material = lights.childNodes.first?.geometry?.materials.first {
            lights.childNodes.forEach {
                $0.geometry?.materials.append(material)
            }
            stars.childNodes.forEach {
                $0.geometry?.materials.append(material)
            }
        }
    }

    func makeScene() -> SCNScene {
        return SCNScene(named: "art.scnassets/chicagoScene.scn")!
    }

    func animateOn(node: SCNNode) {
        let root = node.childNode(withName: "plane", recursively: true)
        guard
            let weWorkText = root?.childNode(withName: "weWorkText", recursively: true)
        else { return }

        SCNTransaction.begin()
        SCNTransaction.animationDuration = 0.2
        weWorkText.childNodes.forEach {
            $0.scale  = SCNVector3(1, 1, 1)
        }
        SCNTransaction.completionBlock = {
            self.animateLights(node: node)
        }
        SCNTransaction.commit()
    }

    func animateLights(node: SCNNode) {
        let root = node.childNode(withName: "plane", recursively: true)
        guard
            let lights = root?.childNode(withName: "lights", recursively: true)
        else { return }

        // highlight it
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 0.25
        let material = lights.childNodes.first?.geometry?.firstMaterial
        material?.emission.contents = UIColor.white

        // on completion - unhighlight
        SCNTransaction.completionBlock = {
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 0.25
            lights.childNodes
                .filter { $0.name?.contains("light") == true }
                .forEach {
                    $0.geometry?.firstMaterial?.emission.contents = UIColor.black
            }
            SCNTransaction.completionBlock = {
                self.animateLights(node: node)
            }
            SCNTransaction.commit()
        }
        SCNTransaction.commit()
    }

    static var count = 0
}
