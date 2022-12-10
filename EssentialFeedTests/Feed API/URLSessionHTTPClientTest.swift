//
//  URLSessionHTTPClientTest.swift
//  EssentialFeedTests
//
//  Created by Aleksey Osadchy on 10.12.2022.
//

import XCTest
import EssentialFeed

class URLSessionHTTPClient {
    
    private let session: URLSession
    
    init(session: URLSession) {
        self.session = session
    }
    
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
        session.dataTask(with: url) { _, _, error in
            if let error = error {
                completion(.failure(error))
            }
        }.resume()
    }
}

final class URLSessionHTTPClientTest: XCTestCase {

    func test_getFromURL_resumesDataTaskWithURL() {
        let url = URL(string: "https://a-url.com")!
        let session = URLSessionSpy()
        let sut = URLSessionHTTPClient(session: session)
        let task = URLSessionDataTaskSpy()
        session.stub(url: url, task: task)
        
        sut.get(from: url) { _ in }
        
        XCTAssertEqual(task.resumeCallCount, 1)
    }
    
    func test_getFromURL_failsOnRequestError() {
        let url = URL(string: "https://a-url.com")!
        let session = URLSessionSpy()
        let sut = URLSessionHTTPClient(session: session)
        let error = NSError(domain: "test", code: 0)
        session.stub(url: url, error: error)
        
        let exp = expectation(description: "Wait for completion")
        
        sut.get(from: url) { result in
            switch result {
            case let .failure(receivedError as NSError):
                XCTAssertEqual(receivedError, error)
                
            default:
                XCTFail("Expected failure with error \(error), got \(result) insted")
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
}

// MARK - Helpers

extension URLSessionHTTPClientTest {
    
    private class URLSessionSpy: URLSession {
        
        private struct Stub {
            let task: URLSessionDataTask
            let error: Error?
        }
        
        private var stubs: [URL: Stub] = [:]
        
        func stub(url: URL, task: URLSessionDataTask = FakeURLSessionDataTask(), error: Error? = nil) {
            stubs[url] = Stub(task: task, error: error)
        }
        
        override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
            
            guard let stub = stubs[url] else {
                fatalError("Couldn't find stub for \(url)")
            }
            
            completionHandler(nil, nil, stub.error)
            return stub.task
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
