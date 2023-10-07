import Foundation

struct OpenAICompletionsBody: Encodable {
    let model: String
    let prompt: String
    let temperature: Float?
    let max_tokens: Int
}
struct OpenAICompletionResponse: Decodable {
    let id: String
    let choices: [OpenAICompletionResponseChoice]
}
struct OpenAICompletionResponseChoice: Decodable {
    let text: String
}
struct OpenAIChatBody: Encodable {
    let model: String
    let messages: [OpenAIConversationMessage]
    let temperature: Float?
    let max_tokens: Int
}
struct OpenAIConversationMessage: Encodable, Decodable {
    let role: String
    let content: String
}
struct OpenAIChatResponseChoice: Decodable {
    let message: OpenAIConversationMessage
}
struct OpenAIChatResponse: Decodable {
    let id: String
    let choices: [OpenAIChatResponseChoice]
}
