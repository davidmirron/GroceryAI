import Foundation

/// Utility for loading recipes from JSON files
struct RecipeJSONLoader {
    /// Error types for recipe loading
    enum LoadError: Error {
        case fileNotFound
        case readError(Error)
        case decodingError(Error)
        
        var localizedDescription: String {
            switch self {
            case .fileNotFound:
                return "Recipe JSON file not found in the app bundle"
            case .readError(let error):
                return "Error reading recipe file: \(error.localizedDescription)"
            case .decodingError(let error):
                return "Error decoding recipe data: \(error.localizedDescription)"
            }
        }
    }
    
    /// Load recipes from a JSON file
    /// - Parameter fileName: Name of the JSON file without extension
    /// - Returns: Array of Recipe objects
    static func loadRecipes(from fileName: String = "recipes") throws -> [Recipe] {
        // Get the URL for the JSON file in the app bundle
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "json") else {
            throw LoadError.fileNotFound
        }
        
        // Load the JSON data
        let data: Data
        do {
            data = try Data(contentsOf: url)
        } catch {
            throw LoadError.readError(error)
        }
        
        // Decode the JSON
        let decoder = JSONDecoder()
        let jsonRecipes: [JSONRecipe]
        do {
            jsonRecipes = try decoder.decode([JSONRecipe].self, from: data)
        } catch {
            throw LoadError.decodingError(error)
        }
        
        // Convert JSON recipes to app model
        return jsonRecipes.map { $0.toRecipe() }
    }
    
    /// Check if the recipe JSON file is valid
    /// - Parameter fileName: Name of the JSON file without extension
    /// - Returns: True if the file exists and can be parsed
    static func verifyJSONIntegrity(fileName: String = "recipes") -> Bool {
        do {
            _ = try loadRecipes(from: fileName)
            return true
        } catch {
            print("⚠️ Recipe JSON integrity check failed: \(error.localizedDescription)")
            return false
        }
    }
} 