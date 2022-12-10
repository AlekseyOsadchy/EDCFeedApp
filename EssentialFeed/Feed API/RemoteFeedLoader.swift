//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Aleksey Osadchy on 07.12.2022.
//

import Foundation

public final class RemoteFeedLoader {
    public typealias Result = LoadFeedResult<Error>
    public typealias LoadCompletion = (Result) -> Void
    
    private let url: URL
    private let client: HTTPClient
    
    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    public func load(completion: @escaping LoadCompletion) {
        
        client.get(from: url) { [weak self] result in
            guard self != nil else { return }
            
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
