//
//  LocalFeedLoader.swift
//  EssentialFeed
//
//  Created by Aleksey Osadchy on 19.12.2022.
//

import Foundation

public final class LocalFeedLoader {
    public typealias TimestampProvider = () -> Date
    public typealias SaveCompletion = (SaveResult) -> Void
    public typealias RetrieveCompletion = (RetrieveResult) -> Void
    public typealias SaveResult = Error?
    public typealias RetrieveResult = LoadFeedResult
    
    let store: FeedStore
    let currentDate: TimestampProvider
    
    public init(store: FeedStore, currentDate: @escaping TimestampProvider) {
        
        self.store = store
        self.currentDate = currentDate
    }
    
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
    
    public func load(completion: @escaping RetrieveCompletion) {
        store.retrieve() { result in
            
            switch result {
            case let .failure(error):
                completion(.failure(error))
                
            case .empty:
                completion(.success([]))
                
            case let .found(feed, _):
                completion(.success(feed.toModels()))
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
