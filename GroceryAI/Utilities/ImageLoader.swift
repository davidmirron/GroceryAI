import SwiftUI
import Combine
import Network

/// Manages image loading, caching, and optimization for the app
class ImageLoader: ObservableObject {
    static let shared = ImageLoader()
    
    // In-memory cache
    @Published var cache = NSCache<NSString, UIImage>()
    
    // Local disk cache
    private let fileManager = FileManager.default
    private var cacheDirectory: URL?
    
    // Network connectivity monitoring
    private let networkMonitor = NWPathMonitor()
    private let networkQueue = DispatchQueue(label: "NetworkMonitor")
    @Published private(set) var isConnected = true
    @Published private(set) var connectionType: ConnectionType = .wifi
    @Published private(set) var isExpensiveConnection = false
    
    private var cancellables = Set<AnyCancellable>()
    private let defaultPlaceholder: String
    private var categoryImageMap: [RecipeCategory: String] = [:]
    
    // Image download operations
    private var downloadTasks: [String: URLSessionDataTask] = [:]
    
    // Image size optimization settings
    private let standardImageSize = CGSize(width: 600, height: 400)
    private let thumbnailSize = CGSize(width: 200, height: 200)
    
    // MARK: - Network Connectivity Types
    
    enum ConnectionType {
        case wifi
        case cellular
        case wiredEthernet
        case loopback
        case other
        case none
        
        var description: String {
            switch self {
            case .wifi: return "WiFi"
            case .cellular: return "Cellular"
            case .wiredEthernet: return "Wired Ethernet"
            case .loopback: return "Loopback"
            case .other: return "Other"
            case .none: return "None"
            }
        }
    }
    
    init(defaultPlaceholder: String = "recipe-placeholder") {
        self.defaultPlaceholder = defaultPlaceholder
        
        // Configure cache limits
        self.cache.countLimit = 100 // Maximum number of images in memory
        self.cache.totalCostLimit = 50 * 1024 * 1024 // 50 MB memory limit
        
        // Setup disk cache
        setupDiskCache()
        
        // Initialize category-to-image mappings
        setupCategoryImageMap()
        
        // Start monitoring network connectivity
        startNetworkMonitoring()
    }
    
    // MARK: - Network Monitoring
    
    private func startNetworkMonitoring() {
        networkMonitor.pathUpdateHandler = { [weak self] path in
            guard let self = self else { return }
            
            // Update on main thread since we're publishing changes
            DispatchQueue.main.async {
                self.isConnected = path.status == .satisfied
                
                // Determine connection type
                if path.usesInterfaceType(.wifi) {
                    self.connectionType = .wifi
                    self.isExpensiveConnection = false
                } else if path.usesInterfaceType(.cellular) {
                    self.connectionType = .cellular
                    self.isExpensiveConnection = true
                } else if path.usesInterfaceType(.wiredEthernet) {
                    self.connectionType = .wiredEthernet
                    self.isExpensiveConnection = false
                } else if path.usesInterfaceType(.loopback) {
                    self.connectionType = .loopback
                    self.isExpensiveConnection = false
                } else {
                    self.connectionType = path.status == .satisfied ? .other : .none
                    self.isExpensiveConnection = path.status == .satisfied
                }
                
                print("📶 Network connectivity: \(self.isConnected ? "Connected" : "Disconnected") - \(self.connectionType.description)")
            }
        }
        
        // Start monitoring on a background queue
        networkMonitor.start(queue: networkQueue)
    }
    
    // MARK: - Cache Setup
    
    private func setupDiskCache() {
        let cachesDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first
        cacheDirectory = cachesDirectory?.appendingPathComponent("ImageCache", isDirectory: true)
        
        // Create cache directory if it doesn't exist
        if let cacheDirectory = cacheDirectory,
           !fileManager.fileExists(atPath: cacheDirectory.path) {
            do {
                try fileManager.createDirectory(at: cacheDirectory,
                                               withIntermediateDirectories: true,
                                               attributes: nil)
                print("📁 Created image cache directory at: \(cacheDirectory.path)")
            } catch {
                print("❌ Failed to create image cache directory: \(error)")
                // Fallback to in-memory only caching
                self.cacheDirectory = nil
            }
        }
    }
    
    // Setup mappings between recipe categories and placeholder images
    private func setupCategoryImageMap() {
        categoryImageMap = [
            .breakfast: "breakfast",
            .lunch: "lunch",
            .dinner: "dinner",
            .dessert: "dessert",
            .appetizer: "appetizer",
            .salad: "salad",
            .soup: "soup",
            .mainCourse: "main-course",
            .sideDish: "side-dish",
            .beverage: "beverage",
            .snack: "snack",
            .other: "recipe-placeholder"
        ]
    }
    
