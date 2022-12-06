//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Aleksey Osadchy on 06.12.2022.
//

import Foundation

typealias LoadFeedResult = Result<[FeedItem], Error>

protocol FeedLoader {
    
    func load(completion: @escaping (LoadFeedResult) -> Void)
}
