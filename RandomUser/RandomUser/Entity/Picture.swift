//
//  Picture.swift
//  RandomUser
//
//  Created by paytalab on 5/15/24.
//

import Foundation

public struct Picture: Decodable, Hashable {
    
    let largeURL : URL?
    let thumbnailURL: URL?
    
    enum CodingKeys: CodingKey {
        case large
        case thumbnail
    }
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let largeURLString = try container.decode(String.self, forKey: .large)
        let thumbnailURLString = try container.decode(String.self, forKey: .thumbnail)
        largeURL = URL(string: largeURLString)
        thumbnailURL = URL(string: thumbnailURLString)
    }
}