    // MARK: - Image Loading
    
    /// Load an image either from cache, local bundle, or URL
    /// - Parameters:
    ///   - imageName: Name or URL string of the image
    ///   - category: Optional recipe category for fallback placeholder
    ///   - size: Optional size to resize the image to
    ///   - highPriority: Indicates if this is a high-priority load
    ///   - completion: Closure called with the loaded image
    func loadImage(named imageName: String?, 
                  forCategory category: RecipeCategory? = nil,
                  size: CGSize? = nil,
                  highPriority: Bool = false,
                  completion: @escaping (UIImage) -> Void) {
        // If imageName is nil or empty, return category-based or default placeholder
        guard let imageName = imageName, !imageName.isEmpty else {
            if let category = category {
                completion(getCategoryImage(for: category))
            } else {
                completion(getPlaceholderImage())
            }
            return
        }
        
        // Generate cache key
        let cacheKey = NSString(string: imageName)
        
        // Check memory cache first (fastest)
        if let cachedImage = cache.object(forKey: cacheKey) {
            // If a size is specified and the cached image is larger, resize it
            if let size = size, cachedImage.size.width > size.width * 1.5 || cachedImage.size.height > size.height * 1.5 {
                DispatchQueue.global(qos: .userInitiated).async {
                    let resizedImage = self.resizeImage(cachedImage, to: size)
                    DispatchQueue.main.async {
                        completion(resizedImage)
                    }
                }
            } else {
                completion(cachedImage)
            }
            return
        }
        
        // Check disk cache next
        if let diskCachedImage = loadImageFromDisk(key: imageName) {
            // Store in memory cache for faster access next time
            cache.setObject(diskCachedImage, forKey: cacheKey)
            
            // Resize if needed
            if let size = size, diskCachedImage.size.width > size.width * 1.5 || diskCachedImage.size.height > size.height * 1.5 {
                DispatchQueue.global(qos: .userInitiated).async {
                    let resizedImage = self.resizeImage(diskCachedImage, to: size)
                    DispatchQueue.main.async {
                        completion(resizedImage)
                    }
                }
            } else {
                completion(diskCachedImage)
            }
            return
        }
        
        // Try to load from bundle
        if let bundleImage = UIImage(named: imageName) {
            // Save to caches
            cache.setObject(bundleImage, forKey: cacheKey)
            saveImageToDisk(bundleImage, key: imageName)
            
            // Resize if needed
            if let size = size, bundleImage.size.width > size.width * 1.5 || bundleImage.size.height > size.height * 1.5 {
                DispatchQueue.global(qos: .userInitiated).async {
                    let resizedImage = self.resizeImage(bundleImage, to: size)
                    DispatchQueue.main.async {
                        completion(resizedImage)
                    }
                }
            } else {
                completion(bundleImage)
            }
            return
        }
        
        // Check if it's a URL
        if let url = URL(string: imageName), url.scheme == "http" || url.scheme == "https" {
            // If not connected, use placeholder immediately and return
            guard isConnected else {
                if let category = category {
                    completion(getCategoryImage(for: category))
                } else {
                    completion(getPlaceholderImage())
                }
                
                // Attempt to download in background if user eventually connects
                DispatchQueue.global(qos: .background).async { [weak self] in
                    // Convert cacheKey to a Swift String to make it Sendable
                    let cacheKeyString = String(cacheKey)
                    self?.attemptDownloadWhenConnected(url: url, key: imageName, size: size, category: category) { [cacheKeyString] image in
                        // If downloaded later, update the cache but don't call completion again
                        if let image = image, let strongSelf = self {
                            // Use NSString(string:) to convert back to the required type for the cache
                            let cacheKey = NSString(string: cacheKeyString)
                            strongSelf.cache.setObject(image, forKey: cacheKey)
                            strongSelf.saveImageToDisk(image, key: imageName)
                        }
                    }
                }
                return
            }
            
            // Determine if we should load a smaller version of the image based on connection
            var optimizedURL = url
            if isExpensiveConnection, let size = size, let reducedURL = optimizeURLForNetworkCondition(url, size: size) {
                optimizedURL = reducedURL
                print("📱 Using optimized image URL for cellular network")
            }
            
            // Download from network with appropriate priority
            let qos: DispatchQoS.QoSClass = highPriority ? .userInitiated : .utility
            loadImageFromURL(optimizedURL, withKey: imageName, qos: qos) { image in
                if let image = image {
                    // Save to caches
                    self.cache.setObject(image, forKey: cacheKey)
                    self.saveImageToDisk(image, key: imageName)
                    
                    // Resize if needed
                    if let size = size, image.size.width > size.width * 1.5 || image.size.height > size.height * 1.5 {
                        DispatchQueue.global(qos: .userInitiated).async {
                            let resizedImage = self.resizeImage(image, to: size)
                            DispatchQueue.main.async {
                                completion(resizedImage)
                            }
                        }
                    } else {
                        completion(image)
                    }
                } else {
                    // If URL loading fails, fall back to placeholders
                    if let category = category {
                        completion(self.getCategoryPlaceholderImage(for: imageName) ?? self.getCategoryImage(for: category))
                    } else {
                        completion(self.getCategoryPlaceholderImage(for: imageName) ?? self.getPlaceholderImage())
                    }
                }
            }
            return
        }
        
        // Try to get category-specific placeholder based on name
        if let categoryImage = getCategoryPlaceholderImage(for: imageName) {
            cache.setObject(categoryImage, forKey: cacheKey)
            completion(categoryImage)
            return
        }
        
        // If category is provided but no image found yet, use category image
        if let category = category {
            let categoryImage = getCategoryImage(for: category)
            cache.setObject(categoryImage, forKey: cacheKey)
            completion(categoryImage)
            return
        }
        
        // If can't load, return placeholder
        completion(getPlaceholderImage())
    }
    
