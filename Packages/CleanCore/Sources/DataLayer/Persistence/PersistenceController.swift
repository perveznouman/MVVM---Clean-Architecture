import CoreData

/// Owns the Core Data stack. The model ships inside this package, so it is loaded from `Bundle.module`.
final class PersistenceController {
    /// Built once per process: creating the model twice makes Core Data warn about duplicate entity classes.
    private static let model: NSManagedObjectModel = {
        guard let url = Bundle.module.url(forResource: "Favorites", withExtension: "momd"),
              let model = NSManagedObjectModel(contentsOf: url) else {
            fatalError("Favorites.momd is missing from the DataLayer bundle")
        }
        return model
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "Favorites", managedObjectModel: Self.model)
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores { _, error in
            if let error { fatalError("Core Data failed to load: \(error)") }
        }
    }
}
