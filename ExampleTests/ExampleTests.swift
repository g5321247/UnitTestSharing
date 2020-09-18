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
                let invalidJSON = Data("invalidJSON".utf8)

                client.complete(statusCode: statusCode, data: invalidJSON,at: index)
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
            let emptyItemList = makeJSON([])

            client.complete(statusCode: 200, data: emptyItemList)
        })
    }

    func test_load_deliversItemsOn200HTTPResponseWithJSONItems() {
        let (sut, client) = makeSUT()
        let item1 = makeFeedItem(
            id: UUID(),
            description: nil,
            location: nil,
            imageURL: URL(string: "https://any-URL.com")!
        )

        let item2 = makeFeedItem(
            id: UUID(),
            description: "a description",
            location: "a location",
            imageURL: URL(string: "https://any-URL.com")!
        )

        expect(sut: sut, onCompletionResult: .success([item1.model, item2.model]), when: {
            let json = makeJSON([item1.json, item2.json])
            client.complete(statusCode: 200, data: json)
        })

    }

    func test_load_doesNotDeliverResultAfterSUTDeallocated() {
        let client = HTTPClientSpy()
        let url = URL(string: "https://www.youtube.com/")!
        var sut: RemoteFeedLoader? = RemoteFeedLoader(
            requestURL: url, client: client)

        var captureResults: [RemoteFeedLoader.Result] = []
        sut?.load { result in
            captureResults.append(result)
        }

        sut = nil
        client.complete(statusCode: 200, data: makeJSON([]))

        XCTAssert(captureResults.isEmpty)
    }

}

private extension ExampleTests {
    func makeSUT(url: URL = URL(string: "https://www.youtube.com/")!) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(
            requestURL: url, client: client)

        traceMemoryLeak(instance: sut)
        traceMemoryLeak(instance: client)

        return (sut: sut, client: client)
    }

    func traceMemoryLeak(instance: AnyObject, file: StaticString = #file, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, file: file, line: line)
        }
    }

    func expect(sut: RemoteFeedLoader, onCompletionResult expectedResult: RemoteFeedLoader.Result, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {

        var captureResults: [RemoteFeedLoader.Result] = []
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

        func complete(statusCode: Int, data: Data, at index: Int = 0) {
            let response = HTTPURLResponse(
                url: requestURLs[index],
                statusCode: statusCode,
                httpVersion: nil,
                headerFields: nil
            )!

            messages[index].completion(.success((data, response)))
        }

    }

    func makeFeedItem(id: UUID, description: String? = nil, location: String? = nil, imageURL: URL) -> (model: FeedItem, json: [String: Any]) {
        let item = FeedItem(
            id: id,
            description: description,
            location: location,
            imageURL: imageURL
        )

        let itemJSON = [
            "id": item.id.uuidString,
            "description": item.description,
            "location": item.location,
            "image": item.imageURL.absoluteString,
        ].compactMapValues { $0 }

        return (item, itemJSON)
    }

    func makeJSON(_ items: [[String: Any]]) -> Data {
        let items = [
            "items": items
        ]

        let json = try! JSONSerialization.data(withJSONObject: items)
        return json
    }
}

extension Data {
    func toString() -> String {
        return String(decoding: self, as: UTF8.self)
    }
}
