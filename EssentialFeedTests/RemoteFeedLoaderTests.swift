//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Aleksey Osadchy on 06.12.2022.
//

import XCTest

class RemoteFeedLoader {
    
    
}

class HTTPClient {
    var requestedURL: URL?
}

final class RemoteFeedLoaderTests: XCTestCase {

    func test_init_doesNotRequestDataFromURL() {
        let client = HTTPClient()
        _ = RemoteFeedLoader()
                
        XCTAssertNil(client.requestedURL)
    }
}