    // Download image from network with specified priority
    private func loadImageFromURL(_ url: URL, withKey key: String, qos: DispatchQoS.QoSClass = .utility, completion: @escaping (UIImage?) -> Void) {
        // Cancel any existing task for this URL
        if let existingTask = downloadTasks[key] {
            existingTask.cancel()
            downloadTasks.removeValue(forKey: key)
        }
        
        // Configure the URLSession with appropriate priority
        let config = URLSessionConfiguration.default
        config.requestCachePolicy = .returnCacheDataElseLoad
        
        // Set timeout based on connection quality
        if isExpensiveConnection {
            config.timeoutIntervalForRequest = 15 // Shorter timeout for cellular
        } else {
            config.timeoutIntervalForRequest = 30 // Longer timeout for WiFi
        }
        
        // Create and configure URLSession
        let session = URLSession(configuration: config)
        
        // Create a new download task
        let task = session.dataTask(with: url) { [weak self] data, response, error in
            // Remove task from tracking
            self?.downloadTasks.removeValue(forKey: key)
            
            // Check for errors
            guard error == nil,
                  let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200,
                  let data = data,
                  let image = UIImage(data: data) else {
                DispatchQueue.main.async {
                    print("❌ Failed to load image from URL: \(url.absoluteString)")
                    completion(nil)
                }
                return
            }
            
            DispatchQueue.main.async {
                completion(image)
            }
        }
        
        // Set task priority based on QoS
        task.priority = qos == .userInitiated ? URLSessionTask.highPriority : URLSessionTask.defaultPriority
        
        // Store and start the task
        downloadTasks[key] = task
        task.resume()
    }
    
    // Modify URL to request a smaller image if on cellular network
    private func optimizeURLForNetworkCondition(_ url: URL, size: CGSize) -> URL? {
        // If we're on WiFi, use the original URL
        guard isExpensiveConnection else { return nil }
        
        // Handle Unsplash URLs - add size parameters
        if url.absoluteString.contains("unsplash.com") {
            var urlString = url.absoluteString
            
            // Remove any existing width/quality parameters
            if urlString.contains("&w=") {
                // Try to keep just the core URL before parameters
                if let baseURL = urlString.components(separatedBy: "?").first {
                    urlString = baseURL
                }
            }
            
            // For cellular connections, reduce image quality
            let targetWidth = Int(min(size.width, 600) * UIScreen.main.scale)
            let qualityParam = "q=60" // Lower quality for cellular
            
            // Add the parameters
            if urlString.contains("?") {
                return URL(string: "\(urlString)&w=\(targetWidth)&\(qualityParam)")
            } else {
                return URL(string: "\(urlString)?w=\(targetWidth)&\(qualityParam)")
            }
        }
        
        // For unknown URLs, return the original
        return nil
    }
    
