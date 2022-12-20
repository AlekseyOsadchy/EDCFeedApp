//
//  SharedTestHelpers.swift
//  EssentialFeedTests
//
//  Created by Aleksey Osadchy on 20.12.2022.
//

import Foundation

func anyURL() -> URL {
    return URL(string: "https://a-url.com")!
}

func anyNSError() -> NSError {
    return NSError(domain: "any error", code: 0)
}
