//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Aleksey Osadchy on 06.12.2022.
//

import Foundation

public enum LoadFeedResult {
    case success([FeedImage])
    case failure(Error)
}

public protocol FeedLoader {
    func load(completion: @escaping (LoadFeedResult) -> Void)
}
