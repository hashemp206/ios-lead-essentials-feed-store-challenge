//
//  Feed.swift
//  Tests
//
//  Created by Hashem Aboonajmi on 8/19/20.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import CoreData
import FeedStoreChallenge

@objc(ManagedFeed)
internal class ManagedFeed: NSManagedObject {
    internal var local: [LocalFeedImage] {
        return (items.compactMap{ $0 as? ManagedFeedImage }).map { $0.local }
    }
}

extension ManagedFeed {

    @nonobjc internal class func fetchRequest() -> NSFetchRequest<ManagedFeed> {
        return NSFetchRequest<ManagedFeed>(entityName: "ManagedFeed")
    }

    @NSManaged internal var timestamp: Date
    @NSManaged internal var items: NSOrderedSet

    static func UniqueFeed(in context: NSManagedObjectContext) throws -> ManagedFeed {
        try context.fetch(ManagedFeed.fetchRequest()).first.map(context.delete)
        return ManagedFeed(context: context)
    }
}

// MARK: Generated accessors for items
extension ManagedFeed {

    @objc(addItems:)
    @NSManaged internal func addToItems(_ values: NSOrderedSet)

}
