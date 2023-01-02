//
//  EssentialFeedCacheIntegrationTests.swift
//  EssentialFeedCacheIntegrationTests
//
//  Created by Aleksey Osadchy on 02.01.2023.
//

import XCTest
import EssentialFeed

final class EssentialFeedCacheIntegrationTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
        setupEmptyStoreState()
    }
    
    override func tearDown() {
        super.tearDown()
        
        undoStoreSideEffects()
    }

    func test_load_deliversNoItemsOnEmptyCache() {
        let sut = makeSUT()
        
        expect(sut, toCompleteWith: .success([])) {  }
    }
    
    func test_load_deliversItemsSavedOnASeparateInstance() {
        let sutToPerformSave = makeSUT()
        let sutToPerformLoad = makeSUT()
        let feed = uniqueImageFeed().models
        
        save(feed, to: sutToPerformSave)
        expect(sutToPerformLoad, toCompleteWith: .success(feed)) {  }
    }
    
    func test_save_overridesItemsSavedOnASeparateInstance() {
        let sutToPerformFirstSave = makeSUT()
        let sutToPerformSecondSave = makeSUT()
        let sutToPerformLoad = makeSUT()
        let firstFeed = uniqueImageFeed().models
        let secondFeed = uniqueImageFeed().models
        
        save(firstFeed, to: sutToPerformFirstSave)
        save(secondFeed, to: sutToPerformSecondSave)
        expect(sutToPerformLoad, toCompleteWith: .success(secondFeed)) {}
    }
 }

// MARK: - Helpers

private extension EssentialFeedCacheIntegrationTests {
    
    func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> LocalFeedLoader {
        let storeBundle = Bundle(for: CoreDataFeedStore.self)
        let storeURL = testSpecificStoreURL()
        let store = try! CoreDataFeedStore(storeURL: storeURL, bundle: storeBundle)
        let sut = LocalFeedLoader(store: store, currentDate: Date.init)
        trackMemoryLeaks(store, file: file, line: line)
        trackMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    private func expect(_ sut: LocalFeedLoader,
                        toCompleteWith expectedResult: LocalFeedLoader.RetrieveResult,
                        when action: () -> Void,
                        file: StaticString = #filePath,
                        line: UInt = #line) {
        
        let exp = expectation(description: "Wait for load completion")
        
        sut.load() { retrieveResult in
            switch (retrieveResult, expectedResult) {
            case let (.success(images), .success(expectedImages)):
                XCTAssertEqual(images, expectedImages, file: file, line: line)
            case let (.failure(error as NSError), .failure(expectedError as NSError)):
                XCTAssertEqual(error.domain, expectedError.domain, file: file, line: line)
                XCTAssertEqual(error.code, expectedError.code, file: file, line: line)
            default:
                XCTFail("Expect \(expectedResult), got \(expectedResult) instead", file: file, line: line)
            }
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1)
    }
    
    func save(_ feed: [FeedImage], to loader: LocalFeedLoader, file: StaticString = #filePath, line: UInt = #line) {
        
        let exp = expectation(description: "Wait for save completion")
        loader.save(feed) { saveError in
            XCTAssertNil(saveError, "Expected to saveFeedSuccessfully", file: file, line: line)
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func testSpecificStoreURL() -> URL {
        return cacheDirectory().appendingPathExtension("\(type(of: self)).store")
    }
    
    func cacheDirectory() -> URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }
    
    func undoStoreSideEffects() {
        deleteStoreArtifacts()
    }
    
    func setupEmptyStoreState() {
        deleteStoreArtifacts()
    }
    
    func deleteStoreArtifacts() {
        try? FileManager.default.removeItem(at: testSpecificStoreURL())
    }
}
