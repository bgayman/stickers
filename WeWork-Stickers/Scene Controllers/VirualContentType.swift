//
//  VirualContentType.swift
//  WeWork-Stickers
//
//  Created by brad.gayman on 7/18/18.
//  Copyright © 2018 B Gay. All rights reserved.
//

import Foundation

enum VirtualContentType: Int {
    case glasses
    case stickerMask

    static let orderedValues: [VirtualContentType] = [.glasses, .stickerMask]

    var imageName: String {
        switch self {
        case .glasses:
            return "icGlasses"
        case .stickerMask:
            return "icStickerMask"
        }
    }
}
