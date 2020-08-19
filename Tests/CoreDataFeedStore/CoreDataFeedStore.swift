//
//  CoreDataFeedStore.swift
//  Tests
//
//  Created by Hashem Aboonajmi on 8/19/20.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import CoreData
import FeedStoreChallenge

final class CoreDataFeedStore: FeedStore {
    
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
        do {
            if let coredataFeed: Feed = try managedObjectContext.fetch(Feed.fetchRequest()).first {
                
                let localFeedImages = coredataFeed.local
                completion(.found(feed: localFeedImages, timestamp: coredataFeed.timestamp))
                
            } else {
                completion(.empty)
            }
        } catch {
            completion(.failure(error))
        }
    }
    
    func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        let context = container.viewContext
        try! context.fetch(Feed.fetchRequest()).first.map(context.delete)
        completion(nil)
    }
    
    func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        
        let managedObjectContext = container.viewContext
        do {
            let coredataFeed = try Feed.UniqueFeed(in: managedObjectContext)
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
            
            try managedObjectContext.save()
            completion(.none)
        } catch {
            completion(error)
        }
    }
}
