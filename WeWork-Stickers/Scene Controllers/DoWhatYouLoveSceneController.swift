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
    }
}
