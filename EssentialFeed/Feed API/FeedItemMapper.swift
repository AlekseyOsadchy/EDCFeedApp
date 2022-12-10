//
//  FeedItemMapper.swift
//  EssentialFeed
//
//  Created by Aleksey Osadchy on 10.12.2022.
//

import Foundation

internal final class FeedItemMapper {
    
    enum StatusCode {
        static let ok = 200
    }
    
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
    
    internal static func map(data: Data, response: HTTPURLResponse) throws -> [FeedItem] {
        guard response.statusCode == StatusCode.ok else { throw RemoteFeedLoader.Error.invalidData }
        return try JSONDecoder().decode(Root.self, from: data).items.map { $0.item }
    }
}
