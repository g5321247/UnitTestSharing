//
//  Client.swift
//  Example
//
//  Created by George Liu on 2020/9/18.
//  Copyright © 2020 George Liu. All rights reserved.
//

import Foundation

protocol HTTPClient {
    func get(from url: URL, completion: @escaping (Result<(Data, HTTPURLResponse), Error>) -> Void)
}
