//
//  UserNetwork.swift
//  RandomUser
//
//  Created by paytalab on 5/15/24.
//

import Foundation

final public class UserNetwork {
    private let module = Network()
    public func getUsers(page: Int, results: Int) async -> Result<[User], Error> {
        let result = await module.requestAPI(page: page, results: results, method: .get)
        switch result {
        case .success(let data):
            guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let results = json["results"] as? [[String: Any]],
                  let resultsData = try? JSONSerialization.data(withJSONObject: results, options: .prettyPrinted) else {
                return .failure(NetworkError.responseParsingError)
            }
            let news = try! JSONDecoder().decode([User].self, from: resultsData)

            return .success(news)
           
        case .failure(let error):
            return .failure(error)
            
        }
    }
}
