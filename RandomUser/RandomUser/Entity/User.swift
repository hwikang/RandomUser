//
//  User.swift
//  RandomUser
//
//  Created by paytalab on 5/15/24.
//

import Foundation

public struct User: Decodable, Hashable {
    let uuid: String
    let fullName: String
    let gender: Gender
    let picture: Picture
    let phone : String
    let email: String
    
    enum CodingKeys: CodingKey {
        case login
        enum Login: String, CodingKey {
            case uuid
        }
        case name
        enum Name: String, CodingKey {
            case title
            case first
            case last
        }
        case gender
        case picture
        case phone
        case email
        
    }
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let loginContainer = try container.nestedContainer(keyedBy: CodingKeys.Login.self, forKey: .login)
        self.uuid = try loginContainer.decode(String.self, forKey: .uuid)
        let nameContainer = try container.nestedContainer(keyedBy: CodingKeys.Name.self, forKey: .name)
        let nameTitle = try nameContainer.decode(String.self, forKey: .title)
        let nameFirst = try nameContainer.decode(String.self, forKey: .first)
        let nameLast = try nameContainer.decode(String.self, forKey: .last)
        self.fullName = "\(nameTitle) \(nameFirst) \(nameLast)"
        self.gender = try container.decode(Gender.self, forKey: .gender)
        self.picture = try container.decode(Picture.self, forKey: .picture)
        self.phone = try container.decode(String.self, forKey: .phone)
        self.email = try container.decode(String.self, forKey: .email)
    }
}
