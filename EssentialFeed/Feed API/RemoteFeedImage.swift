//
//  RemoteFeedImage.swift
//  EssentialFeed
//
//  Created by Aleksey Osadchy on 19.12.2022.
//

import Foundation

struct RemoteFeedImage: Decodable {
    let id: UUID
    let description: String?
    let location: String?
    let image: URL
}
