import Foundation
import Alamofire
import Combine

class OpenAIService {
    var completionUrl = "https://api.openai.com/v1/completions"
    var chatUrl = "https://api.openai.com/v1/chat/completions"
    var isLoading: Bool = false
    
    func sendCompletion(message: String) -> AnyPublisher<OpenAICompletionResponse, Error> {
        let body = OpenAICompletionsBody(model: "text-davinci-003", prompt: message, temperature: 0.6, max_tokens: 256)
        
        let apiKey = UserDefaults.standard.string(forKey: "openAiApiKey")
        
        let headers: HTTPHeaders = [
            "Authorization" : "Bearer \(apiKey ?? "")"
        ]
        
        return Future { [weak self] promise in
            guard let self = self else {return}
            AF.request(self.completionUrl, method: .post, parameters: body, encoder: .json, headers: headers)
                .responseDecodable(of: OpenAICompletionResponse.self) { response in
                    
                    switch response.result {
                    case .success(let result): promise(.success(result))
                        
                    case.failure(let error): promise(.failure(error))
                    }
                }
        }
        .eraseToAnyPublisher()
    }
    
    func sendChatCompletion(messages: [OpenAIConversationMessage]) -> AnyPublisher<OpenAIChatResponse, Error> {
        let body = OpenAIChatBody(model: "gpt-3.5-turbo", messages: messages, temperature: 0.6, max_tokens: 256)
        print(body)
        let apiKey = UserDefaults.standard.string(forKey: "openAiApiKey")
        
        let headers: HTTPHeaders = [
            "Authorization" : "Bearer \(apiKey ?? "")"
        ]
        
        return Future { [weak self] promise in
            guard let self = self else {return}
            AF.request(self.chatUrl, method: .post, parameters: body, encoder: .json, headers: headers)
                .responseJSON { response in
                    print(response)
                }
                .responseDecodable(of: OpenAIChatResponse.self) { response in

                    switch response.result {
                    case .success(let result): promise(.success(result))
                        
                    case.failure(let error): promise(.failure(error))
                    }
                }
        }
        .eraseToAnyPublisher()
    }
}
