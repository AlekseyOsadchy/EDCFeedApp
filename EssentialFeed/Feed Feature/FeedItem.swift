//
//  FeedItem.swift
//  EssentialFeed
//
//  Created by Aleksey Osadchy on 06.12.2022.
//

import Foundation

public struct FeedItem: Equatable {
    
    let id: UUID
    let description: String?
    let location: String?
    let imageURL: URL
}
