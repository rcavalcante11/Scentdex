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

    // MARK: - Match By Notes
    func searchByNotes(notes: String) async throws -> [FragranceResult] {
        let endpoint = "\(baseURL)/fragrances/match?notes=\(notes.urlEncoded)&limit=10"
        return try await fetch(from: endpoint)
    }

    // MARK: - Match By Notes Separados
    func searchByNotesSeparated(top: String, middle: String) async throws -> [FragranceResult] {
        let endpoint = "\(baseURL)/fragrances/match?top=\(top.urlEncoded)&middle=\(middle.urlEncoded)&limit=10"
        return try await fetch(from: endpoint)
    }

    // MARK: - Match By Accords
    func searchByAccords(accords: String) async throws -> [FragranceResult] {
        let endpoint = "\(baseURL)/fragrances/match?accords=\(accords.urlEncoded)&limit=10"
        return try await fetch(from: endpoint)
    }

    // MARK: - Private
    private func fetch<T: Decodable>(from urlString: String) async throws -> [T] {
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            if let httpResponse = response as? HTTPURLResponse {
                print("📡 Fragella status:", httpResponse.statusCode, urlString)
            }

            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                throw URLError(.badServerResponse)
            }

            return try JSONDecoder().decode([T].self, from: data)
        } catch {
            print("❌ Fragella error:", error.localizedDescription, urlString)
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
