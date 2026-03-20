import SwiftUI
import SwiftData

@main
struct ScentdexApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: Perfume.self)
    }
}
