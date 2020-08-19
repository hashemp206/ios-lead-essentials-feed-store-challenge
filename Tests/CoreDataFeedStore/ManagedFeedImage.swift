//
//  FeedImage.swift
//  Tests
//
//  Created by Hashem Aboonajmi on 8/19/20.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import CoreData
import FeedStoreChallenge

@objc(ManagedFeedImage)
internal class ManagedFeedImage: NSManagedObject {
    var local: LocalFeedImage {
        return LocalFeedImage(id: id, description: descriptions, location: location, url: url)
    }
}

extension ManagedFeedImage {

    @nonobjc internal class func fetchRequest() -> NSFetchRequest<ManagedFeedImage> {
        return NSFetchRequest<ManagedFeedImage>(entityName: "ManagedFeedImage")
    }

    @NSManaged internal var descriptions: String?
    @NSManaged internal var id: UUID
    @NSManaged internal var location: String?
    @NSManaged internal var url: URL

}
