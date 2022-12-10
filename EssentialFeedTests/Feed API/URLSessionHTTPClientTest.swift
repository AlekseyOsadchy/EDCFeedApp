//
//  URLSessionHTTPClientTest.swift
//  EssentialFeedTests
//
//  Created by Aleksey Osadchy on 10.12.2022.
//

import XCTest

class URLSessionHTTPClient {
    
    private let session: URLSession
    
    init(session: URLSession) {
        self.session = session
    }
    
    func get(from url: URL) {
        session.dataTask(with: url) { _, _, _ in }.resume()
    }
}

final class URLSessionHTTPClientTest: XCTestCase {

    func test_getFromURL_resumesDataTaskWithURL() {
        
        let url = URL(string: "https://a-url.com")!
        let session = URLSessionSpy()
        let sut = URLSessionHTTPClient(session: session)
        let task = URLSessionDataTaskSpy()
        
        session.stub(url: url, task: task)
        sut.get(from: url)
        
        XCTAssertEqual(task.resumeCallCount, 1)
    }
}

// MARK - Helpers

extension URLSessionHTTPClientTest {
    
    private class URLSessionSpy: URLSession {
        private var stubs: [URL: URLSessionDataTask] = [:]
        
        func stub(url: URL, task: URLSessionDataTask) {
            stubs[url] = task
        }
        
        override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
            return stubs[url] ?? FakeURLSessionDataTask()
        }
    }
    
    
    private class FakeURLSessionDataTask: URLSessionDataTask {
        override func resume() {}
    }
    
    private class URLSessionDataTaskSpy: URLSessionDataTask {
        var resumeCallCount: Int = 0
        
        override func resume() {
            resumeCallCount += 1
        }
    }
}
