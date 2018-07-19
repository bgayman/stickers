//
//  Sticker+SceneController.swift
//  WeWork-Stickers
//
//  Created by B Gay on 7/19/18.
//  Copyright © 2018 B Gay. All rights reserved.
//

import Foundation

extension Sticker {
    var sceneController: SceneController {
        guard let type = StickerType(rawValue: identifier) else {
            return DoWhatYouLoveSceneController()
        }
        switch type {
        case .frankfurt,
             .paris,
             .pride,
             .saoPaulo,
             .telAviv:
            return DoWhatYouLoveSceneController()
        case .monterrey, .montreal:
            return MonterreySceneController()
        case .pride2:
            return Pride2SceneController()
        case .weWork:
            return WeWorkSceneController()
        case .chicago:
            return ChicagoSceneController()
        case .newYork:
            return NewYorkSceneController()
        case .sanFrancisco:
            return SanFranciscoSceneController()
        }
    }
}
