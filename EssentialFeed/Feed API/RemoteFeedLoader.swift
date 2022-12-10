//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Aleksey Osadchy on 07.12.2022.
//

import Foundation

public final class RemoteFeedLoader {
    public typealias LoadCompletion = (Result) -> Void
    
    private let url: URL
    private let client: HTTPClient
    
    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    public func load(completion: @escaping LoadCompletion) {
        
        client.get(from: url) { result in
            switch result {
            case let .success(data, response):
                completion(FeedItemsMapper.map(data, from: response))
            case .failure:
                completion(.failure(.connectivity))
            }
        }
    }
}

public extension RemoteFeedLoader {
    
    enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
}

public extension RemoteFeedLoader {
    
    enum Result: Equatable {
        case success([FeedItem])
        case failure(Error)
    }
}
