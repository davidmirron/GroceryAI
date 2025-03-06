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
            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = CDRecipe.fetchRequest()
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            
            do {
                try context.execute(deleteRequest)
                DispatchQueue.main.async {
                    completion?()
                }
            } catch {
                print("❌ Failed to delete all recipes: \(error)")
            }
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