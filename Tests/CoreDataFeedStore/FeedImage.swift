//
//  FeedImage.swift
//  Tests
//
//  Created by Hashem Aboonajmi on 8/19/20.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import CoreData
import FeedStoreChallenge

@objc(FeedImage)
internal class FeedImage: NSManagedObject {
    var local: LocalFeedImage {
        return LocalFeedImage(id: id, description: descriptions, location: location, url: url)
    }
}

extension FeedImage {

    @nonobjc internal class func fetchRequest() -> NSFetchRequest<FeedImage> {
        return NSFetchRequest<FeedImage>(entityName: "FeedImage")
    }

    @NSManaged internal var descriptions: String?
    @NSManaged internal var id: UUID
    @NSManaged internal var location: String?
    @NSManaged internal var url: URL

}
