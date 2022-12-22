//
//  FeedStoreSpecs.swift
//  EssentialFeedTests
//
//  Created by Aleksey Osadchy on 22.12.2022.
//

import Foundation

protocol FeedStoreSpecs {
    func test_retrieve_deliversEmptyOnEmptyCache()
    func test_retrieve_hasNoSideEffectsOnEmptyCache()
    func test_retrieve_deliversFoundOnNonEmptyCache()
    func test_retrieve_withOnSideEffectsOnNonEmptyCache()

    func test_insert_overridesPreviouslyInsertedCacheValues()

    func test_delete_hasNoSideEffectsOnEmptyCache()
    func test_delete_emptiesPreviouslyInsertionCache()
    
    func test_storeSideEffects_runSerially()
}

protocol FailableRetrieveFeedStoreSpec {
    func test_retrieve_deliversFailureOnRetrievalError()
    func test_retrieve_hasNoSideEffectOnFailure()
}

protocol FailableInsertFeedSpec {
    func test_insert_deliversErrorOnInsertionError()
    func test_insert_hasNoSideEffetsOnInsertionError()
}

protocol FailableDeleteFeedSpec {
    func test_delete_deliversErrorOnDeletionError()
    func test_delete_hasNoSideEffectsOnDeletionError()
}
