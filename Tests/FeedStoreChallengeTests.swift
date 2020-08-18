//
//  Copyright © 2019 Essential Developer. All rights reserved.
//

import XCTest
import CoreData
import FeedStoreChallenge

@objc(Feed)
internal class Feed: NSManagedObject {
    internal var local: [LocalFeedImage] {
        return (items!.array as! [FeedImage]).map { $0.local }
    }
}

extension Feed {

    @nonobjc internal class func fetchRequest() -> NSFetchRequest<Feed> {
        return NSFetchRequest<Feed>(entityName: "Feed")
    }

    @NSManaged internal var timestamp: Date?
    @NSManaged internal var items: NSOrderedSet?

}

// MARK: Generated accessors for items
extension Feed {

    @objc(insertObject:inItemsAtIndex:)
    @NSManaged internal func insertIntoItems(_ value: FeedImage, at idx: Int)

    @objc(removeObjectFromItemsAtIndex:)
    @NSManaged internal func removeFromItems(at idx: Int)

    @objc(insertItems:atIndexes:)
    @NSManaged internal func insertIntoItems(_ values: [FeedImage], at indexes: NSIndexSet)

    @objc(removeItemsAtIndexes:)
    @NSManaged internal func removeFromItems(at indexes: NSIndexSet)

    @objc(replaceObjectInItemsAtIndex:withObject:)
    @NSManaged internal func replaceItems(at idx: Int, with value: FeedImage)

    @objc(replaceItemsAtIndexes:withItems:)
    @NSManaged internal func replaceItems(at indexes: NSIndexSet, with values: [FeedImage])

    @objc(addItemsObject:)
    @NSManaged internal func addToItems(_ value: FeedImage)

    @objc(removeItemsObject:)
    @NSManaged internal func removeFromItems(_ value: FeedImage)

    @objc(addItems:)
    @NSManaged internal func addToItems(_ values: NSOrderedSet)

    @objc(removeItems:)
    @NSManaged internal func removeFromItems(_ values: NSOrderedSet)

}


@objc(FeedImage)
internal class FeedImage: NSManagedObject {
    var local: LocalFeedImage {
        return LocalFeedImage(id: id!, description: descriptions, location: location, url: url!)
    }
}

extension FeedImage {

    @nonobjc internal class func fetchRequest() -> NSFetchRequest<FeedImage> {
        return NSFetchRequest<FeedImage>(entityName: "FeedImage")
    }

    @NSManaged internal var descriptions: String?
    @NSManaged internal var id: UUID?
    @NSManaged internal var location: String?
    @NSManaged internal var url: URL?

}


class CoreDataFeedStore: FeedStore {
    
    private let container: NSPersistentContainer
    
    init(storeURL: URL) {
        let modelURL = Bundle(for: type(of: self)).url(forResource: "FeedModel", withExtension: "momd")!

        let model = NSManagedObjectModel(contentsOf: modelURL)!
        let container = NSPersistentContainer(name: "CoreDataFeedStore", managedObjectModel: model)
        let description = NSPersistentStoreDescription(url: storeURL)
        container.persistentStoreDescriptions = [description]
        container.loadPersistentStores { storeDescription, error in
            if let error = error {
                print("Unresolved error \(error)")
            }
        }
        
        self.container = container
    }
    
    func retrieve(completion: @escaping FeedStore.RetrievalCompletion) {
        let managedObjectContext = container.viewContext
        if let coredataFeed: Feed = try! managedObjectContext.fetch(Feed.fetchRequest()).first, let items = coredataFeed.items, items.array.isEmpty == false {
            let coredataItems = items.array as! [FeedImage]
        
            completion(.found(feed: coredataItems.map{ $0.local }, timestamp: coredataFeed.timestamp!))
            
        } else {
            completion(.empty)
        }
        
        
    }
    
    func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        fatalError("Must implemented")
    }
    
    func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        
        let managedObjectContext = container.viewContext
        let coredataFeed = Feed(context: managedObjectContext)
        coredataFeed.timestamp = timestamp
        let coredataFeedImages = feed.map { localFeedImage -> FeedImage in
            let item = FeedImage(context: managedObjectContext)
            item.id = localFeedImage.id
            item.descriptions = localFeedImage.description
            item.location = localFeedImage.location
            item.url = localFeedImage.url
            return item
        }
        
        coredataFeed.addToItems(NSOrderedSet(array: coredataFeedImages))
        
        try! managedObjectContext.save()
        completion(.none)
    }
}

