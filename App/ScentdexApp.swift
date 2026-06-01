import SwiftUI
import SwiftData

@main
struct ScentdexApp: App {
    
    init() {
           let key = Bundle.main.infoDictionary?["FRAGELLA_API_KEY"] as? String
            URLCache.shared.removeAllCachedResponses()
           print("🔑 Key:", key?.prefix(8) ?? "NOT FOUND")
        
       }
    
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: Perfume.self)
    }
}