    // Try to download an image when network connectivity is restored
    private func attemptDownloadWhenConnected(url: URL, key: String, size: CGSize?, category: RecipeCategory?, completion: @escaping (UIImage?) -> Void) {
        // Create a sink to the isConnected publisher
        var cancellable: AnyCancellable?
        
        cancellable = $isConnected
            .dropFirst() // Skip the current value
            .filter { $0 } // Wait for connected state
            .first() // Take just the first connected state
            .sink { [weak self] _ in
                // We're connected, try to download the image
                self?.loadImageFromURL(url, withKey: key) { image in
                    completion(image)
                    
                    // Clean up the cancellable
                    cancellable?.cancel()
                    cancellable = nil
                }
            }
        
        // Store the cancellable to prevent it from being deallocated
        if let cancellable = cancellable {
            cancellables.insert(cancellable)
        }
    }
    
    // MARK: - Disk Cache Operations
    
    private func diskCachePath(for key: String) -> URL? {
        guard let cacheDirectory = cacheDirectory else { return nil }
        
        // Create a filename-safe hash of the key
        let safeKey = key
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: ":", with: "_")
            .replacingOccurrences(of: "?", with: "_")
            .replacingOccurrences(of: "&", with: "_")
            .replacingOccurrences(of: "=", with: "_")
            .replacingOccurrences(of: " ", with: "_")
        
