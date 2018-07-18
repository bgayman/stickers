//
//  StickerStack.swift
//  WeWork-Stickers
//
//  Created by B Gay on 7/17/18.
//  Copyright © 2018 B Gay. All rights reserved.
//

import UIKit
import CoreLocation

typealias JSONDictionary = [String: Any]

final class StickerStack {

    static let shared = StickerStack()
    
    let stickers: [Sticker]
    
    init() {
        guard
            let path = Bundle.main.path(forResource: "Stickers", ofType: "plist"),
            let array = NSArray(contentsOfFile: path),
            let dicts = array as? [JSONDictionary]
        else { fatalError() }
        self.stickers = dicts.compactMap(Sticker.init)
    }
}

struct Sticker {

    let identifier: String
    let title: String
    let description: String
    var location: CLLocationCoordinate2D? = nil
    let imageName: String
    let stickerImage: UIImage
    let stickerTemplateImage: UIImage
    let wikiLink: URL
    var dateAdded: Date? = nil
    
    enum CodingKeys: String {
        case identifier
        case title
        case description
        case latitude
        case longitude
        case imageName
        case wikiLink
        case dateAdded
    }
    
    var dictionaryRepresentation: JSONDictionary {
        return [
            CodingKeys.identifier.rawValue: identifier,
            CodingKeys.title.rawValue: title,
            CodingKeys.description.rawValue: description,
            CodingKeys.latitude.rawValue: location?.latitude as Any,
            CodingKeys.longitude.rawValue: location?.longitude as Any,
            CodingKeys.imageName.rawValue: imageName,
            CodingKeys.wikiLink.rawValue: wikiLink.absoluteString,
            CodingKeys.dateAdded.rawValue: dateAdded?.timeIntervalSince1970 as Any
        ]
    }
}

extension Sticker {
    init?(dictionary: JSONDictionary) {
        guard
            let identifier = dictionary[CodingKeys.identifier.rawValue] as? String,
            let title = dictionary[CodingKeys.title.rawValue] as? String,
            let description = dictionary[CodingKeys.description.rawValue] as? String,
            let imageName = dictionary[CodingKeys.imageName.rawValue] as? String,
            let wikiLinkValue = dictionary[CodingKeys.wikiLink.rawValue] as? String,
            let wikiLink = URL(string: wikiLinkValue),
            let stickerImage = UIImage(named: imageName)
        else { return nil }
        self.identifier = identifier
        self.title = title
        self.description = description
        if let latitude = dictionary[CodingKeys.latitude.rawValue] as? Double,
           let longitude = dictionary[CodingKeys.longitude.rawValue] as? Double {
            self.location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        }
        self.imageName = imageName
        self.stickerImage = stickerImage
        self.stickerTemplateImage = stickerImage.withRenderingMode(.alwaysTemplate)
        self.wikiLink = wikiLink
        if let dateAddedValue = dictionary[CodingKeys.dateAdded.rawValue] as? Double {
            self.dateAdded = Date(timeIntervalSince1970: dateAddedValue)
        }
    }
}
