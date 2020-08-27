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
        expect(sut: sut, onCompletionResult: .failure(.noConnectivity), when: {
            let error = NSError(domain: "", code: 0, userInfo: [:])

            client.complete(with: error, at: 0)
        })
    }

    func test_load_deliversErrorOnNon200HTTPResponse() {
        let (sut, client) = makeSUT()
        let samples = [100, 300, 400, 500]

        samples.enumerated().forEach { (index, statusCode) in
            expect(sut: sut, onCompletionResult: .failure(.invalidData), when: {
                client.complete(statusCode: statusCode, at: index)
            })
        }
    }

    func test_load_deliversInvalidDataOn200HTTPResponseWithInvalidJSON() {

        let (sut, client) = makeSUT()
        expect(sut: sut, onCompletionResult: .failure(.invalidData), when: {
            let invalidJSON = Data("invalidJSON".utf8)

            client.complete(statusCode: 200, data: invalidJSON)
        })
    }

    func test_load_deliversEmptyItemsOn200HTTPResponseWithEmptyJSONList() {
        let (sut, client) = makeSUT()

        expect(sut: sut, onCompletionResult: .success([]), when: {
            let emptyItemList = Data("{\"items\": []}".utf8)

            client.complete(statusCode: 200, data: emptyItemList)
        })
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

    func expect(sut: FeedLoader, onCompletionResult expectedResult: FeedLoader.Result, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {

        var captureResults: [FeedLoader.Result] = []
        sut.load { result in
            captureResults.append(result)
        }

        action()
        XCTAssertEqual(captureResults, [expectedResult], file: file, line: line)
    }

    class HTTPClientSpy: HTTPClient {
        typealias Mesaage = (url: URL, completion:(Result<(Data, HTTPURLResponse), Error>) -> Void)

        var messages: [Mesaage] = []

        var requestURLs: [URL] {
            return messages.map { $0.url }
        }

        func get(from url: URL, completion: @escaping (Result<(Data, HTTPURLResponse), Error>) -> Void) {
            messages.append((url: url, completion: completion))
        }

        func complete(with error: Error, at index: Int = 0) {
            messages[index].completion(.failure(error))
        }

        func complete(statusCode: Int, data: Data = Data(), at index: Int = 0) {
            let response = HTTPURLResponse(
                url: requestURLs[index],
                statusCode: statusCode,
                httpVersion: nil,
                headerFields: nil
            )!

            messages[index].completion(.success((data, response)))
        }

    }
}
