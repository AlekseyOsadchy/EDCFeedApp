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
                
        XCTAssertNil(client.requestedURL)
    }
    
    func test_load_requestsDataFromURL() {
        let (sut, client) = makeSUT()
        
        sut.load()
        
        XCTAssertNotNil(client.requestedURL)
    }
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
        var requestedURL: URL?
        
        func get(from url: URL) {
            requestedURL = url
        }
    }
}
