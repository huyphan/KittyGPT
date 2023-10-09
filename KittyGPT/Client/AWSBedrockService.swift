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

enum InitializationError: Error {
    case invalidCredentials
    case emptyCredentials
    case unknownError
}

enum RequestError: Error {
    case invalidModel
}

class AWSBedrockService: AIService {
    
    let client: BedrockRuntimeClient
    
    public init() throws {
        do {
            let region = Configurations.awsRegion
            let accessKey = Configurations.awsAccessKey
            let secretKey = Configurations.awsSecretKey
            let sessionToken = Configurations.awsSessionToken
            let profile = Configurations.awsProfile
            
            let credentialsProvider: CredentialsProviding
            if (Configurations.awsCredsMode == AWSCredsMode.profile) {
                if (region == "" || profile == "") {
                    throw InitializationError.emptyCredentials
                }
                credentialsProvider = try ProfileCredentialsProvider(profileName: profile)
            } else {
                if (region == "" || accessKey == "" || secretKey == "") {
                    throw InitializationError.emptyCredentials
                }
                credentialsProvider = try StaticCredentialsProvider(Credentials(accessKey: accessKey, secret: secretKey, sessionToken: sessionToken))
            }
            
            let config = try BedrockRuntimeClient.BedrockRuntimeClientConfiguration(region: region, credentialsProvider: credentialsProvider)
            client = BedrockRuntimeClient(config: config)
        } catch {
            print("ERROR: ", dump(error, name: "Initializing Bedrock runtime client"))
            throw InitializationError.unknownError
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
                var modelId: String = ""

                switch Configurations.backend {
                case Backend.bedrock_claude_instance_v1:
                    modelId = "anthropic.claude-instant-v1"
                case Backend.bedrock_claude_v2:
                    modelId = "anthropic.claude-v2"
                default:
                    promise(.failure(RequestError.invalidModel))
                }

                let input = try InvokeModelInput(
                    accept: "application/json",
                    body: jsonEncoder.encode(body),
                    contentType: "application/json",
                    modelId: modelId
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
