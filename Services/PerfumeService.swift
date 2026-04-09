import Foundation

@MainActor
class PerfumeService {
    
    // MARK: - Properties
    static let shared = PerfumeService()
    
    private let baseURL = "https://api.fragella.com/api/v1"
    private var apiKey: String {
        Bundle.main.infoDictionary?["FRAGELLA_API_KEY"] as? String ?? ""
    }
    
    // MARK: - Search
    func searchPerfumes(query: String) async throws -> [FragranceResult] {
        guard !query.isEmpty else { return [] }
        
        let endpoint = "\(baseURL)/fragrances?search=\(query.urlEncoded)&limit=10"
        return try await fetch(from: endpoint)
    }
    
    // MARK: - Similar
    func fetchSimilar(to perfumeName: String) async throws -> [FragranceResult] {
        let endpoint = "\(baseURL)/fragrances/similar?name=\(perfumeName.urlEncoded)&limit=6"
        return try await fetch(from: endpoint)
    }
    
    // MARK: - Private
    private func fetch<T: Codable>(from urlString: String) async throws -> [T] {
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        
        print("🔍 Fetching:", urlString)
        print("🔑 Key:", apiKey.prefix(8), "...")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse {
                print("📡 Status:", httpResponse.statusCode)
            }
            
            if let json = String(data: data, encoding: .utf8) {
                print("📦 Response:", json.prefix(200))
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                throw URLError(.badServerResponse)
            }
            
            return try JSONDecoder().decode([T].self, from: data)
        } catch {
            print("❌ Error:", error)
            throw error
        }
    }
}

// MARK: - String Extension
extension String {
    var urlEncoded: String {
        self.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? self
    }
}
