//
//  FeedItem.swift
//  Example
//
//  Created by George Liu on 2020/9/18.
//  Copyright © 2020 George Liu. All rights reserved.
//

import Foundation

struct FeedItem: Equatable {
    let id: UUID
    let description: String?
    let location: String?
    let imageURL: URL

}
