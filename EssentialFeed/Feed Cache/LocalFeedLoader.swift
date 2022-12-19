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
    public typealias SaveResult = Error?
    
    let store: FeedStore
    let currentDate: TimestampProvider
    
    public init(store: FeedStore, currentDate: @escaping TimestampProvider) {
        
        self.store = store
        self.currentDate = currentDate
    }
    
    public func save(_ items: [FeedItem], completion: @escaping SaveCompletion) {
        store.deleteCachedFeed { [weak self] error in
            guard let self = self else { return }
            if let cacheDeletionError = error {
                completion(cacheDeletionError)
            } else {
                self.cache(items, completion: completion)
            }
        }
    }
    
    private func cache(_ items: [FeedItem], completion: @escaping SaveCompletion) {
        store.insert(items.toLocal(), timestamp: currentDate()) { [weak self] error in
            guard self != nil else { return }
            completion(error)
        }
    }
}

private extension Array where Element == FeedItem {
    func toLocal() -> [LocalFeedItem] {
        return map { LocalFeedItem(id: $0.id, description: $0.description, location: $0.location, imageURL: $0.imageURL) }
    }
}
