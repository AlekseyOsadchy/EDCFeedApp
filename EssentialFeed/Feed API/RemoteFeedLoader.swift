//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Aleksey Osadchy on 07.12.2022.
//

import Foundation

public protocol HTTPClient {
    func get(from url: URL, completion: @escaping (Error) -> Void)
}

public final class RemoteFeedLoader {
    public typealias LoadCompletion = (Error) -> Void
    
    private let url: URL
    private let client: HTTPClient
    
    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    public func load(completion: @escaping LoadCompletion = { _ in }) {
        client.get(from: url) { error in
            completion(.connectivity)
        }
    }
}

public extension RemoteFeedLoader {
    
    enum Error: Swift.Error {
        case connectivity
    }
}
