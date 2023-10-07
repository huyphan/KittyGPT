import Foundation
import Alamofire
import Combine

class OpenAIService: AIService {
    var completionUrl = "https://api.openai.com/v1/completions"
    var chatUrl = "https://api.openai.com/v1/chat/completions"
    
    func sendChatCompletion(messages: [ConversationMessage]) -> AnyPublisher<ChatResponse, Error> {
        let openAIMessages: [OpenAIConversationMessage] = messages.map { m in
            return OpenAIConversationMessage(role: m.role == Role.human ? "user" : "assistant", content: m.content)
        }
        let body = OpenAIChatBody(model: "gpt-3.5-turbo", messages: openAIMessages, temperature: 0.6, max_tokens: Configurations.maxReturnedToken)

        let apiKey = UserDefaults.standard.string(forKey: "openAiApiKey")
        
        let headers: HTTPHeaders = [
            "Authorization" : "Bearer \(apiKey ?? "")"
        ]
        
        return Future { [weak self] promise in
            guard let self = self else {return}
            AF.request(self.chatUrl, method: .post, parameters: body, encoder: .json, headers: headers)
                .responseDecodable(of: OpenAIChatResponse.self) { response in

                    switch response.result {
                    case .success(let result):
                        guard let textResponse = result.choices.first?.message.content.trimmingCharacters(in: .whitespacesAndNewlines.union(.init(charactersIn: "\""))) else {return}
                        let id = result.id
                        promise(.success(ChatResponse(id: id, message: textResponse)))
                        
                    case.failure(let error): promise(.failure(error))
                    }
                }
        }
        .eraseToAnyPublisher()
    }
}
