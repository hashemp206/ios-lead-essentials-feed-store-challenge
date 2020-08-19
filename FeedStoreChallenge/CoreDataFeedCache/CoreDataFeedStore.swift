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
    
    static func UniqueFeed(in context: NSManagedObjectContext) throws -> ManagedFeed {
        try context.fetch(ManagedFeed.fetchRequest()).first.map(context.delete)
        return ManagedFeed(context: context)
    }
}

extension ManagedFeed {

    @nonobjc internal class func fetchRequest() -> NSFetchRequest<ManagedFeed> {
        return NSFetchRequest<ManagedFeed>(entityName: "ManagedFeed")
    }

    @NSManaged internal var timestamp: Date
    @NSManaged internal var items: NSOrderedSet
}

// MARK: Generated accessors for items
extension ManagedFeed {

    @objc(addItems:)
    @NSManaged internal func addToItems(_ values: NSOrderedSet)
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
    
    public init(storeURL: URL) {
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
    
    public func retrieve(completion: @escaping FeedStore.RetrievalCompletion) {
        let managedObjectContext = container.viewContext
        do {
            if let coredataFeed: ManagedFeed = try managedObjectContext.fetch(ManagedFeed.fetchRequest()).first {
                
                let localFeedImages = coredataFeed.local
                completion(.found(feed: localFeedImages, timestamp: coredataFeed.timestamp))
                
            } else {
                completion(.empty)
            }
        } catch {
            completion(.failure(error))
        }
    }
    
    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        let context = container.viewContext
        try! context.fetch(ManagedFeed.fetchRequest()).first.map(context.delete)
        completion(nil)
    }
    
    public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        
        let managedObjectContext = container.viewContext
        do {
            let coredataFeed = try ManagedFeed.UniqueFeed(in: managedObjectContext)
            coredataFeed.timestamp = timestamp
            let coredataFeedImages = feed.map { localFeedImage -> ManagedFeedImage in
                let item = ManagedFeedImage(context: managedObjectContext)
                item.id = localFeedImage.id
                item.descriptions = localFeedImage.description
                item.location = localFeedImage.location
                item.url = localFeedImage.url
                return item
            }
            
            coredataFeed.addToItems(NSOrderedSet(array: coredataFeedImages))
            
            try managedObjectContext.save()
            completion(.none)
        } catch {
            completion(error)
        }
    }
}
