//
//  FeedItemMapper.swift
//  Example
//
//  Created by George Liu on 2020/9/18.
//  Copyright © 2020 George Liu. All rights reserved.
//

import Foundation

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

    static func map(data: Data, reponse: HTTPURLResponse) -> RemoteFeedLoader.Result {
        guard reponse.statusCode == OK_200, let root = try? JSONDecoder().decode(Root.self, from: data) else {
            return .failure(.invalidData)
        }
        return .success(root.items.map { $0.feedItem })
    }
}
