//
//  LocalFeedLoader.swift
//  EssentialFeed
//
//  Created by Aleksey Osadchy on 19.12.2022.
//

import Foundation

public final class LocalFeedLoader {
    public typealias TimestampProvider = () -> Date
    
    private let store: FeedStore
    private let currentDate: TimestampProvider
    
    public init(store: FeedStore, currentDate: @escaping TimestampProvider) {
        self.currentDate = currentDate
        self.store = store
    }
}
 
extension LocalFeedLoader {
    public typealias SaveResult = Error?
    public typealias SaveCompletion = (SaveResult) -> Void
    
    public func save(_ feed: [FeedImage], completion: @escaping SaveCompletion) {
        store.deleteCachedFeed { [weak self] error in
            guard let self = self else { return }
            if let cacheDeletionError = error {
                completion(cacheDeletionError)
            } else {
                self.cache(feed, completion: completion)
            }
        }
    }
    
    private func cache(_ feed: [FeedImage], completion: @escaping SaveCompletion) {
        store.insert(feed.toLocal(), timestamp: currentDate()) { [weak self] error in
            guard self != nil else { return }
            completion(error)
        }
    }
}

extension LocalFeedLoader: FeedLoader {
    public typealias RetrieveCompletion = (RetrieveResult) -> Void
    public typealias RetrieveResult = FeedLoader.Result
    
    public func load(completion: @escaping RetrieveCompletion) {
        store.retrieve() { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case let .failure(error):
                completion(.failure(error))
                
            case let .success(.some(cachedFeed)) where FeedCachePolicy.validate(cachedFeed.timestamp, against: self.currentDate()):
                completion(.success(cachedFeed.feed.toModels()))
                
            case .success:
                completion(.success([]))
            }
        }
    }
}

extension LocalFeedLoader {
    
    public func validateCache() {
        store.retrieve { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .failure:
                self.store.deleteCachedFeed(completion: { _ in })
                
            case let .success(.some(cachedFeed)) where !FeedCachePolicy.validate(cachedFeed.timestamp, against: self.currentDate()):
                self.store.deleteCachedFeed(completion: { _ in })
                
            case .success:
                break
            }
        }
    }
}

private extension Array where Element == FeedImage {
    func toLocal() -> [LocalFeedImage] {
        return map { LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url) }
    }
}

private extension Array where Element == LocalFeedImage {
    func toModels() -> [FeedImage] {
        return map { FeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url) }
    }
}
