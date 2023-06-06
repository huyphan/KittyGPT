//
//  QuestionEditor.swift
//  KittyGPT
//
//  Created by Phan, Harry on 5/21/23.
//

import Combine
import Foundation
import SwiftUI

typealias Configuration<V> = Group<V> where V:View
typealias MainContent<V> = Group<V> where V:View

struct QuestionEditor<Configuration: View>: View {
    
    var buildPrompt: (() -> String)
    @Binding var mainContent: String
    
    private let config: Configuration
    let openAIService = OpenAIService()
    
    @State var cancellables = Set<AnyCancellable>()
    @State var isLoading = false
    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    
    @Environment(\.managedObjectContext) private var viewContext
    
    init(@ViewBuilder _ content: () -> Configuration, mainContent: Binding<String>, buildPrompt: @escaping () -> String) {
        self.config = content()
        self._mainContent = mainContent
        self.buildPrompt = buildPrompt
    }
    
    var body: some View {
        
        VStack {
            HStack(alignment: .bottom) {
                config
                if (isLoading) {
                    ProgressView().padding()
                } else {
                    Button(action: {
                        sendMessage()
                    }) {
                        Image(systemName: "paperplane").padding(.vertical, 5.0)
                    }
                    .foregroundColor(.blue)
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
    
    
    func sendMessage (){
        guard mainContent != "" else {
            return
        }
        let prompt = self.buildPrompt()
        
        let myMessage = ChatMessage(context: viewContext)
        myMessage.id = UUID().uuidString
        myMessage.content = prompt.trimmingCharacters(in: ["\n"])
        myMessage.createdAt = Date()
        myMessage.sender = "me"
        do {
            try viewContext.save()
        } catch {
            print("Error when saving message")
        }
        
        isLoading = true
        openAIService.sendMessage(message: prompt).sink { completion in
            switch completion {
            case .failure(_):
                showErrorAlert = true
                errorMessage = "Failed to send prompt to OpenAI"
            case .finished: print("Received response")
            }
            isLoading = false
        } receiveValue: { response in
            guard let textResponse = response.choices.first?.text.trimmingCharacters(in: .whitespacesAndNewlines.union(.init(charactersIn: "\""))) else {return}
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
        
        mainContent = ""
        showErrorAlert = false
        errorMessage = ""
    }
}




struct QuestionEditor_Previews: PreviewProvider {
    static var previews: some View {
        QuestionEditor({
            Configuration {
                Text("Improve this sentence or paragraph")
            }
        }, mainContent: .constant(""), buildPrompt: { return ""})
    }
}
