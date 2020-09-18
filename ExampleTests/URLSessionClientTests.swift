//
//  URLSessionClientTests.swift
//  ExampleTests
//
//  Created by George Liu on 2020/9/18.
//  Copyright © 2020 George Liu. All rights reserved.
//

import XCTest

protocol HTTPURLSession {
    func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> HTTPURLSessionDataTask
}

extension URLSessionDataTask: HTTPURLSessionDataTask {}

extension URLSession {
    func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> HTTPURLSessionDataTask {
        let result: URLSessionDataTask = dataTask(with: url, completionHandler: completionHandler)
        return result
    }
}

protocol HTTPURLSessionDataTask {
    func resume()
}

class HTTPURLSessionClient {

    let session: HTTPURLSession

    init(session: HTTPURLSession) {
        self.session = session
    }

    func get(with url: URL, completion: @escaping (Error?) -> Void) {
        session.dataTask(with: url) { (_, _, error) in
            completion(error)
        }.resume()
    }
}

class HTTPURLSessionClientTests: XCTestCase {

    func test_getWithURL_DataTaskCallResume() {
        let url = URL(string: "https://any-URL.com")!
        let session = URLSessionSpy()
        let dataTask = URLSessionDataTaskSpy()

        session.stub(url: url, dataTask: dataTask)
        let sut = HTTPURLSessionClient(session: session)
        sut.get(with: url) { _ in}

        XCTAssertEqual(dataTask.resumeCount, 1)
    }

    func test_getWithURL_failedDataTaskWithError() {
        let url = URL(string: "https://any-URL.com")!
        let session = URLSessionSpy()
        let dataTask = URLSessionDataTaskSpy()
        let error = NSError(domain: "Any Error", code: 0)

        session.stub(url: url, dataTask: dataTask, error: error)
        let sut = HTTPURLSessionClient(session: session)

        let exp = expectation(description: "load get")
        var captureError: NSError?

        sut.get(with: url) { error in
            captureError = error as NSError?
            exp.fulfill()
        }

        wait(for: [exp], timeout: 1.0)
        XCTAssertEqual(error, captureError)
    }


    class URLSessionSpy: HTTPURLSession {
        private var stubs: [URL: Stub] = [:]


        struct Stub {
            let dataTask: HTTPURLSessionDataTask
            let error: Error?
        }

        func stub(url: URL, dataTask: HTTPURLSessionDataTask, error: Error? = nil) {
            stubs[url] = Stub(dataTask: dataTask, error: error)
        }

        func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> HTTPURLSessionDataTask {
            guard let stub = stubs[url] else {
                fatalError("Not get stub with \(url)")
            }

            completionHandler(nil, nil, stub.error)

            return stub.dataTask
        }
    }

    class URLSessionDataTaskFake: HTTPURLSessionDataTask {
        func resume() {
        }
    }

    class URLSessionDataTaskSpy: HTTPURLSessionDataTask {
        var resumeCount = 0

        func resume() {
            resumeCount += 1
        }
    }
}
