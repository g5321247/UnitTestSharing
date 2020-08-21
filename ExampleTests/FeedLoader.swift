//
//  FeedLoader.swift
//  ExampleTests
//
//  Created by George Liu on 2020/8/18.
//  Copyright © 2020 George Liu. All rights reserved.
//

import Foundation

protocol HTTPClient {
    func get(from url: URL, completion: @escaping (Error) -> Void)
}

struct FeedLoader {
    let requestURL: URL
    let client: HTTPClient

    enum Error: Swift.Error {
        case noConnectivity
    }

    func load(completion: @escaping (Error) -> Void = { _ in }) {
        client.get(from: requestURL) { _ in
            completion(.noConnectivity)
        }
    }
}
