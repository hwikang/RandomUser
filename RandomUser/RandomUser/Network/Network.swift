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
        print("Fetch URL - \(url)")
        let response = await session.request(url, method: method).validate().serializingData().response
        return response.result
    }
}

enum NetworkError: Error {
    case responseParsingError
}

