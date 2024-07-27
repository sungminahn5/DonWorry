import Foundation

class FileManagerHelper {
    static let shared = FileManagerHelper()
    private let fileName = "spendingEntries.json"
    
    private init() {}
    
    private func getDocumentsDirectory() -> URL {
        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documentsDirectory
    }
    
    func saveEntries(_ entries: [SpendingEntry]) {
        let fileURL = getDocumentsDirectory().appendingPathComponent(fileName)
        
        do {
            let data = try JSONEncoder().encode(entries)
            try data.write(to: fileURL)
        } catch {
            print("Failed to save entries: \(error.localizedDescription)")
        }
    }
    
    func loadEntries() -> [SpendingEntry] {
        let fileURL = getDocumentsDirectory().appendingPathComponent(fileName)
        
        do {
            let data = try Data(contentsOf: fileURL)
            return try JSONDecoder().decode([SpendingEntry].self, from: data)
        } catch {
            print("Failed to load entries: \(error.localizedDescription)")
            return []
        }
    }
}
