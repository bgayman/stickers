//
//  SanFranciscoSceneManager.swift
//  WeWork-Stickers
//
//  Created by B Gay on 7/16/18.
//  Copyright © 2018 B Gay. All rights reserved.
//

import SceneKit

final class SanFranciscoSceneController: NSObject, SceneController {
    
    let audio = SCNAudioSource(fileNamed: "nautical.wav")!
    static var count = 0

    
    func makeScene() -> SCNScene {
        return ARScenesBuilder.makeSanFranciscoScene()
    }
    
    func prepare(node: SCNNode) {
        let bridge = node.childNode(withName: "bridge", recursively: true)
        bridge?.scale = SCNVector3(0.0075, 0.0075, 0.0075)
    }
    
    func animateOn(node: SCNNode) {
        guard
            let light = node.childNode(withName: "light", recursively: true),
            let light2 = node.childNode(withName: "light2", recursively: true),
            let fog = node.childNode(withName: "fog", recursively: true),
            let fog2 = node.childNode(withName: "fog2", recursively: true),
            let bridge = node.childNode(withName: "bridge", recursively: true),
            let weWorkText = node.childNode(withName: "weWorkText", recursively: true)
            else { return }
        light.scale = SCNVector3Zero
        light2.scale = SCNVector3Zero
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 1.0
        for node in bridge.childNodes {
            node.scale = SCNVector3(1.05, 1.0, 1.0)
        }
        for node in weWorkText.childNodes {
            node.geometry?.firstMaterial?.transparency = 1.0
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
        playAudio(node: node)
    }
    
    func animateLights(node: SCNNode) {
        guard let light = node.childNode(withName: "light", recursively: true) else { return }
        let material = light.geometry!.firstMaterial!
        
        // highlight it
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 1.5
        
        // on completion - unhighlight
        SCNTransaction.completionBlock = {
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 2.5
            material.emission.contents = UIColor.black
            SCNTransaction.completionBlock = {
                self.animateLights(node: node)
            }
            
            SCNTransaction.commit()
        }
        
        material.emission.contents = UIColor.red
        
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
        let letter = letters[SanFranciscoSceneController.count % letters.count]
        let material = letter.geometry?.firstMaterial
        // highlight it
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 0.75
        
        // on completion - unhighlight
        SCNTransaction.completionBlock = {
            SanFranciscoSceneController.count += 1
            if SanFranciscoSceneController.count >= letters.count && SanFranciscoSceneController.count % letters.count == 0 {
                SCNTransaction.begin()
                SCNTransaction.animationDuration = 0.75
                letters.forEach {
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
        
        material?.emission.contents = UIColor.white
        
        SCNTransaction.commit()
    }
    
    func playAudio(node: SCNNode) {
        node.removeAllAudioPlayers()
        let audioPlayer = SCNAudioPlayer(source: audio)
        audioPlayer.didFinishPlayback = {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                self.playAudio(node: node)
            }
        }
        node.addAudioPlayer(audioPlayer)
    }
}
