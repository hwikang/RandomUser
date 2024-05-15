//
//  Picture.swift
//  RandomUser
//
//  Created by paytalab on 5/15/24.
//

import Foundation

public struct Picture: Decodable, Hashable {
    
    let largeURL : URL?
    let mediumURL: URL?
    let thumbnailURL: URL?
    
    enum CodingKeys: CodingKey {
        case large
        case medium
        case thumbnail
    }
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let largeURLString = try container.decode(String.self, forKey: .large)
        let mediumURLString = try container.decode(String.self, forKey: .medium)
        let thumbnailURLString = try container.decode(String.self, forKey: .thumbnail)
        largeURL = URL(string: largeURLString)
        mediumURL = URL(string: mediumURLString)
        thumbnailURL = URL(string: thumbnailURLString)
    }
}
