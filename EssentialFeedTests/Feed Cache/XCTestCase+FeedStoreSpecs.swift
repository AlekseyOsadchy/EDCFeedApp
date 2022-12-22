//
//  XCTestCase+FeedStoreSpecs.swift
//  EssentialFeedTests
//
//  Created by Aleksey Osadchy on 22.12.2022.
//

import XCTest
import EssentialFeed

extension FeedStoreSpecs where Self: XCTestCase {
    
    @discardableResult
    func insert(_ cache: (feed: [LocalFeedImage], timestamp: Date), to sut: FeedStore) -> Error? {
        let exp = expectation(description: "Wait for insertion completion")
        
        var insertedError: Error?
        sut.insert(cache.feed, timestamp: cache.timestamp) { error in
            insertedError = error
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        return insertedError
    }

    @discardableResult
    func deleteCache(from sut: FeedStore) -> Error? {
        let exp = expectation(description: "Wait for deletion completion")
        var deletionError: Error?
        sut.deleteCachedFeed { error in
            deletionError = error
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 10.0)
        return deletionError
    }

    func expect(_ sut: FeedStore,
                toRetrieveTwice expectedResult: RetrieveCacheFeedResult,
                file: StaticString = #filePath,
                line: UInt = #line) {
        expect(sut, toRetrieve: expectedResult)
        expect(sut, toRetrieve: expectedResult)
    }

    func expect(_ sut: FeedStore,
                toRetrieve expectedResult: RetrieveCacheFeedResult,
                file: StaticString = #filePath,
                line: UInt = #line) {
        
        let exp = expectation(description: "Wait for cache retrieval")
        
        sut.retrieve { retrieveResult in
            switch (retrieveResult, expectedResult) {
            case (.empty, .empty),
                 (.failure, .failure):
                break
            case let (.found(rFeed, rTimestamp), .found(eFeed, eTimestamp)):
                XCTAssertEqual(rFeed, eFeed, file: file, line: line)
                XCTAssertEqual(rTimestamp, eTimestamp, file: file, line: line)
                
            default:
                XCTFail("Expect to retrieve \(expectedResult), got \(retrieveResult) instead", file: file, line: line)
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1)
    }
}
