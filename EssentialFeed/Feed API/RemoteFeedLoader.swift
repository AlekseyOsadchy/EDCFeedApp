//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Aleksey Osadchy on 07.12.2022.
//

import Foundation

public protocol HTTPClient {
    func get(from url: URL, completion: @escaping (Error?, HTTPURLResponse?) -> Void)
}

public final class RemoteFeedLoader {
    public typealias LoadCompletion = (Error) -> Void
    
    private let url: URL
    private let client: HTTPClient
    
    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    public func load(completion: @escaping LoadCompletion) {
        
        client.get(from: url) { error, response in
            
            if response != nil {
                completion(.invalidData)
            } else {
                completion(.connectivity)
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
