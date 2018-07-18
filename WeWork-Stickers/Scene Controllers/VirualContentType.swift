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

    static let orderedValues: [VirtualContentType] = [.glasses]

    var imageName: String {
        switch self {
        case .glasses:
            return "glasses"
        }
    }
}
