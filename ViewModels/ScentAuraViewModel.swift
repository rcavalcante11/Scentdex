import Foundation
import Observation

@Observable
class ScentAuraViewModel {
    
    

    // MARK: - Properties
    private(set) var generatedLabel: String = ""
    private(set) var description: String = ""
    private(set) var isLoading: Bool = false

    // MARK: - Intent
    @MainActor
    func reset() {
        description = ""
        generatedLabel = ""
    }
    
    @MainActor
    func generateDescription(for profile: ScentProfile) async {
        guard description.isEmpty else { return }
        isLoading = true
        let result = await fetchProfile(for: profile)
        generatedLabel = result.label
        description = result.description
        isLoading = false
    }
    
    

    // MARK: - Private
    private func fetchProfile(for profile: ScentProfile) async -> (label: String, description: String) {

        let prompt = buildPrompt(for: profile)

        guard let url = URL(string: "https://api.anthropic.com/v1/messages") else {
            return fallback(for: profile)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
        request.setValue(Secrets.anthropicKey, forHTTPHeaderField: "x-api-key")

        let body: [String: Any] = [
            "model": "claude-sonnet-4-6",
            "max_tokens": 1000,
            "messages": [["role": "user", "content": prompt]]
        ]

        guard let httpBody = try? JSONSerialization.data(withJSONObject: body) else {
            return fallback(for: profile)
        }
        request.httpBody = httpBody

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard (response as? HTTPURLResponse)?.statusCode == 200 else {
                return fallback(for: profile)
            }

            guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let content = json["content"] as? [[String: Any]],
                  let text = content.first?["text"] as? String
            else {
                print("🧠 Failed to parse response")
                return fallback(for: profile)
            }

            

            // Parse JSON response
            let clean = text
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .replacingOccurrences(of: "```json", with: "")
                .replacingOccurrences(of: "```", with: "")
                .trimmingCharacters(in: .whitespacesAndNewlines)

            guard let jsonData = clean.data(using: .utf8),
                  let parsed = try? JSONSerialization.jsonObject(with: jsonData) as? [String: String],
                  let label = parsed["label"],
                  let desc = parsed["description"]
            else {
              
                return fallback(for: profile)
            }

            return (label: label, description: desc)

        } catch {
            print("🧠 Error:", error.localizedDescription)
            return fallback(for: profile)
        }
    }

    private func buildPrompt(for profile: ScentProfile) -> String {
        let accordLines = profile.topAccords.prefix(5).map { accord in
            "- \(accord.name): \(Int(accord.score)) pts"
        }.joined(separator: "\n")

        return """
        You are a master perfumer writing a personalised scent profile for a fragrance app called Scentdex.

        The user's collection has been analysed:
        Dominant family: \(profile.dominantFamily.rawValue)
        Second family: \(profile.secondFamily?.rawValue ?? "none")
        Top accords by weight:
        \(accordLines)

        Respond ONLY with a valid JSON object, no markdown, no extra text:
        {
          "label": "A 2-3 word evocative name for this olfactive profile. Should feel poetic and personal, not technical. Examples: 'Dark Botanist', 'Sunlit Nomad', 'Velvet Storm', 'Amber Drifter'. Never use family names directly.",
          "description": "3 sentences written directly to the user. Mention 2-3 specific top accords by name in **bold**. Include one real perfumery insight in accessible language. Tone: warm and confident, like a knowledgeable friend."
        }
        """
    }

    private func fallback(for profile: ScentProfile) -> (label: String, description: String) {
        let names = profile.topAccords.prefix(3).map { $0.name }.joined(separator: ", ")
        return (
            label: profile.accordLabel,
            description: "Your collection is anchored by \(names) — a combination that speaks of a considered, personal approach to fragrance."
        )
    }
    
}
