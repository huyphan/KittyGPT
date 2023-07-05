import CoreData

class PersistenceController: ObservableObject {
    
    static let shared = PersistenceController()
    
    // Storage for Core Data
    let container: NSPersistentContainer
    
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "KittyGPT")
        
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Failed to load Core Data stack: \(error)")
            }
        }
    }
    
    // A test configuration for SwiftUI previews
    static var preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)
        
        // Create 10 example programming languages.
        for i in 0..<10 {
            let message = ChatMessage(context: controller.container.viewContext)
            message.id = i.codingKey.stringValue
            message.sender = i.codingKey.stringValue
            message.createdAt = Date()
            message.content = "Message " + i.codingKey.stringValue
            print(i)
        }
        
        return controller
    }()
    
    func lastConversations(messageCount: Int) -> [ChatMessage] {
        let request = ChatMessage.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(
                keyPath: \ChatMessage.createdAt,
                ascending: false)]
        request.fetchLimit = messageCount
        do {
            return try container.viewContext.fetch(request)
        } catch {
            // Handle error
            print("Error retrieving previous messages: \(error)")
        }
        return []
    }
    
    func save() {
        let context = container.viewContext
        
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Show some error here
            }
        }
    }
    
    func deleteAll() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = ChatMessage.fetchRequest()
        
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try container.viewContext.execute(batchDeleteRequest)
            try container.viewContext.save()
        } catch {
            // Handle error
            print("Error deleting data: \(error)")
        }
    }
}
