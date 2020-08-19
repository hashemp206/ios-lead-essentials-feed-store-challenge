//
//  Feed.swift
//  Tests
//
//  Created by Hashem Aboonajmi on 8/19/20.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import CoreData
import FeedStoreChallenge

@objc(Feed)
internal class Feed: NSManagedObject {
    internal var local: [LocalFeedImage] {
        return (items.compactMap{ $0 as? FeedImage }).map { $0.local }
    }
}

extension Feed {

    @nonobjc internal class func fetchRequest() -> NSFetchRequest<Feed> {
        return NSFetchRequest<Feed>(entityName: "Feed")
    }

    @NSManaged internal var timestamp: Date
    @NSManaged internal var items: NSOrderedSet

    static func UniqueFeed(in context: NSManagedObjectContext) throws -> Feed {
        try context.fetch(Feed.fetchRequest()).first.map(context.delete)
        return Feed(context: context)
    }
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
