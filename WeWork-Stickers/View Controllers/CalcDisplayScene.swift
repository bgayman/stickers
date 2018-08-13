//
//  CalcDisplayScene.swift
//  WeWork-Stickers
//
//  Created by brad.gayman on 8/13/18.
//  Copyright © 2018 B Gay. All rights reserved.
//

import SpriteKit

class CalcDisplayScene: SKScene {

    override init() {
        super.init(size: CGSize(width: 1024, height: 1024))
        self.backgroundColor = UIColor(white: 0.75, alpha: 1.0)
        let textSprite = SKLabelNode(text: "123456789")
        textSprite.fontName = "Menlo-Bold"
        textSprite.fontSize = 120
        textSprite.fontColor = UIColor.black
        textSprite.position = CGPoint(x: 512, y: 1024 - 20)
        self.addChild(textSprite)
        textSprite.zRotation = CGFloat.pi
        textSprite.xScale = -1
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
