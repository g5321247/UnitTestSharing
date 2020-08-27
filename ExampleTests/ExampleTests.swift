//
//  ExampleTests.swift
//  ExampleTests
//
//  Created by George Liu on 2020/8/18.
//  Copyright © 2020 George Liu. All rights reserved.
//

import XCTest
@testable import Example

class ExampleTests: XCTestCase {
    func test_init_doesNotRequestDataFromURL() {
        let (_, client) = makeSUT()


        XCTAssertTrue(client.requestURLs.isEmpty)
    }

    func test_load_requestDataFromURL() {
        let url =  URL(string: "https://www.youtube.com/")!

        let (sut, client) = makeSUT(url: url)
        sut.load()
        XCTAssertEqual(client.requestURLs, [url])
    }

    func test_loadTwice_requestDataFromURL() {
        let (sut, client) = makeSUT()
        sut.load()
        sut.load()

        XCTAssertEqual(client.requestURLs.count, 2)
    }

    func test_load_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()

        var captureError: FeedLoader.Error?

        sut.load { error in
            captureError = error
        }

        let error = NSError(domain: "", code: 0, userInfo: [:])

        client.complete(with: error, at: 0)
        XCTAssertEqual(captureError, .noConnectivity)
    }

    func test_load_deliversErrorOnNon200HTTPResponse() {
    }

    func test_load_deliversInvalidDataOn200HTTPResponseWithInvalidJSON() {
    }

    func test_load_deliversEmptyItemsOn200HTTPResponseWithEmptyJSONList() {
    }

    func test_load_deliversItemsOn200HTTPResponseWithJSONItems() {
    }

    func test_load_doesNotDeliverResultAfterSUTDeallocated() {
    }

}

private extension ExampleTests {

    func makeSUT(url: URL = URL(string: "https://www.youtube.com/")!) -> (sut: FeedLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = FeedLoader(
            requestURL: url, client: client)

        return (sut: sut, client: client)
    }

    class HTTPClientSpy: HTTPClient {
        var messages: [(url: URL, completion:(Error) -> Void)] = []

        var requestURLs: [URL] {
            return messages.map { $0.url }
        }

        func get(from url: URL, completion: @escaping (Error) -> Void) {
            messages.append((url: url, completion: completion))
        }

        func complete(with err: Error, at index: Int) {
            messages[index].completion(err)
        }

    }
}
