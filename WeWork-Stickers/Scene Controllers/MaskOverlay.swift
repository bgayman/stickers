//
//  MaskOverlay.swift
//  WeWork-Stickers
//
//  Created by B Gay on 7/18/18.
//  Copyright © 2018 B Gay. All rights reserved.
//

import ARKit
import SceneKit
import UIKit

final class Mask: SCNNode, VirtualFaceContent {
    static var count = 0
    
    init(geometry: ARSCNFaceGeometry) {
        let material = geometry.firstMaterial!
        
        material.diffuse.contents = UIImage(named: "mask")
        material.lightingModel = .physicallyBased
        
        super.init()
        self.geometry = geometry
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("\(#function) has not been implemented")
    }
    
    var areBrowsUp = false
    var needsUpdate = false
    var isUpdating = false
    
    var blendShapes: [ARFaceAnchor.BlendShapeLocation: Any] = [:] {
        didSet {
            guard let browInnerUp = blendShapes[.browInnerUp] as? Float else { return }
            if browInnerUp > 0.5 {
                if areBrowsUp == false {
                    needsUpdate = true
                }
                areBrowsUp = true
            } else {
                areBrowsUp = false
            }
            
        }
    }
    
    // MARK: VirtualFaceContent
    
    /// - Tag: SCNFaceGeometryUpdate
    func update(withFaceAnchor anchor: ARFaceAnchor) {
        let faceGeometry = geometry as! ARSCNFaceGeometry
        faceGeometry.update(from: anchor.geometry)
        blendShapes = anchor.blendShapes
        if needsUpdate && !isUpdating {
            isUpdating = true
            DispatchQueue.main.async {
                Mask.count += 1
                let sticker = StickerStack.shared.stickers[Mask.count % StickerStack.shared.stickers.count]
                let maskView = MaskView(sticker: sticker)
                faceGeometry.firstMaterial?.diffuse.contents = maskView.snapshotMask
                self.needsUpdate = false
                self.isUpdating = false
            }
        }
        
    }
}

extension UIView {
    var snapshotMask: UIImage? {
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, 1)
        self.drawHierarchy(in: self.bounds, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}

final class MaskView: UIView {
    
    init(sticker: Sticker) {
        super.init(frame: CGRect(origin: .zero, size: CGSize(width: 1024, height: 1024)))
        let imageView = UIImageView(image: sticker.stickerImage)
        imageView.frame = CGRect(x: 20, y: 420, width: 300.0, height: 300.0)
        addSubview(imageView)
        let rightImageView = UIImageView(image: sticker.stickerImage)
        rightImageView.frame = CGRect(x: 704, y: 420, width: 300.0, height: 300.0)
        addSubview(rightImageView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
