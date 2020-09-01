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

//protocol FeedLoader {
//    func load(completion: @escaping (Result) -> Void)
//}

class FeedLoader {
    let requestURL: URL
    let client: HTTPClient

    init(requestURL: URL, client: HTTPClient) {
        self.requestURL = requestURL
        self.client = client
    }

    enum Error: Swift.Error {
        case noConnectivity
        case invalidData
    }

    enum Result: Equatable {
        case success([FeedItem])
        case failure(Error)
    }

    func load(completion: @escaping (Result) -> Void = { _ in }) {
        client.get(from: requestURL) { [weak self] (result) in
            guard self != nil else { return }
            switch result {
            case .success(let (data, reponse)):
                completion(FeedItemMapper.map(data: data, reponse: reponse))

            case .failure(_):
                completion(.failure(.noConnectivity))
            }
        }
    }
}

class FeedItemMapper {

    struct Root: Decodable {
        let items: [Item]
    }

    struct Item: Decodable {
        let id: UUID
        let description: String?
        let location: String?
        let image: URL

        var feedItem: FeedItem {
            return FeedItem(
                id: id,
                description: description,
                location: location,
                imageURL: image
            )
        }
    }

    static var OK_200: Int {
        return 200
    }

    static func map(data: Data, reponse: HTTPURLResponse) -> FeedLoader.Result {
        guard reponse.statusCode == OK_200, let root = try? JSONDecoder().decode(Root.self, from: data) else {
            return .failure(.invalidData)
        }
        return .success(root.items.map { $0.feedItem })
    }
}
