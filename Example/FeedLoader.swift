//
//  FeedLoader.swift
//  Example
//
//  Created by George Liu on 2020/9/18.
//  Copyright © 2020 George Liu. All rights reserved.
//

import Foundation

typealias FeedLoaderResult<E: Error> = Result<[FeedItem], E>

protocol FeedLoader {
    associatedtype E: Error
    func load(completion: @escaping (FeedLoaderResult<E>) -> Void)
}
