//
//  VitualContentUpdater.swift
//  WeWork-Stickers
//
//  Created by brad.gayman on 7/18/18.
//  Copyright © 2018 B Gay. All rights reserved.
//

import SceneKit
import ARKit

final class VirtualContentUpdater: NSObject, ARSCNViewDelegate {
    let showsCoordinateOrigin = false

    var virtualFaceNode: VirtualFaceNode? {
        didSet {
            setupFaceNodeContent()
        }
    }

    private var faceNode: SCNNode?

    private let serialQueue = DispatchQueue(label: "com.bradgayman.ARFaceSceneKit")

    private func setupFaceNodeContent() {
        guard let node = faceNode else { return }
        node.childNodes.forEach { $0.removeFromParentNode() }

        if let content = virtualFaceNode {
            node.addChildNode(content)
        }
    }

    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        faceNode = node
        serialQueue.async {
            self.setupFaceNodeContent()
        }
    }

    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        if let faceAnchor = anchor as? ARFaceAnchor {
            virtualFaceNode?.update(withFaceAnchor: faceAnchor)
        }
    }
}
