//
//  UserDefaults+Application.swift
//  WeWork-Stickers
//
//  Created by brad.gayman on 7/18/18.
//  Copyright © 2018 B Gay. All rights reserved.
//

import Foundation

extension UserDefaults {

    static let appGroupID = "com.wework.stickers"

    static let appGroup = UserDefaults(suiteName: UserDefaults.appGroupID)

    func add(_ sticker: Sticker) {
        let interval = Date().timeIntervalSince1970
        set(interval, forKey: sticker.identifier)
    }

    func remove(_ sticker: Sticker) {
        removeObject(forKey: sticker.identifier)
    }

    func date(for sticker: Sticker) -> Date? {
        let interval = double(forKey: sticker.identifier)
        guard interval > 0.0 else { return nil }
        return Date(timeIntervalSince1970: interval)
    }
}
