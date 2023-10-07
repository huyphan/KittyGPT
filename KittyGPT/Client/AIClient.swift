import Combine

struct ChatResponse: Decodable {
    let id: String
    let message: String
}

struct ConversationMessage: Encodable, Decodable {
    let role: Role
    let content: String
}

enum Role: String, Codable {
    case human = "user"
    case assistant = "assistant"
}

protocol AIService {
    func sendChatCompletion(messages: [ConversationMessage]) -> AnyPublisher<ChatResponse, Error>
}

