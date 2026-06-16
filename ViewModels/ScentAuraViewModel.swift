//
//  ScentAuraViewModel.swift
//  Scentdex
//
//  Created by macbook on 08/06/2026.
//

import Foundation
import Observation

@Observable
class ScentAuraViewModel {

    // MARK: - Properties
    private(set) var description: String = ""
    private(set) var isLoading: Bool = false

    // MARK: - Intent
    @MainActor
    func generateDescription(for profile: ScentProfile) async {
        guard description.isEmpty else { return }
        isLoading = true
        description = await fetchDescription(for: profile) ?? fallbackDescription(for: profile)
        isLoading = false
    }

    // MARK: - Private
    private func fetchDescription(for profile: ScentProfile) async -> String? {
        print("🧠 Calling Claude API...")
        let prompt = buildPrompt(for: profile)

        guard let url = URL(string: "https://api.anthropic.com/v1/messages") else {
            print("🧠 Invalid URL")
            return nil
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
        request.setValue(Secrets.anthropicKey, forHTTPHeaderField: "x-api-key")

        let body: [String: Any] = [
            "model": "claude-sonnet-4-6",
            "max_tokens": 1000,
            "messages": [
                ["role": "user", "content": prompt]
            ]
        ]

        guard let httpBody = try? JSONSerialization.data(withJSONObject: body) else {
            print("🧠 Failed to serialize body")
            return nil
        }
        request.httpBody = httpBody

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            if let httpResponse = response as? HTTPURLResponse {
                print("🧠 Status:", httpResponse.statusCode)
            }

            if let raw = String(data: data, encoding: .utf8) {
                print("🧠 Response:", raw.prefix(300))
            }

            guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let content = json["content"] as? [[String: Any]],
                  let text = content.first?["text"] as? String
            else {
                print("🧠 Failed to parse response")
                return nil
            }

            return text.trimmingCharacters(in: .whitespacesAndNewlines)
        } catch {
            print("🧠 Error:", error.localizedDescription)
            return nil
        }
    }

    private func buildPrompt(for profile: ScentProfile) -> String {
        let accordLines = profile.topAccords.prefix(5).map { accord in
            "- \(accord.name): \(Int(accord.score)) pts"
        }.joined(separator: "\n")

        let label = profile.accordLabel
        let secondLabel = profile.secondFamily?.rawValue ?? "none"

        return """
        You are a master perfumer writing a personalised scent profile for a fragrance app called Scentdex.

        The user's collection has been analysed and their olfactive profile is:

        Label: \(label)
        Dominant family: \(profile.dominantFamily.rawValue)
        Second family: \(secondLabel)

        Their top accords by weight across their collection:
        \(accordLines)

        Write a 3-sentence personal profile description.
        Rules:
        - Write directly to the user (use "your", "you")
        - Mention 2-3 of their specific top accords by name
        - Include one piece of real perfumery knowledge translated into accessible language
        - Tone: warm, confident, like a knowledgeable friend — not academic
        - No bullet points, no headers, just flowing prose
        - Do not mention the label name directly
        """
    }

    private func fallbackDescription(for profile: ScentProfile) -> String {
        let names = profile.topAccords.prefix(3).map { $0.name }.joined(separator: ", ")
        return "Your collection is anchored by \(names) — a combination that speaks of a considered, personal approach to fragrance. These aren't accidental choices."
    }
}
