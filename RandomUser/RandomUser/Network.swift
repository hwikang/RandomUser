//
//  Network.swift
//  RandomUser
//
//  Created by paytalab on 5/13/24.
//

import Foundation
import Alamofire

final class Network {
    private let urlPrefix = "https://randomuser.me/api/"
    private let urlSeed = "lightening-market"
    private let session = Session(configuration: .default)
    
    public func requestAPI(page: Int, results: Int, method: HTTPMethod) async -> Result<Data, AFError> {
        let url = urlPrefix + "?seed=\(urlSeed)" + "&page=\(page)" + "&results=\(results)"
        let response = await session.request(url, method: method).validate().serializingData().response
        return response.result
    }
}

enum NetworkError: Error {
    case responseParsingError
}


final class UserNetwork {
    private let module = Network()
    public func getUsers(page: Int, results: Int) async -> Result<[User], Error> {
        let result = await module.requestAPI(page: page, results: results, method: .get)
        switch result {
        case .success(let data):
            guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let articles = json["articles"] as? [[String: Any]],
                  let articlesData = try? JSONSerialization.data(withJSONObject: articles, options: .prettyPrinted),
                  let news = try? JSONDecoder().decode([User].self, from: articlesData) else {
                return .failure(NetworkError.responseParsingError)
            }
           
            return .success(news)
           
        case .failure(let error):
            return .failure(error)
        }
    }
}

struct User: Decodable {
    
}
