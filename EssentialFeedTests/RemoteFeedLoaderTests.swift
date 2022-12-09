//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Aleksey Osadchy on 06.12.2022.
//

import XCTest
import EssentialFeed

final class RemoteFeedLoaderTests: XCTestCase {

    func test_init_doesNotRequestDataFromURL() {
        let (_, client) = makeSUT()
                
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    func test_load_requestsDataFromURL() {
        let url = URL(string: "https://www.google.com")!
        let (sut, client) = makeSUT(url: url)
        
        sut.load()
        
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_loadTwice_requestsDataFromURLTwice() {
        let url = URL(string: "https://www.google.com")!
        let (sut, client) = makeSUT(url: url)
        
        sut.load()
        sut.load()
        
        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    func test_load_deliversErrorOnClientError() {
        
        let (sut, client) = makeSUT()
        
        var captureError: [RemoteFeedLoader.Error] = []
        sut.load { captureError.append($0) }
        
        let clientError = NSError(domain: "Test", code: 0)
        client.complete(with: clientError)
        
        XCTAssertEqual(captureError, [.connectivity])
    }
    
//    func test_load_deliversErrorOnNon200HTTPResponse() {
//
//        let (sut, client) = makeSUT()
//
//        client.complete(withStatusCode: 400)
//
//        var captureError: [RemoteFeedLoader.Error] = []
//        sut.load { captureError.append($0) }
//
//        XCTAssertEqual(captureError, [.invalidData])
//    }
}

// MARK: - Helpers

extension RemoteFeedLoaderTests {
    
    private func makeSUT(url: URL = URL(string: "https://www.google.com")!) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        return (RemoteFeedLoader(url: url, client: client), client)
    }
}

extension RemoteFeedLoaderTests {
    
    class HTTPClientSpy: HTTPClient {
        
        var messages: [(url: URL, completion: (Error) -> Void)] = []
        
        var requestedURLs: [URL] {
            return messages.map { $0.url }
        }
        
        func get(from url: URL, completion: @escaping (Error) -> Void) {
            messages.append((url, completion))
        }
        
        func complete(with error: Error, at index: Int = 0) {
            messages[index].completion(error)
        }
    }
}
