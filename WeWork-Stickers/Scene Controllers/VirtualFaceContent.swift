//
//  VirtualFaceContent.swift
//  WeWork-Stickers
//
//  Created by brad.gayman on 7/18/18.
//  Copyright © 2018 B Gay. All rights reserved.
//

import SceneKit
import ARKit
import SpriteKit

protocol VirtualFaceContent {
    func update(withFaceAnchor: ARFaceAnchor)
}

typealias VirtualFaceNode = VirtualFaceContent & SCNNode

func loadedContentForAsset(named resourceName: String) -> SCNNode {
    let url = Bundle.main.url(forResource: resourceName, withExtension: "scn", subdirectory: "art.scnassets")!
    let node = SCNReferenceNode(url: url)!
    node.load()
    return node
}

final class GlassesOverlay: SCNNode, VirtualFaceContent {

    let occlusionNode: SCNNode
    static var shaderCount = 0
    let rect = CGRect(origin: .zero, size: CGSize(width: 100, height: 100))
    private lazy var testNode1 = SKSpriteNode(color: .white, size: self.rect.size)
    private lazy var testNode2 = SKSpriteNode(color: .white, size: self.rect.size)

    private lazy var glasses = childNode(withName: "glasses", recursively: true)!
    private lazy var eyeLeftNode = self.glasses.childNode(withName: "WeLeft", recursively: true)!
    private lazy var eyeRightNode = self.glasses.childNode(withName: "WeRight", recursively: true)!
    private lazy var framesNode = self.glasses.childNode(withName: "Frames", recursively: true)!
    private lazy var shaders = [nil,
                                self.makeCheckerboard(),
                                self.makeCircleWaveRainbowBlended(),
                                self.makeLightGrid(),
                                self.makeRadialGradient(),
                                self.makeDynamicGrayNoise(),
                                self.makeDynamicRainbowNoise()]
    var areBrowsUp = false

    var blendShapes: [ARFaceAnchor.BlendShapeLocation: Any] = [:] {
        didSet {
            guard let browInnerUp = blendShapes[.browInnerUp] as? Float else { return }
            if browInnerUp > 0.25 {
                if areBrowsUp == false {
                    updateNodes()
                }
                areBrowsUp = true
            } else {
                areBrowsUp = false
            }

        }
    }

    /// - Tag: OcclusionMaterial
    init(geometry: ARSCNFaceGeometry) {

        /*
         Write depth but not color and render before other objects.
         This causes the geometry to occlude other SceneKit content
         while showing the camera view beneath, creating the illusion
         that real-world objects are obscuring virtual 3D objects.
         */
        geometry.firstMaterial!.colorBufferWriteMask = []
        occlusionNode = SCNNode(geometry: geometry)
        occlusionNode.renderingOrder = -1

        super.init()

        addChildNode(occlusionNode)

        // Add 3D content positioned as "glasses".
        let faceOverlayContent = loadedContentForAsset(named: "glasses")
        addChildNode(faceOverlayContent)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("\(#function) has not been implemented")
    }


    // MARK: VirtualFaceContent

    func updateNodes() {
        GlassesOverlay.shaderCount += 1
        let spriteKitScene = SKScene(size: CGSize(width: 100, height: 100))
        let otherSpriteKitScene = SKScene(size: CGSize(width: 100, height: 100))
        testNode1.anchorPoint = CGPoint(x: 0, y: 0)
        testNode1.color = .white
        testNode2.anchorPoint = CGPoint(x: 0, y: 0)
        testNode2.color = .white
        testNode1.removeFromParent()
        testNode2.removeFromParent()
        spriteKitScene.addChild(testNode1)
        spriteKitScene.backgroundColor = .white
        otherSpriteKitScene.addChild(testNode2)
        otherSpriteKitScene.backgroundColor = .white
        let shader = shaders[GlassesOverlay.shaderCount % shaders.count]
        testNode1.shader = shader
        testNode2.shader = shader
        let material = SCNMaterial()
        material.diffuse.contents = spriteKitScene

        let otherMaterial = SCNMaterial()
        otherMaterial.diffuse.contents = otherSpriteKitScene
        eyeRightNode.geometry?.materials = [material]
        eyeLeftNode.geometry?.materials = [otherMaterial]
    }

    func update(withFaceAnchor anchor: ARFaceAnchor) {
        let faceGeometry = occlusionNode.geometry as! ARSCNFaceGeometry
        faceGeometry.update(from: anchor.geometry)
        blendShapes = anchor.blendShapes
    }

    func makeLightGrid() -> SKShader {
        let uniforms: [SKUniform] = [
            SKUniform(name: "u_density", float: 8),
            SKUniform(name: "u_speed", float: 3),
            SKUniform(name: "u_group_size", float: 2),
            SKUniform(name: "u_brightness", float: 3),
            ]

        return SKShader(fromFile: "SHKLightGrid", uniforms: uniforms)
    }

    func makeCheckerboard() -> SKShader {
        let uniforms: [SKUniform] = [
            SKUniform(name: "u_rows", float: 12),
            SKUniform(name: "u_cols", float: 12),
            SKUniform(name: "u_first_color", color: .white),
            SKUniform(name: "u_second_color", color: .black),
            ]

        return SKShader(fromFile: "SHKCheckerboard", uniforms: uniforms)
    }

    func makeCircleWaveRainbowBlended() -> SKShader {
        let uniforms: [SKUniform] = [
            SKUniform(name: "u_speed", float: 1),
            SKUniform(name: "u_brightness", float: 0.5),
            SKUniform(name: "u_strength", float: 2),
            SKUniform(name: "u_density", float: 100),
            SKUniform(name: "u_center", point: CGPoint(x: 0.68, y: 0.33)),
            SKUniform(name: "u_red", float: -1)
        ]

        return SKShader(fromFile: "SHKCircleWaveRainbowBlended", uniforms: uniforms)
    }

    func makeRadialGradient() -> SKShader {
        let uniforms: [SKUniform] = [
            SKUniform(name: "u_first_color", color: .blue),
            SKUniform(name: "u_second_color", color: .clear),
            SKUniform(name: "u_center", point: CGPoint(x: 0.75, y: 0.25))
        ]

        return SKShader(fromFile: "SHKRadialGradient", uniforms: uniforms)
    }

    func makeDynamicGrayNoise() -> SKShader {
        return SKShader(fromFile: "SHKDynamicGrayNoise")
    }

    func makeDynamicRainbowNoise() -> SKShader {
        return SKShader(fromFile: "SHKDynamicRainbowNoise")
    }
}
