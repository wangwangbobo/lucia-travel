import Foundation

/// Talks to the hosted Pico function. The API key lives only on the server
/// (Qoder Sites Secret / the local proxy); it is never bundled in the app.
enum PicoService {
    struct Turn: Encodable {
        let role: String
        let content: String
    }

    struct Context: Encodable {
        let tab: String
        let day: String?
        let planBuilt: Bool
        let days: Int?
        let style: String?
        let theme: String?
        let note: String?
        let stage: String
        let language: String
    }

    private struct Body: Encodable {
        let messages: [Turn]
        let context: Context
    }

    private struct Reply: Decodable {
        let ok: Bool
        let reply: String?
        let error: String?
    }

    enum Failure: LocalizedError {
        case unreachable
        case upstream
        case invalid

        var errorDescription: String? {
            switch self {
            case .unreachable: return "Pico couldn't reach the live model just now. Try once more in a moment."
            case .upstream: return "Pico is getting a lot of questions right now. Try again in a minute."
            case .invalid: return "The live assistant returned an empty answer. Try asking once more."
            }
        }
    }

    static var endpoint: URL {
        #if DEBUG
        let args = ProcessInfo.processInfo.arguments
        if let index = args.firstIndex(of: "-picoEndpoint"),
           args.indices.contains(index + 1),
           let url = URL(string: args[index + 1]) {
            return url
        }
        #endif
        if let saved = UserDefaults.standard.string(forKey: "pico.endpoint"),
           let url = URL(string: saved) {
            return url
        }
        // Temporary public demo backend: the local proxy behind a Cloudflare quick
        // tunnel, so the key stays on this Mac. Swap for the Sites function URL
        // (https://roamchina-pico-6n9ilgtpldd.qoder.website/functions/v1/app/chat)
        // once PICO_API_KEY is entered in Site Settings and the site is published.
        return URL(string: "https://donations-enters-menus-lightweight.trycloudflare.com/api/chat")!
    }

    static func reply(history: [ChatMessage], context: Context) async throws -> String {
        var turns: [Turn] = []
        for message in history.suffix(12) {
            let text = message.text.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !text.isEmpty, !text.contains("<") else { continue }
            turns.append(Turn(role: message.role == .user ? "user" : "assistant", content: String(text.prefix(2000))))
        }
        guard turns.last?.role == "user" else { throw Failure.invalid }

        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.timeoutInterval = 50
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(Body(messages: turns, context: context))

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await URLSession.shared.data(for: request)
        } catch {
            throw Failure.unreachable
        }

        guard let http = response as? HTTPURLResponse else { throw Failure.unreachable }
        guard let payload = try? JSONDecoder().decode(Reply.self, from: data) else {
            throw http.statusCode == 429 ? Failure.upstream : Failure.invalid
        }
        guard http.statusCode == 200, payload.ok, let text = payload.reply?.trimmingCharacters(in: .whitespacesAndNewlines), !text.isEmpty else {
            throw payload.error == "rate_limited" ? Failure.upstream : Failure.invalid
        }
        return text
    }
}