class FeedStoreChallengeTests: XCTestCase, FeedStoreSpecs {
	
//
//   We recommend you to implement one test at a time.
//   Uncomment the test implementations one by one.
// 	 Follow the process: Make the test pass, commit, and move to the next one.
//

	func test_retrieve_deliversEmptyOnEmptyCache() {
		let sut = makeSUT()

		assertThatRetrieveDeliversEmptyOnEmptyCache(on: sut)
	}

	func test_retrieve_hasNoSideEffectsOnEmptyCache() {
		let sut = makeSUT()

		assertThatRetrieveHasNoSideEffectsOnEmptyCache(on: sut)
	}

	func test_retrieve_deliversFoundValuesOnNonEmptyCache() {
		let sut = makeSUT()

		assertThatRetrieveDeliversFoundValuesOnNonEmptyCache(on: sut)
	}

	func test_retrieve_hasNoSideEffectsOnNonEmptyCache() {
//		let sut = makeSUT()
//
//		assertThatRetrieveHasNoSideEffectsOnNonEmptyCache(on: sut)
	}

	func test_insert_deliversNoErrorOnEmptyCache() {
//		let sut = makeSUT()
//
//		assertThatInsertDeliversNoErrorOnEmptyCache(on: sut)
	}

	func test_insert_deliversNoErrorOnNonEmptyCache() {
//		let sut = makeSUT()
//
//		assertThatInsertDeliversNoErrorOnNonEmptyCache(on: sut)
	}

	func test_insert_overridesPreviouslyInsertedCacheValues() {
//		let sut = makeSUT()
//
//		assertThatInsertOverridesPreviouslyInsertedCacheValues(on: sut)
	}

	func test_delete_deliversNoErrorOnEmptyCache() {
//		let sut = makeSUT()
//
//		assertThatDeleteDeliversNoErrorOnEmptyCache(on: sut)
	}

	func test_delete_hasNoSideEffectsOnEmptyCache() {
//		let sut = makeSUT()
//
//		assertThatDeleteHasNoSideEffectsOnEmptyCache(on: sut)
	}

	func test_delete_deliversNoErrorOnNonEmptyCache() {
//		let sut = makeSUT()
//
//		assertThatDeleteDeliversNoErrorOnNonEmptyCache(on: sut)
	}

	func test_delete_emptiesPreviouslyInsertedCache() {
//		let sut = makeSUT()
//
//		assertThatDeleteEmptiesPreviouslyInsertedCache(on: sut)
	}

	func test_storeSideEffects_runSerially() {
//		let sut = makeSUT()
//
//		assertThatSideEffectsRunSerially(on: sut)
	}
	
	// - MARK: Helpers
	
	private func makeSUT() -> FeedStore {
        let blackHoleURL = URL(fileURLWithPath: "/dev/null")
        let sut = CoreDataFeedStore(storeURL: blackHoleURL)
        trackForMemoryLeaks(sut)
        return sut
	}
	
}

//
// Uncomment the following tests if your implementation has failable operations.
// Otherwise, delete the commented out code!
//

//extension FeedStoreChallengeTests: FailableRetrieveFeedStoreSpecs {
//
//	func test_retrieve_deliversFailureOnRetrievalError() {
////		let sut = makeSUT()
////
////		assertThatRetrieveDeliversFailureOnRetrievalError(on: sut)
//	}
//
//	func test_retrieve_hasNoSideEffectsOnFailure() {
////		let sut = makeSUT()
////
////		assertThatRetrieveHasNoSideEffectsOnFailure(on: sut)
//	}
//
//}

//extension FeedStoreChallengeTests: FailableInsertFeedStoreSpecs {
//
//	func test_insert_deliversErrorOnInsertionError() {
////		let sut = makeSUT()
////
////		assertThatInsertDeliversErrorOnInsertionError(on: sut)
//	}
//
//	func test_insert_hasNoSideEffectsOnInsertionError() {
////		let sut = makeSUT()
////
////		assertThatInsertHasNoSideEffectsOnInsertionError(on: sut)
//	}
//
//}

//extension FeedStoreChallengeTests: FailableDeleteFeedStoreSpecs {
//
//	func test_delete_deliversErrorOnDeletionError() {
////		let sut = makeSUT()
////
////		assertThatDeleteDeliversErrorOnDeletionError(on: sut)
//	}
//
//	func test_delete_hasNoSideEffectsOnDeletionError() {
////		let sut = makeSUT()
////
////		assertThatDeleteHasNoSideEffectsOnDeletionError(on: sut)
//	}
//
//}
