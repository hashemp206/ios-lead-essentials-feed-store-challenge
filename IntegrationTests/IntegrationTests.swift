//
//  IntegrationTests.swift
//  IntegrationTests
//
//  Created by Hashem Aboonajmi on 8/20/20.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import XCTest
import FeedStoreChallenge

class IntegrationTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        setupEmptyStoreState()
    }
    
    override func tearDown() {
        undoStoreSideEffects()
        super.tearDown()
    }
    
    func test_coreDataPersistsFeedDataAcrossAppLaunches() {
        let firstAppLaunchSUT = makeSUT()
        let secondAppLaunchSUT = makeSUT()
        let feed = uniqueImageFeed()
        
        insert(feed: feed, with: firstAppLaunchSUT)

        expec(with: secondAppLaunchSUT, toLoad: feed)
    }
    
    // MARK: - Helpers
    
    private func makeSUT() -> FeedStore {
        let blackHoleURL = testSpecificStoreURL()
        let sut = CoreDataFeedStore(storeURL: blackHoleURL)
        trackForMemoryLeaks(sut)
        return sut
    }
    
    private func insert(feed: [LocalFeedImage], with store: FeedStore, file: StaticString = #file, line: UInt = #line) {
        let expec = expectation(description: "should save feed")
        store.insert(feed, timestamp: Date()) { error in
           XCTAssertNil(error, "error saving feed", file: file, line: line)
           expec.fulfill()
        }
        wait(for: [expec], timeout: 1.0)
    }
    
    private func expec(with store: FeedStore, toLoad expectedFeed: [LocalFeedImage], file: StaticString = #file, line: UInt = #line) {
        let expec = expectation(description: "should retrieve feed")
        store.retrieve { result in
            switch result {
            case .empty:
                XCTAssertEqual(expectedFeed, [], "feed sould be empty")
            case .failure(let error):
                XCTAssertNil(error, "error retrieving feed")
            case .found(let loadedFeed, _):
                XCTAssertEqual(loadedFeed, expectedFeed, "feed should be found")
            }
            expec.fulfill()
        }

        wait(for: [expec], timeout: 1.0)
    }
    
    func uniqueImageFeed() -> [LocalFeedImage] {
        return [uniqueImage(), uniqueImage()]
    }
    
    func uniqueImage() -> LocalFeedImage {
        return LocalFeedImage(id: UUID(), description: "any", location: "any", url: anyURL())
    }
    
    func anyURL() -> URL {
        return URL(string: "http://any-url.com")!
    }
    
    private func setupEmptyStoreState() {
        deleteStoreDataBase()
    }
    
    private func undoStoreSideEffects() {
        deleteStoreDataBase()
    }
    
    private func deleteStoreDataBase() {
        try? FileManager.default.removeItem(at: testSpecificStoreURL())
    }
    
    private func testSpecificStoreURL() -> URL {
        return cachesDirectory().appendingPathComponent("feedDatabase.store")
    }

    private func cachesDirectory() -> URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }
}
