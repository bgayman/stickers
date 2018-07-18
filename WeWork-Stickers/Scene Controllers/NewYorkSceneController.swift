//
//  NewYorkSceneController.swift
//  WeWork-Stickers
//
//  Created by B Gay on 7/17/18.
//  Copyright © 2018 B Gay. All rights reserved.
//

import SceneKit

final class NewYorkSceneController: NSObject, SceneController {
    static var count = 0

    func prepare(node: SCNNode) {
        let text = node.childNode(withName: "text", recursively: true)
        let city = node.childNode(withName: "city", recursively: true)
        let cityText = node.childNode(withName: "cityText", recursively: true)
        let lights = node.childNode(withName: "lights", recursively: true)
        text?.scale = SCNVector3(0.0075, 0.0075, 0.0075)
        city?.scale = SCNVector3(0.0075, 0.0075, 0.0075)
        cityText?.scale = SCNVector3(0.0075, 0.0075, 0.0075)
        lights?.scale = SCNVector3(0.0075, 0.0075, 0.0075)
    }
    
    
    func makeScene() -> SCNScene {
        return ARScenesBuilder.makeNewYorkScene()
    }
    
    func animateOn(node: SCNNode) {
        guard
            let text = node.childNode(withName: "text", recursively: true),
            let weWorkText = text.childNode(withName: "weWorkText", recursively: true),
            let newYorkText = text.childNode(withName: "newYorkText", recursively: true),
            let city = node.childNode(withName: "city", recursively: true),
            let cityText = node.childNode(withName: "cityText", recursively: true),
            let frame = node.childNode(withName: "frame", recursively: true)
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
        cityText.childNodes.forEach {
            $0.scale = SCNVector3(1, 1, 1)
        }
        frame.childNodes.forEach {
            $0.scale = SCNVector3(1, 1, 1)
        }
        SCNTransaction.completionBlock = {
            self.animateLights(node: node)
            let sparklerLeft = node.childNode(withName: "sparklerLeft", recursively: true)
            let sparklerRight = node.childNode(withName: "sparklerRight", recursively: true)
            let sparkler = SCNParticleSystem(named: "Sparkler.scnp", inDirectory: nil)!
            let sparkler2 = SCNParticleSystem(named: "Sparkler.scnp", inDirectory: nil)!
            sparklerLeft?.addParticleSystem(sparkler)
            sparklerRight?.addParticleSystem(sparkler2)
        }
        SCNTransaction.commit()
    }
    
    func animateLights(node: SCNNode) {
        guard
            let lights = node.childNode(withName: "lights", recursively: true)
        else { return }
        
        let num = "\(NewYorkSceneController.count % 4)"
        // highlight it
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 0.25
        let leftLight = lights.childNode(withName: "lightLeft\(num)", recursively: true)
        let rightLight = lights.childNode(withName: "lightRight\(num)", recursively: true)
        leftLight?.geometry?.firstMaterial?.emission.contents = UIColor.white
        rightLight?.geometry?.firstMaterial?.emission.contents = UIColor.white
        
        // on completion - unhighlight
        SCNTransaction.completionBlock = {
            NewYorkSceneController.count += 1
            if NewYorkSceneController.count >= 4 && NewYorkSceneController.count % 4 == 0 {
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
            } else {
                self.animateLights(node: node)
            }
        }
        SCNTransaction.commit()
    }
}
