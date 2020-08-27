//
//  FeedLoader.swift
//  ExampleTests
//
//  Created by George Liu on 2020/8/18.
//  Copyright © 2020 George Liu. All rights reserved.
//

import Foundation

struct FeedItem: Equatable {
    let id: UUID
    let description: String?
    let location: String?
    let imageURL: URL
}

protocol HTTPClient {
    func get(from url: URL, completion: @escaping (Result<(Data, HTTPURLResponse), Error>) -> Void)
}

struct FeedLoader {
    let requestURL: URL
    let client: HTTPClient

    enum Error: Swift.Error {
        case noConnectivity
        case invalidData
    }

    enum Result: Equatable {
        case success([FeedItem])
        case failure(Error)
    }

    func load(completion: @escaping (Result) -> Void = { _ in }) {
        client.get(from: requestURL) { (result) in

            switch result {
            case .success(let data, _):
                if let _ = try? JSONSerialization.jsonObject(with: data) {
                    completion(.success([]))
                } else {
                    completion(.failure(.invalidData))
                }

            case .failure(_):
                completion(.failure(.noConnectivity))
            }
        }
    }
}
