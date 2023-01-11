//
//  FeedItemsMapper.swift
//  EssentialFeed
//
//  Created by Aleksey Osadchy on 10.12.2022.
//

import Foundation

internal final class FeedItemsMapper {
    
    enum StatusCode {
        static let ok = 200
    }
    
    private struct Root: Decodable {
        let items: [RemoteFeedImage]
    }
    
    internal static func map(_ data: Data, from response: HTTPURLResponse) throws -> [RemoteFeedImage] {
        guard response.statusCode == StatusCode.ok,
              let root = try? JSONDecoder().decode(Root.self, from: data) else {
            throw RemoteFeedLoader.Error.invalidData
        }
        
        return root.items
    }
}
