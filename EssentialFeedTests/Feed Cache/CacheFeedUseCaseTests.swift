//
//  CacheFeedUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Aleksey Osadchy on 16.12.2022.
//

import XCTest


class LocalFeedLoader {
    
    let store: FeedStore
    
    init(store: FeedStore) {
        
        self.store = store
    }
}

class FeedStore {
    var deleteCachedFeedCallCount: Int = 0
    
}

final class CacheFeedUseCaseTests: XCTestCase {
    
    func test_init_doesNotDeleteCacheUponCreation() {
        
        let store = FeedStore()
        _ = LocalFeedLoader(store: store)
        
        XCTAssertEqual(store.deleteCachedFeedCallCount, 0)
    }
}
