//
//  HTTPClient.swift
//  EssentialFeed
//
//  Created by Aleksey Osadchy on 10.12.2022.
//

import Foundation

public enum HTTPClientResult {
    case success(Data, HTTPURLResponse)
    case failure(Error)
}

public protocol HTTPClient {
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void)
}
