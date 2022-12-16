//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Aleksey Osadchy on 06.12.2022.
//

import XCTest
import EssentialFeed

final class LoadFeedFromRemoteUseCaseTests: XCTestCase {
    typealias VoidClosure = () -> Void
    
    func test_init_doesNotRequestDataFromURL() {
        let (_, client) = makeSUT()
                
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    func test_load_requestsDataFromURL() {
        let url = URL(string: "https://www.google.com")!
        let (sut, client) = makeSUT(url: url)
        
        sut.load { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_loadTwice_requestsDataFromURLTwice() {
        let url = URL(string: "https://www.google.com")!
        let (sut, client) = makeSUT(url: url)
        
        sut.load { _ in }
        sut.load { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    func test_load_deliversErrorOnClientError() {
        
        let (sut, client) = makeSUT()
        
        expect(sut: sut, toCompleteWith: failure(.connectivity), when: {
            let clientError = NSError(domain: "Test", code: 0)
            client.complete(with: clientError)
        })
    }
    
    func test_load_deliversErrorOnNon200HTTPResponse() {
        
        let (sut, client) = makeSUT()
        
        let samples = [199, 201, 300, 400, 500]
        
        samples.enumerated().forEach { index, code in
            expect(sut: sut, toCompleteWith: failure(.invalidData), when: {
                let jsonData = makeItemsJSON()
                client.complete(withStatusCode: code, data: jsonData, at: index)
            })
        }
    }
    
    func test_load_deliversErrorOn200ResponseWithInvalidData() {
        let (sut, client) = makeSUT()
        
        expect(sut: sut, toCompleteWith: failure(.invalidData), when: {
            let invalidJSON = Data("invalid json".utf8)
            client.complete(withStatusCode: 200, data: invalidJSON)
        })
    }
    
    func text_load_deliversNoItemsOn200HTTPResponseWithEmptyJSONList() {
        let (sut, client) = makeSUT()
        
        expect(sut: sut, toCompleteWith: .success([]), when: {
            let emptyListJson = Data("{\"items\": []}".utf8)
            client.complete(withStatusCode: 200, data: emptyListJson)
        })
    }
    
    func test_load_deliversNoItemsOn200HTTPResponseWithJSONItems() {
        let (sut, client) = makeSUT()
        
        let item1 = makeItem(id: UUID(), description: "Item 1", imageURL: URL(string: "https://www.google.com")!)
        let item2 = makeItem(id: UUID(), location: "Location 2", imageURL: URL(string: "https://www.google.com")!)
    
        let items = [item1.model, item2.model]
        
        expect(sut: sut, toCompleteWith: .success(items), when: {
            let jsonData = makeItemsJSON(item1.json, item2.json)
            client.complete(withStatusCode: 200, data: jsonData)
        })
    }
    
    func test_load_doesNotDeliversResultAfterSUTInstanceHasBeenDeallocated() {
        let client = HTTPClientSpy()
        var sut: RemoteFeedLoader? = RemoteFeedLoader(url: URL(string: "https://a-url.com")!, client: client)
        
        var captureResults: [RemoteFeedLoader.Result] = []
        sut?.load { captureResults.append($0) }
        
        sut = nil
        client.complete(withStatusCode: 200, data: makeItemsJSON())
        
        XCTAssertTrue(captureResults.isEmpty)
    }
}

// MARK: - Helpers

extension LoadFeedFromRemoteUseCaseTests {
    
    private func makeSUT(url: URL = URL(string: "https://www.google.com")!,
                         file: StaticString = #filePath,
                         line: UInt = #line) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
        
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        
        trackMemoryLeaks(sut, file: file, line: line)
        trackMemoryLeaks(client, file: file, line: line)
        
        return (sut, client)
    }
    
    private func makeItem(id: UUID,
                          description: String? = nil,
                          location: String? = nil,
                          imageURL: URL) -> (model: FeedItem, json: [String: Any]) {
        
        let item = FeedItem(id: id, description: description, location: location, imageURL: imageURL)
        let json: [String: Any] = ["id": item.id.uuidString,
                                   "description": item.description as Any,
                                   "location": item.location as Any,
                                   "image": item.imageURL.absoluteString]
        return (item, json)
    }
    
    private func makeItemsJSON(_ items: [String: Any]...) -> Data {
        let json: [String: Any] = ["items": items]
        return try! json.data()
    }
    
    private func expect(sut: RemoteFeedLoader,
                        toCompleteWith expectedResult: RemoteFeedLoader.Result,
                        when action: VoidClosure,
                        file: StaticString = #filePath,
                        line: UInt = #line) {
        
        let exp = expectation(description: "Wait for completion")
        sut.load { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedItems), .success(expectedItems)):
                XCTAssertEqual(receivedItems, expectedItems, file: file, line: line)
                
            case let (.failure(receivedError as RemoteFeedLoader.Error), .failure(expectedError as RemoteFeedLoader.Error)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
                
            default:
                XCTFail("Expected result \(expectedResult) got \(receivedResult) instead", file: file, line: line)
            }
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func failure(_ error: RemoteFeedLoader.Error) -> RemoteFeedLoader.Result {
        return .failure(error)
    }
}

extension LoadFeedFromRemoteUseCaseTests {
    
    class HTTPClientSpy: HTTPClient {
        typealias ResponseCompletion = (HTTPClientResult) -> Void
        
        var messages: [(url: URL, completion: ResponseCompletion)] = []
        
        var requestedURLs: [URL] {
            return messages.map { $0.url }
        }
        
        func get(from url: URL, completion: @escaping ResponseCompletion) {
            messages.append((url, completion))
        }
        
        func complete(with error: Error, at index: Int = 0) {
            messages[index].completion(.failure(error))
        }
        
        func complete(withStatusCode code: Int,
                      data: Data,
                      at index: Int = 0) {
            
            let response = HTTPURLResponse(url: requestedURLs[index],
                                           statusCode: code,
                                           httpVersion: nil,
                                           headerFields: nil)!
            messages[index].completion(.success(data, response))
        }
    }
}

extension Encodable {
    
    var asParameters: [String: Any]? {
        
        guard let data = try? JSONEncoder().encode(self) else {
            return nil
        }
        return (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)).flatMap { $0 as? [String: Any] }
    }
}

extension Dictionary where Key == String, Value == Any {
    
    func data() throws -> Data {
        return try JSONSerialization.data(withJSONObject: self)
    }
}