        return cacheDirectory.appendingPathComponent(safeKey)
    }
    
    /// Returns the disk cache path for a given key - for use by CachedImage
    func getCachePathForKey(_ key: String) -> URL? {
        return diskCachePath(for: key)
    }
    
    private func saveImageToDisk(_ image: UIImage, key: String) {
        guard let path = diskCachePath(for: key) else { return }
        
        // Compress and save in background
        DispatchQueue.global(qos: .background).async {
            // Get appropriate quality settings based on network and device
            let (compressionQuality, _) = self.getImageQualitySettings()
            
            // Compress with dynamic quality based on conditions
            if let data = image.jpegData(compressionQuality: compressionQuality) {
                do {
                    try data.write(to: path)
                } catch {
                    print("❌ Failed to save image to disk: \(error)")
                }
            }
        }
    }
    
    private func loadImageFromDisk(key: String) -> UIImage? {
        guard let path = diskCachePath(for: key),
              fileManager.fileExists(atPath: path.path) else {
            return nil
        }
        
        do {
            let data = try Data(contentsOf: path)
            return UIImage(data: data)
        } catch {
            print("❌ Failed to load image from disk: \(error)")
            return nil
        }
    }
    
    // MARK: - Image Processing
    
    /// Resize an image to the specified size, preserving aspect ratio
    /// - Parameters:
    ///   - image: The image to resize
    ///   - size: The target size
    /// - Returns: The resized image
    func resizeImage(_ image: UIImage, to size: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            // Calculate the maximum dimension that preserves aspect ratio
            let aspectRatio = image.size.width / image.size.height
            var drawRect = CGRect(origin: .zero, size: size)
            
            if aspectRatio > 1 {
                // Wider image
                let targetHeight = size.width / aspectRatio
                drawRect.origin.y = (size.height - targetHeight) / 2
                drawRect.size.height = targetHeight
            } else if aspectRatio < 1 {
                // Taller image
                let targetWidth = size.height * aspectRatio
                drawRect.origin.x = (size.width - targetWidth) / 2
                drawRect.size.width = targetWidth
            }
            
            // Draw image in the calculated rect, preserving aspect ratio
            image.draw(in: drawRect)
        }
    }
    
    /// Downsample a large image at load time for better memory efficiency
    /// - Parameters:
    ///   - url: The URL of the image to downsample
    ///   - pointSize: The target size in points
    ///   - scale: The screen scale
    /// - Returns: The downsampled image or nil if it couldn't be loaded
    func downsampleImage(from url: URL, to pointSize: CGSize, scale: CGFloat = UIScreen.main.scale) -> UIImage? {
        // Create an image source that reads from the file URL
        let imageSourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
        guard let imageSource = CGImageSourceCreateWithURL(url as CFURL, imageSourceOptions) else {
            return nil
        }
        
        // Calculate the desired dimension
        let maxDimensionInPixels = max(pointSize.width, pointSize.height) * scale
        
        // Downsample
        let downsampleOptions = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceShouldCacheImmediately: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: maxDimensionInPixels
        ] as CFDictionary
        
        guard let downsampledImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, downsampleOptions) else {
            return nil
        }
        
        return UIImage(cgImage: downsampledImage)
    }
    
    /// Load a large image progressively to display a preview quickly
    /// - Parameters:
    ///   - url: The URL of the image to load
    ///   - targetSize: The target size for the final image
    ///   - progressHandler: Callback that provides a low quality version first, then the final image
    func loadProgressiveImage(from url: URL, targetSize: CGSize, progressHandler: @escaping (UIImage?, Bool) -> Void) {
        // First try to load a downsampled version quickly to show something
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            // Load low quality image first (for preview)
            if let lowQualityImage = self?.downsampleImage(from: url, to: CGSize(width: targetSize.width / 3, height: targetSize.height / 3)) {
                DispatchQueue.main.async {
                    // Pass the low quality preview, with isFullQuality = false
                    progressHandler(lowQualityImage, false)
                }
            }
            
            // Then load the full quality image
            if let fullQualityImage = self?.downsampleImage(from: url, to: targetSize) {
                DispatchQueue.main.async {
                    // Pass the full quality image, with isFullQuality = true
                    progressHandler(fullQualityImage, true)
                }
            } else {
                // If full quality fails but we had a preview, don't report failure
                if self?.downsampleImage(from: url, to: CGSize(width: targetSize.width / 3, height: targetSize.height / 3)) == nil {
                    DispatchQueue.main.async {
                        // No image could be loaded at all
                        progressHandler(nil, false)
                    }
                }
            }
        }
    }
    
    // Helper method to determine appropriate image quality settings based on network and device
    func getImageQualitySettings() -> (compressionQuality: CGFloat, maxDimension: CGFloat) {
        // Base quality on network type and device capabilities
        let isLowPowerMode = ProcessInfo.processInfo.isLowPowerModeEnabled
        
        switch (connectionType, isLowPowerMode) {
        case (.wifi, false):
            return (0.85, 1200) // High quality on good connection
        case (.wifi, true):
            return (0.75, 900) // Medium quality on good connection but low power
        case (.cellular, false):
            return (0.65, 800) // Medium-low quality on cellular
        case (.cellular, true):
            return (0.55, 600) // Low quality on cellular and low power
        case (.wiredEthernet, _):
            return (0.9, 1500) // Best quality on wired
        default:
            return (0.7, 800) // Default medium quality
        }
    }
    
    // MARK: - Placeholder Images
    
    // Get a placeholder image based on recipe category
    private func getCategoryImage(for category: RecipeCategory) -> UIImage {
        if let imageName = categoryImageMap[category], let image = UIImage(named: imageName) {
            return image
        }
        return getPlaceholderImage()
    }
    
    // Get an appropriate category-based placeholder image based on recipe name
    private func getCategoryPlaceholderImage(for recipeName: String) -> UIImage? {
        let recipeLowercase = recipeName.lowercased()
        
        // First try exact category matches
        if recipeLowercase.contains("salad") {
            return UIImage(named: "salad") ?? getPlaceholderImage()
        } else if recipeLowercase.contains("pizza") {
            return UIImage(named: "pizza") ?? getPlaceholderImage()
        } else if recipeLowercase.contains("soup") || recipeLowercase.contains("stew") {
            return UIImage(named: "soup") ?? getPlaceholderImage()
        } else if recipeLowercase.contains("dessert") || recipeLowercase.contains("cake") || 
                  recipeLowercase.contains("cookie") || recipeLowercase.contains("sweet") || 
                  recipeLowercase.contains("chocolate") || recipeLowercase.contains("pie") {
            return UIImage(named: "dessert") ?? getPlaceholderImage()
        }
        
        // Then try ingredient-based matches
        if recipeLowercase.contains("pasta") || recipeLowercase.contains("spaghetti") || 
           recipeLowercase.contains("noodle") || recipeLowercase.contains("macaroni") {
            return UIImage(named: "pasta") ?? getPlaceholderImage()
        } else if recipeLowercase.contains("chicken") || recipeLowercase.contains("turkey") {
            return UIImage(named: "chicken") ?? getPlaceholderImage()
        } else if recipeLowercase.contains("beef") || recipeLowercase.contains("steak") || 
                  recipeLowercase.contains("pork") || recipeLowercase.contains("meat") || 
                  recipeLowercase.contains("burger") {
            return UIImage(named: "meat") ?? getPlaceholderImage()
        } else if recipeLowercase.contains("sandwich") || recipeLowercase.contains("toast") || 
                  recipeLowercase.contains("bread") || recipeLowercase.contains("wrap") {
            return UIImage(named: "sandwich") ?? getPlaceholderImage()
        } else if recipeLowercase.contains("salmon") || recipeLowercase.contains("fish") || 
                  recipeLowercase.contains("seafood") || recipeLowercase.contains("shrimp") || 
                  recipeLowercase.contains("tuna") {
            return UIImage(named: "seafood") ?? getPlaceholderImage()
        } else if recipeLowercase.contains("pancake") || recipeLowercase.contains("waffle") || 
                  recipeLowercase.contains("breakfast") || recipeLowercase.contains("egg") || 
                  recipeLowercase.contains("omelet") {
            return UIImage(named: "breakfast") ?? getPlaceholderImage()
        } else if recipeLowercase.contains("stir fry") || recipeLowercase.contains("curry") || 
                  recipeLowercase.contains("asian") || recipeLowercase.contains("chinese") || 
                  recipeLowercase.contains("thai") {
            return UIImage(named: "stirfry") ?? getPlaceholderImage()
        } else if recipeLowercase.contains("vegetable") || recipeLowercase.contains("vegan") || 
                  recipeLowercase.contains("vegetarian") {
            return UIImage(named: "vegetable") ?? getPlaceholderImage()
        } else if recipeLowercase.contains("rice") || recipeLowercase.contains("grain") || 
                  recipeLowercase.contains("quinoa") {
            return UIImage(named: "rice") ?? getPlaceholderImage()
        }
        
        // No category match found
        return nil
    }
    
    private func getPlaceholderImage() -> UIImage {
        if let placeholder = UIImage(named: defaultPlaceholder) {
            return placeholder
        }
        // Fallback to a system symbol if placeholder image is missing
        return UIImage(systemName: "fork.knife") ?? UIImage()
    }
    
    // MARK: - Cache Management
    
    /// Clear the in-memory cache
    func clearMemoryCache() {
        cache.removeAllObjects()
    }
    
    /// Clear both memory and disk caches
    func clearCache() {
        // Clear memory cache
        cache.removeAllObjects()
        
        // Clear disk cache (in background)
        guard let cacheDirectory = cacheDirectory,
              fileManager.fileExists(atPath: cacheDirectory.path) else {
            return
        }
        
        DispatchQueue.global(qos: .background).async {
            do {
                let cacheContents = try self.fileManager.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: nil)
                for fileURL in cacheContents {
                    try self.fileManager.removeItem(at: fileURL)
                }
                print("✅ Cleared disk image cache")
            } catch {
                print("❌ Failed to clear disk cache: \(error)")
            }
        }
    }
    
    /// Remove old cached images that haven't been accessed recently
    func pruneCache() {
        guard let cacheDirectory = cacheDirectory,
              fileManager.fileExists(atPath: cacheDirectory.path) else {
            return
        }
        
        DispatchQueue.global(qos: .background).async {
            do {
                // Get list of all cached files with attributes
                let cacheContents = try self.fileManager.contentsOfDirectory(
                    at: cacheDirectory,
                    includingPropertiesForKeys: [.contentAccessDateKey, .contentModificationDateKey, .fileSizeKey]
                )
                
                // Calculate date threshold (older than 7 days)
                let now = Date()
                let calendar = Calendar.current
                let threshold = calendar.date(byAdding: .day, value: -7, to: now)!
                
                // Track size of deleted files
                var bytesFreed: UInt64 = 0
                var filesDeleted = 0
                
                for fileURL in cacheContents {
                    // Get file attributes
                    let attributes = try fileURL.resourceValues(forKeys: [.contentAccessDateKey, .contentModificationDateKey, .fileSizeKey])
                    
                    // Use the most recent of access or modification date
                    let accessDate = attributes.contentAccessDate ?? Date.distantPast
                    let modificationDate = attributes.contentModificationDate ?? Date.distantPast
                    let lastUsedDate = max(accessDate, modificationDate)
                    
                    // Delete if older than threshold
                    if lastUsedDate < threshold, let fileSize = attributes.fileSize {
                        try self.fileManager.removeItem(at: fileURL)
                        bytesFreed += UInt64(fileSize)
                        filesDeleted += 1
                    }
                }
                
                if filesDeleted > 0 {
                    let megabytesFreed = Double(bytesFreed) / (1024 * 1024)
                    print("✅ Pruned cache: deleted \(filesDeleted) files, freed \(String(format: "%.2f", megabytesFreed)) MB")
                }
            } catch {
                print("❌ Failed to prune disk cache: \(error)")
            }
        }
    }
    
    /// Print statistics about cache usage
    func printCacheStatistics() {
        // Memory cache statistics
        let memoryCacheCount = cache.countLimit
        let memoryCacheSizeMB = Double(cache.totalCostLimit) / (1024 * 1024)
        
        // Get disk cache size
        var diskCacheSize: UInt64 = 0
        var fileCount = 0
        
        if let cacheDirectory = cacheDirectory,
           fileManager.fileExists(atPath: cacheDirectory.path) {
            
            // Enumerate all files
            guard let fileEnumerator = fileManager.enumerator(
                at: cacheDirectory,
                includingPropertiesForKeys: [.fileSizeKey],
                options: [.skipsHiddenFiles, .skipsSubdirectoryDescendants]
            ) else {
                print("📊 Image Cache Statistics:")
                print("  - Memory cache limit: \(memoryCacheCount) images, \(String(format: "%.1f", memoryCacheSizeMB)) MB")
                print("  - Disk cache: Unable to calculate")
                return
            }
            
            // Sum up file sizes
            for case let fileURL as URL in fileEnumerator {
                do {
                    let attributes = try fileURL.resourceValues(forKeys: [.fileSizeKey])
                    if let fileSize = attributes.fileSize {
                        diskCacheSize += UInt64(fileSize)
                        fileCount += 1
                    }
                } catch {
                    print("Error getting file size: \(error)")
                }
            }
        }
        
        // Convert bytes to MB for display
        let diskCacheSizeMB = Double(diskCacheSize) / (1024 * 1024)
        
        // Print statistics
        print("📊 Image Cache Statistics:")
        print("  - Memory cache limit: \(memoryCacheCount) images, \(String(format: "%.1f", memoryCacheSizeMB)) MB")
        print("  - Disk cache: \(fileCount) files, \(String(format: "%.2f", diskCacheSizeMB)) MB")
    }
    
    // MARK: - Priority Management
    
    /// Updates the loading priority for a specific image
    func updatePriority(for imageName: String, highPriority: Bool) {
        guard let url = URL(string: imageName), url.scheme == "http" || url.scheme == "https" else {
            return // Only URL-based images need priority updates
        }
        
        let cacheKey = NSString(string: imageName)
        
        // If it's already in cache, nothing to prioritize
        if cache.object(forKey: cacheKey) != nil {
            return
        }
        
        // If there's an active download task for this image, update its priority
        if let existingTask = downloadTasks[imageName] {
            // Cancel the existing task if it's not high priority but should be
            if highPriority && existingTask.priority == URLSessionTask.defaultPriority {
                existingTask.cancel()
                downloadTasks.removeValue(forKey: imageName)
                
                // Request the image again with high priority
                loadImage(named: imageName, highPriority: true) { _ in }
            }
            // If it's already high priority, we don't need to downgrade it
        }
    }
}

