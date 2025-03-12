import Foundation
import CoreData

class CoreDataManager {
    // Singleton instance
    static let shared = CoreDataManager()
    
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "GroceryAI")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        
        // For better performance during batch operations
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                print("❌ CoreData error: \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    // MARK: - Background Operations
    
    func performBackgroundTask(_ block: @escaping (NSManagedObjectContext) -> Void) {
        persistentContainer.performBackgroundTask { (context) in
            block(context)
            
            // Save the context if it has changes
            if context.hasChanges {
                do {
                    try context.save()
                } catch {
                    let nserror = error as NSError
                    print("❌ Background save error: \(nserror), \(nserror.userInfo)")
                }
            }
        }
    }
    
    // MARK: - Recipe Operations
    
    // Delete all recipes
    func deleteAllRecipes(completion: (() -> Void)? = nil) {
        performBackgroundTask { context in
            // Try a more robust approach that handles potential database issues
            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = CDRecipe.fetchRequest()
            
            // First, try the standard approach
            do {
                // Count recipes before deletion for logging
                let count = try context.count(for: fetchRequest as! NSFetchRequest<NSManagedObject>)
                
                if count > 0 {
                    // Use a batch delete request for efficiency with larger datasets
                    let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
                    deleteRequest.resultType = .resultTypeObjectIDs
                    
                    let result = try context.execute(deleteRequest) as? NSBatchDeleteResult
                    
                    if let objectIDs = result?.result as? [NSManagedObjectID] {
                        // Use the returned object IDs to update the context's registered objects
                        let changes = [NSDeletedObjectsKey: objectIDs]
                        NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [context, self.persistentContainer.viewContext])
                        
                        print("✅ Successfully deleted \(objectIDs.count) recipes from CoreData")
                    }
                    
                    // Save after batch deletion to ensure clean state
                    try context.save()
                } else {
                    print("ℹ️ No recipes to delete")
                }
                
                DispatchQueue.main.async {
                    completion?()
                }
            } catch {
                print("⚠️ Error during batch deletion: \(error)")
                
                // Fallback to individual fetch and delete if batch delete fails
                self.handleDeletionFailure(context: context, completion: completion)
            }
        }
    }
    
    // Handle failures during deletion with a more careful approach
    private func handleDeletionFailure(context: NSManagedObjectContext, completion: (() -> Void)? = nil) {
        do {
            // Try individual fetch and delete as a fallback
            let fetchRequest: NSFetchRequest<CDRecipe> = CDRecipe.fetchRequest()
            let recipes = try context.fetch(fetchRequest)
            
            print("🔄 Falling back to individual deletion for \(recipes.count) recipes")
            
            // Delete each recipe individually
            for recipe in recipes {
                context.delete(recipe)
            }
            
            // Save after individual deletions
            if context.hasChanges {
                try context.save()
                print("✅ Successfully deleted recipes using fallback method")
            }
            
            DispatchQueue.main.async {
                completion?()
            }
        } catch {
            print("❌ Critical error during recipe deletion: \(error)")
            
            // Last resort: try to reset the entire store
            self.resetPersistentStore {
                DispatchQueue.main.async {
                    completion?()
                }
            }
        }
    }
    
    // Reset the entire persistent store as a last resort
    private func resetPersistentStore(completion: @escaping () -> Void) {
        print("⚠️ Attempting to reset the persistent store")
        
        let coordinator = persistentContainer.persistentStoreCoordinator
        
        guard let storeURL = persistentContainer.persistentStoreDescriptions.first?.url,
              let store = coordinator.persistentStore(for: storeURL) else {
            print("❌ Could not locate persistent store for reset")
            completion()
            return
        }
        
        do {
            try coordinator.remove(store)
            
            // Recreate the store
            try coordinator.addPersistentStore(
                ofType: NSSQLiteStoreType,
                configurationName: nil,
                at: storeURL,
                options: [
                    NSMigratePersistentStoresAutomaticallyOption: true,
                    NSInferMappingModelAutomaticallyOption: true
                ]
            )
            
            print("✅ Successfully reset the persistent store")
            completion()
        } catch {
            print("❌ Failed to reset persistent store: \(error)")
            completion()
        }
    }
    
    // Get recipe count
    func getRecipeCount() -> Int {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<CDRecipe> = CDRecipe.fetchRequest()
        
        do {
            return try context.count(for: fetchRequest)
        } catch {
            print("❌ Failed to get recipe count: \(error)")
            return 0
        }
    }
} 