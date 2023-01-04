//
//  HTTPClient.swift
//  EssentialFeed
//
//  Created by Aleksey Osadchy on 10.12.2022.
//

import Foundation


public protocol HTTPClient {
    typealias Result = Swift.Result<(Data, HTTPURLResponse), Error>
    
    func get(from url: URL, completion: @escaping (Result) -> Void)
}