// MARK: - SwiftUI Image View
struct CachedImage: View {
    let imageName: String?
    let category: RecipeCategory?
    let contentMode: ContentMode
    let cornerRadius: CGFloat
    let size: CGSize
    let backgroundColor: Color
    let placeholderScale: CGFloat
    
    @State private var image: UIImage?
    @State private var isLoading = false
    @State private var isLowQuality = false
    @State private var loadAttempted = false
    @State private var isVisible = false
    
    init(
        imageName: String?,
        category: RecipeCategory? = nil,
        contentMode: ContentMode = .fill,
        cornerRadius: CGFloat = 8,
        size: CGSize = CGSize(width: 100, height: 100),
        backgroundColor: Color = Color(.systemGray5),
        placeholderScale: CGFloat = 0.6
    ) {
        self.imageName = imageName
        self.category = category
        self.contentMode = contentMode
        self.cornerRadius = cornerRadius
        self.size = size
        self.backgroundColor = backgroundColor
        self.placeholderScale = placeholderScale
    }
    
    var body: some View {
        ZStack {
            // Background and shape
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(backgroundColor)
                .frame(width: size.width, height: size.height)
            
            if let uiImage = image {
                // Display the loaded image
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: contentMode)
                    .frame(width: size.width, height: size.height)
                    .cornerRadius(cornerRadius)
                    // Apply a slight blur effect if it's a low quality preview
                    .blur(radius: isLowQuality ? 1.0 : 0)
                    .animation(.easeInOut(duration: 0.3), value: isLowQuality)
            } else if isLoading {
                // Show loading indicator
                ProgressView()
                    .frame(width: size.width, height: size.height)
            } else {
                // Show a placeholder with an emoji based on recipe name
                if let name = imageName, !name.isEmpty {
                    Text(getRecipeEmoji(for: name))
                        .font(.system(size: min(size.width, size.height) * placeholderScale))
                } else {
                    Image(systemName: "fork.knife")
                        .font(.system(size: min(size.width, size.height) * 0.4))
                        .foregroundColor(.gray)
                }
            }
        }
        .onAppear {
            isVisible = true
            loadImage(highPriority: true)
        }
        .onDisappear {
            isVisible = false
            if isLoading {
                // Deprioritize loading when no longer visible
                updateLoadingPriority(highPriority: false)
            }
        }
        .onChange(of: imageName) { _, _ in
            loadImage(highPriority: isVisible)
        }
    }
    
    private func loadImage(highPriority: Bool = false) {
        guard !loadAttempted else { return }
        loadAttempted = true
        isLoading = true
        
        // Check if it's a URL image
        if let imageName = imageName, 
           let url = URL(string: imageName), 
           url.scheme == "http" || url.scheme == "https" {
            
            // Use progressive loading for URL images
            loadProgressiveImage(from: url, highPriority: highPriority)
        } else {
            // For local images, use standard loading
            loadStandardImage(highPriority: highPriority)
        }
    }
    
    private func updateLoadingPriority(highPriority: Bool) {
        guard let imageName = imageName else { return }
        
        // Update loading priority in ImageLoader
        ImageLoader.shared.updatePriority(for: imageName, highPriority: highPriority)
    }
    
    private func loadProgressiveImage(from url: URL, highPriority: Bool = false) {
        // Use priority based on visibility
        ImageLoader.shared.loadImage(
            named: url.absoluteString,
            forCategory: category,
            size: size,
            highPriority: highPriority
        ) { [self] loadedImage in
            withAnimation(.easeInOut(duration: 0.2)) {
                self.image = loadedImage
                self.isLoading = false
                self.isLowQuality = false
            }
        }
        
        // If we're on a fast connection, we can skip the progressive loading
        guard ImageLoader.shared.isExpensiveConnection else { return }
        
        // For progressive loading on slow connections, try to load from disk cache first
        if let diskCachePath = ImageLoader.shared.getCachePathForKey(url.absoluteString),
           FileManager.default.fileExists(atPath: diskCachePath.path) {
            
            // We have a disk cache, load it progressively
            ImageLoader.shared.loadProgressiveImage(from: diskCachePath, targetSize: size) { progressImage, isFullQuality in
                guard let progressImage = progressImage else { return }
                
                withAnimation(.easeInOut(duration: 0.2)) {
                    self.image = progressImage
                    self.isLoading = false
                    self.isLowQuality = !isFullQuality
                }
            }
        }
    }
    
    private func loadStandardImage(highPriority: Bool = false) {
        // Load image with proper size optimization
        ImageLoader.shared.loadImage(
            named: imageName,
            forCategory: category,
            size: size,
            highPriority: highPriority
        ) { loadedImage in
            withAnimation(.easeInOut(duration: 0.2)) {
                self.image = loadedImage
                self.isLoading = false
                self.isLowQuality = false
            }
        }
    }
    
    // Helper function to determine emoji for recipe name
    private func getRecipeEmoji(for name: String) -> String {
        let name = name.lowercased()
        
        if name.contains("pancake") || name.contains("waffle") { return "🥞" }
        else if name.contains("salad") { return "🥗" }
        else if name.contains("pasta") || name.contains("spaghetti") { return "🍝" }
        else if name.contains("cookie") || name.contains("dessert") { return "🍪" }
        else if name.contains("curry") { return "🍛" }
        else if name.contains("taco") || name.contains("mexican") { return "🌮" }
        else if name.contains("bread") || name.contains("toast") { return "🍞" }
        else if name.contains("stir fry") { return "🥘" }
        else if name.contains("pizza") { return "🍕" }
        else if name.contains("burger") { return "🍔" }
        else if name.contains("rice") { return "🍚" }
        else if name.contains("soup") { return "🍲" }
        else if name.contains("cake") { return "🍰" }
        else if name.contains("chicken") { return "🍗" }
        else if name.contains("beef") || name.contains("steak") { return "🥩" }
        else if name.contains("seafood") || name.contains("fish") { return "🐟" }
        else if name.contains("breakfast") || name.contains("egg") { return "🍳" }
        else if name.contains("fruit") || name.contains("apple") { return "🍎" }
        else { return "🍽️" }
    }
}

// Example usage:
// CachedImage(imageName: recipe.imageName, category: recipe.category, size: CGSize(width: 90, height: 90)) 
// CachedImage(imageName: recipe.imageName, category: recipe.category, size: CGSize(width: 90, height: 90)) 