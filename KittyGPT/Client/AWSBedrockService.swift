import Foundation
import Alamofire
import Combine
import AWSBedrockRuntime
import ClientRuntime
import ClientRuntime
import AWSClientRuntime

struct RequestMessageBody: Encodable {
    let prompt: String
    let max_tokens_to_sample: Int
}

struct ResponseMessageBody: Decodable {
    let completion: String;
}

class AWSBedrockService: AIService {
    
    let client: BedrockRuntimeClient
    
    public init() {
        do {
            let region = UserDefaults.standard.string(forKey: "awsRegion") ?? "us-east-1"
            let credentialsProvider: CredentialsProviding
            if (Configurations.awsCredsMode == AWSCredsMode.profile) {
                credentialsProvider = try ProfileCredentialsProvider(profileName: Configurations.awsProfile)
            } else {
                credentialsProvider = try StaticCredentialsProvider(Credentials(accessKey: Configurations.awsAccessKey, secret: Configurations.awsSecretKey))
            }
            
            let config = try BedrockRuntimeClient.BedrockRuntimeClientConfiguration(region: region, credentialsProvider: credentialsProvider)
            client = try BedrockRuntimeClient(config: config)
        } catch {
            print("ERROR: ", dump(error, name: "Initializing Bedrock runtime client"))
            exit(1)
        }
    }
    
    func sendChatCompletion(messages: [ConversationMessage]) -> AnyPublisher<ChatResponse, Error> {
        var prompt = ""
        for message in messages {
            if (message.role == Role.human) {
                prompt.append("\n\nHuman: " + message.content)
            } else {
                prompt.append("\n\nAssistant: " + message.content)
            }
        }
        prompt.append("\n\nAssistant: ")
        let body: RequestMessageBody = RequestMessageBody(
            prompt: prompt,
            max_tokens_to_sample: Configurations.maxReturnedToken
        )

        let jsonEncoder = JSONEncoder()

        return Future { [self] promise in
            do {
                let input = try InvokeModelInput(
                    accept: "application/json",
                    body: jsonEncoder.encode(body),
                    contentType: "application/json",
                    modelId: "anthropic.claude-instant-v1"
                )
                Task { @MainActor [self] in
                    do {
                        let response = try await self.client.invokeModel(input: input)
                        let jsonDecoder = JSONDecoder()
                        let textResponse = try jsonDecoder.decode(ResponseMessageBody.self, from: (response.body)!).completion
                        let milliseconds = Int(Date().timeIntervalSince1970 * 1000)
                        promise(.success(ChatResponse(id: "bedrock-\(milliseconds)", message: textResponse)))
                    } catch {
                        promise(.failure(error))
                    }
                }
            } catch {
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
}
