//
//  LoadFeedFromCacheUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Aleksey Osadchy on 20.12.2022.
//

import XCTest
import EssentialFeed

final class LoadFeedFromCacheUseCaseTests: XCTestCase {
    
    func test_init_doesNotMessageUponCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.receivedMessages, [])
    }
    
    func test_load_requestCacheRetrieval() {
        let (sut, store) = makeSUT()
        
        sut.load() { _ in }
        
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_load_failsOnRetrieval() {
        let (sut, store) = makeSUT()
        let exp = expectation(description: "Wait for load completion")
        let retrievalError = anyNSError()
        
        var receivedError: Error?
        sut.load() { error in
            receivedError = error
            exp.fulfill()
        }
        
        store.completeRetrieval(with: retrievalError)
        
        wait(for: [exp], timeout: 1)
        
        XCTAssertEqual((receivedError as NSError?)?.domain, retrievalError.domain)
        XCTAssertEqual((receivedError as NSError?)?.code, retrievalError.code)
    }
}

// MARK: - Helpers

extension LoadFeedFromCacheUseCaseTests {
    
    private func makeSUT(currentDate: @escaping () -> Date = Date.init,
                         file: StaticString = #filePath,
                         line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        trackMemoryLeaks(store, file: file, line: line)
        trackMemoryLeaks(sut, file: file, line: line)
        return (sut, store)
    }
    
    private func anyNSError() -> NSError {
        return NSError(domain: "any error", code: 0)
    }
}
