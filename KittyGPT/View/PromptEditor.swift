import Combine
import Foundation
import SwiftUI

struct PromptEditor: View {
    var prompt: Prompt?
    
    @Environment(\.managedObjectContext) private var viewContext
    
    let openAIService = OpenAIService()
    
    @State var cancellables = Set<AnyCancellable>()
    @State var isLoading = false
    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    @State private var formResponse: [String: String] = [:]
    @Binding var shouldSendMessage: Bool
    
    var body: some View {
        VStack {
            if (isLoading) {
                ProgressView().padding()
            }
            if (prompt != nil) {
                HStack(alignment: .bottom) {
                    VStack {
                        Text(prompt!.description ?? "NO DESCRIPTION").font(.title2)
                        ForEach(prompt!.fields ?? []) { field in
                            VStack {
                                switch field.type {
                                case "single-line":
                                    TextField(field.name, text: Binding(
                                        get: {
                                            formResponse[field.name] ?? ""
                                        },
                                        set: { newValue in
                                            formResponse[field.name] = newValue
                                        })
                                    )
                                    .padding(0)
                                    .frame(height: 40)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .lineSpacing(40)
                                    
                                case "multiple-lines":
                                    HStack {
                                        TextEditor(text: Binding(
                                            get: {
                                                formResponse[field.name] ?? ""
                                            },
                                            set: { newValue in
                                                formResponse[field.name] = newValue
                                            })
                                        )
                                        .padding(10)
                                        .frame(height: 100)
                                        .font(.title3)
                                        .scrollContentBackground(.hidden)
                                        .background(Color(red: 54/256, green: 58/256, blue: 61/256))
                                    }
                                    .background(Color(red: 54/256, green: 58/256, blue: 61/256))
                                    .cornerRadius(10)
                                    
                                default:
                                    EmptyView()
                                }
                            }
                        }
                    }
                }
                .onChange(of: shouldSendMessage) { _ in
                    sendMessage()
                }
            }
        }
        .alert(isPresented: $showErrorAlert) {
            Alert(
                title: Text("Error"),
                message: Text("An error occurred: \(errorMessage)"),
                dismissButton: .default(Text("OK"))
            )
        }
        .padding()
    }
    
    func buildMessage() -> String {
        var message: String = prompt?.template ?? ""
        for field in prompt?.fields ?? [] {
            message = message.replacingOccurrences(of: "{\(field.name)}", with: formResponse[field.name] ?? "")
        }
        return message
    }

    func containsEmpty() -> Bool {
        if (prompt == nil) {
            return true
        }
        for field in prompt!.fields {
            if formResponse[field.name] == nil || formResponse[field.name]?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
                return true
            }
        }
        return false
    }

    func sendMessage (){
        guard !containsEmpty() else {
            return
        }
        let message = self.buildMessage()

        // Save the question
        let myMessage = ChatMessage(context: viewContext)
        myMessage.id = UUID().uuidString
        myMessage.content = message.trimmingCharacters(in: .whitespacesAndNewlines)
        myMessage.createdAt = Date()
        myMessage.sender = "me"

        do {
            try viewContext.save()
        } catch {
            print("Error when saving message")
        }
        
        isLoading = true
        openAIService.sendMessage(message: message).sink { completion in
            switch completion {
            case .failure(_):
                showErrorAlert = true
                errorMessage = "Failed to send prompt to OpenAI. Check your API Key in Settings."
            case .finished: print("Received response")
            }
            isLoading = false
        } receiveValue: { response in
            guard let textResponse = response.choices.first?.text.trimmingCharacters(in: .whitespacesAndNewlines.union(.init(charactersIn: "\""))) else {return}
            
            // Save the answer
            let chatGPTMessage = ChatMessage(context: viewContext)
            chatGPTMessage.id = response.id
            chatGPTMessage.content = textResponse
            chatGPTMessage.createdAt = Date()
            chatGPTMessage.sender = "chatGPT"
            do {
                try viewContext.save()
            } catch {
                showErrorAlert = true
                errorMessage = "Can't save message to local database"
            }
            isLoading = false
        }
        .store(in: &cancellables)

        prompt?.fields.forEach { field in
            if field.persistent == nil || !field.persistent! {
                formResponse.removeValue(forKey: field.name)
            }
        }
        
        showErrorAlert = false
        errorMessage = ""
    }
}
