//
//  CoreDataFeedStore.swift
//  Tests
//
//  Created by Hashem Aboonajmi on 8/19/20.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import CoreData

// MARK: - Managed Object Entities

@objc(ManagedFeed)
private class ManagedFeed: NSManagedObject {
    
    internal var local: [LocalFeedImage] {
        return (items.compactMap{ $0 as? ManagedFeedImage }).map { $0.local }
    }
}

extension ManagedFeed {

    @nonobjc internal class func fetchRequest() -> NSFetchRequest<ManagedFeed> {
        return NSFetchRequest<ManagedFeed>(entityName: "ManagedFeed")
    }

    internal class func managedFeedImages(from feed: [LocalFeedImage], context: NSManagedObjectContext) -> [ManagedFeedImage] {
       return feed.map { localFeedImage -> ManagedFeedImage in
            let item = ManagedFeedImage(context: context)
            item.id = localFeedImage.id
            item.descriptions = localFeedImage.description
            item.location = localFeedImage.location
            item.url = localFeedImage.url
            return item
        }
    }
    
    @NSManaged internal var timestamp: Date
    @NSManaged internal var items: NSOrderedSet
}


@objc(ManagedFeedImage)
private class ManagedFeedImage: NSManagedObject {
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

// MARK: - Core Data Feed Store
public final class CoreDataFeedStore: FeedStore {
    
    private let container: NSPersistentContainer
    private lazy var context: NSManagedObjectContext = {
        return container.newBackgroundContext()
    }()
    
    public init(storeURL: URL) throws {
        let modelURL = Bundle(for: type(of: self)).url(forResource: "FeedModel", withExtension: "momd")!

        let model = NSManagedObjectModel(contentsOf: modelURL)!
        let container = NSPersistentContainer(name: "CoreDataFeedStore", managedObjectModel: model)
        let description = NSPersistentStoreDescription(url: storeURL)
        container.persistentStoreDescriptions = [description]
        var loadError: Swift.Error?
        container.loadPersistentStores { loadError = $1 }
        try loadError.map { throw $0 }
        
        self.container = container
    }
    
    private func fetchCurrentFeed() throws -> ManagedFeed? {
        return try context.fetch(ManagedFeed.fetchRequest()).first
    }
    
    private func deleteCurrentFeed() throws {
        if let currentFeed = try fetchCurrentFeed() {
            context.delete(currentFeed)
            try context.save()
        }
    }
    
    private func uniqueFeed() throws -> ManagedFeed {
        try deleteCurrentFeed()
        return ManagedFeed(context: context)
    }
    
    public func retrieve(completion: @escaping FeedStore.RetrievalCompletion) {
        
        context.perform {
            do {
                if let coredataFeed: ManagedFeed = try self.fetchCurrentFeed() {
                    
                    let localFeedImages = coredataFeed.local
                    completion(.found(feed: localFeedImages, timestamp: coredataFeed.timestamp))
                    
                } else {
                    completion(.empty)
                }
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        context.perform {
            do {
                try self.deleteCurrentFeed()
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }
    
    public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        
        let context = self.context
        context.perform {
            do {
                let coredataFeed = try self.uniqueFeed()
                coredataFeed.timestamp = timestamp
                coredataFeed.items = NSOrderedSet(array: ManagedFeed.managedFeedImages(from: feed, context: context))
                
                try context.save()
                completion(.none)
            } catch {
                completion(error)
            }
        }
    }
}
