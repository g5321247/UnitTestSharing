//
//  FeedLoader.swift
//  ExampleTests
//
//  Created by George Liu on 2020/8/18.
//  Copyright © 2020 George Liu. All rights reserved.
//

import Foundation


class RemoteFeedLoader: FeedLoader {
    typealias Result = FeedLoaderResult<Error>

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
