//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Aleksey Osadchy on 07.12.2022.
//

import Foundation

public enum HTTPClientResult {
    case success(Data, HTTPURLResponse)
    case failure(Error)
}

public protocol HTTPClient {
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void)
}

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
                if let items = try? FeedItemMapper.map(data: data, response: response) {
                    completion(.success(items))
                } else {
                    completion(.failure(.invalidData))
                }
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

private class FeedItemMapper {
    
    private struct Root: Decodable {
        let items: [Item]
    }

    private struct Item: Decodable {
        let id: UUID
        let description: String?
        let location: String?
        let image: URL
        
        var item: FeedItem {
            return FeedItem(id: id, description: description, location: location, imageURL: image)
        }
    }
    
    static func map(data: Data, response: HTTPURLResponse) throws -> [FeedItem] {
        guard response.statusCode == 200 else { throw RemoteFeedLoader.Error.invalidData }
        return try JSONDecoder().decode(Root.self, from: data).items.map { $0.item }
    }
}
