//
//  DoWhatYouLoveSceneController.swift
//  WeWork-Stickers
//
//  Created by brad.gayman on 7/18/18.
//  Copyright © 2018 B Gay. All rights reserved.
//

import SceneKit

final class DoWhatYouLoveSceneController: NSObject, SceneController {
    static var count = 0

    func prepare(node: SCNNode) {
    }


    func makeScene() -> SCNScene {
        return SCNScene(named: "art.scnassets/doWhatYouLove3.scn")!
    }
    
    func animateOn(node: SCNNode) {
        guard
            let root = node.childNode(withName: "plane", recursively: true),
            let sign = root.childNode(withName: "Sign", recursively: true)
        else { return }
        sign.scale = SCNVector3Zero
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 0.5
        sign.scale = SCNVector3(0.05, 0.05, 0.05)
        
        SCNTransaction.completionBlock = {
            self.animateText(node: node)
        }
        
        SCNTransaction.commit()
    }
    
    func animateText(node: SCNNode) {
        let root = node.childNode(withName: "plane", recursively: true)
        guard
            let sign = root?.childNode(withName: "Sign", recursively: true),
            let doText = sign.childNode(withName: "Do", recursively: true),
            let what = sign.childNode(withName: "What", recursively: true),
            let you = sign.childNode(withName: "You", recursively: true),
            let love = sign.childNode(withName: "Love", recursively: true)
        else { return }
        
        let words = [doText, what, you, love]
        let word = words[DoWhatYouLoveSceneController.count % words.count]
        let material = word.geometry?.firstMaterial
        // highlight it
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 0.75
        
        // on completion - unhighlight
        SCNTransaction.completionBlock = {
            DoWhatYouLoveSceneController.count += 1
            if DoWhatYouLoveSceneController.count >= words.count && DoWhatYouLoveSceneController.count % words.count == 0 {
                SCNTransaction.begin()
                SCNTransaction.animationDuration = 0.75
                words.forEach {
                    $0.geometry?.firstMaterial?.emission.contents = UIColor.black
                }
                SCNTransaction.completionBlock = {
                    self.animateText(node: node)
                }
                
                SCNTransaction.commit()
            } else {
                self.animateText(node: node)
            }
            
        }
        
        if word === love {
            material?.emission.contents = UIColor.red
        } else {
            material?.emission.contents = UIColor.white
        }
        
        SCNTransaction.commit()
    }
}
