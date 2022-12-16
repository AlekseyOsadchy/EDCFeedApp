//
//  CacheFeedUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Aleksey Osadchy on 16.12.2022.
//

import XCTest
import EssentialFeed

class LocalFeedLoader {
    
    let store: FeedStore
    
    init(store: FeedStore) {
        
        self.store = store
    }
    
    func save(_ items: [FeedItem]) {
        store.deleteCachedFeed()
    }
}

class FeedStore {
    var deleteCachedFeedCallCount: Int = 0
    
    func deleteCachedFeed() {
        deleteCachedFeedCallCount += 1
    }
}

final class CacheFeedUseCaseTests: XCTestCase {
    
    func test_init_doesNotDeleteCacheUponCreation() {
        let store = FeedStore()
        _ = LocalFeedLoader(store: store)
        
        XCTAssertEqual(store.deleteCachedFeedCallCount, 0)
    }
    
    func test_save_requestCacheDeletion() {
        let store = FeedStore()
        let sut = LocalFeedLoader(store: store)
        let items = [uniqueItem(), uniqueItem()]
        sut.save(items)
        
        XCTAssertEqual(store.deleteCachedFeedCallCount, 1)
    }
}

// MARK: - Helpers

extension CacheFeedUseCaseTests {
    
    private func anyURL() -> URL {
        return URL(string: "https://a-url.com")!
    }
    
    private func uniqueItem() -> FeedItem {
        return FeedItem(id: UUID(), description: nil, location: nil, imageURL: anyURL())
    }
}
