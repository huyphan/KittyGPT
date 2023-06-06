//
//  NavigationManagerView.swift
//  KittyGPT
//
//  Created by Phan, Harry on 5/17/23.
//

import SwiftUI
import Combine

enum SideBarItem: String, Identifiable, CaseIterable {
    var id: String { rawValue }
    
    case improveWriting = "Writing - Make it read better"
    case conciseWriting = "Writing - Make it more concise"
    case alternativePhrases = "Writing - Alternative phrases"
    case grammarChecker = "Writing - Grammar and spelling checker"
    case writeCode = "Coding - Suggesting code snippet"
    case dynamicPrompt = "Test - Dynamic prompt"
}

func loadPromptConfigurations<T: Decodable>() -> T {
    
    let fileManager = FileManager.default
    let supportDirectory = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
    
    var data: String = ""
    let fileURL = supportDirectory?.appendingPathComponent("model.json")
    print("Reading the file \(fileURL)")
    do {
        data = try String(contentsOf: fileURL!)
    } catch {
        // Handle error reading file
        print("Error reading file: \(error.localizedDescription)")
    }
    
    
    do {
        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: data.data(using: .utf8)!)
    } catch {
        fatalError("Couldn't parse the prompt configuration file as \(T.self):\n\(error)")
    }
}

struct NavigationmanagerView: View {
    @State var sideBarVisibility: NavigationSplitViewVisibility = .doubleColumn
    @State var selectedSideBarItem: String = ""
    @State var shouldSendMessage: Bool = false
    @State private var refreshID = UUID()
    
    @FetchRequest
    private var messages: FetchedResults<ChatMessage>
    private var request: NSFetchRequest<ChatMessage>
    
    private var promptConfigurations: PromptConfigurations = loadPromptConfigurations()
    private var prompts: [String: Prompt] = [:]

    @FocusState private var isPromptTemplateListFocused: Bool
    @Binding var shouldFocusPromptTemplateList: Bool
    
    @Environment(\.managedObjectContext) private var viewContext

    
    init(shouldFocusPromptTemplateList: Binding<Bool>) {
        request = ChatMessage.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(
                keyPath: \ChatMessage.createdAt,
                ascending: false)]
        request.fetchLimit = 20
        _messages = FetchRequest(fetchRequest: request)
        _shouldFocusPromptTemplateList = shouldFocusPromptTemplateList

        for group in promptConfigurations.groups {
            for prompt in group.prompts {
                prompts[prompt.id] = prompt
            }
        }
    }

    var selectedPrompt: Prompt? {
        return prompts[selectedSideBarItem]
    }
    
    var body: some View {
        NavigationSplitView(columnVisibility: $sideBarVisibility) {
            VStack {
                List(selection: $selectedSideBarItem) {
                    ForEach(promptConfigurations.groups, id: \.self) { group in
                        Section(header: Text("★ " + group.name).font(.title2)) {
                            ForEach(group.prompts) { prompt in
                                NavigationLink(
                                    prompt.name,
                                    value: prompt.id
                                )
                            }
                        }
                    }
                }
                .listStyle(DefaultListStyle()) // Use the DefaultListStyle as a starting point
                .listRowInsets(EdgeInsets()) // Remove the row insets to make it look like a grouped style
                // Add more styling as desired
                // For example, you can adjust the font, colors, and spacing
                .font(.body)
                .foregroundColor(.primary)
                .padding(.vertical, 8)
                .onChange(of: shouldFocusPromptTemplateList) { _ in
                    isPromptTemplateListFocused = true
                }
                .focused($isPromptTemplateListFocused)
                
                
                Spacer()
                
            }.focusSection()
        }
        detail: {
            VStack {
                // Message list
                ScrollViewReader { proxy in
                    ScrollView {
                        ForEach(self.messages.reversed(), id: \.self) { item in
                            MessageView(message: item).id(item.id)
                        }
                        .id(refreshID)
                    }
                    .onChange(of: messages.first?.id) { _ in
                        proxy.scrollTo(messages.first?.id, anchor: .bottom)
                    }
                    .onAppear(perform: {
                        proxy.scrollTo(messages.first?.id, anchor: .bottom)
                    })
                }
                .padding(.bottom, 30)
                Spacer()
                PromptEditor(prompt: selectedPrompt, shouldSendMessage: $shouldSendMessage)
                HStack {
                    Spacer()
                    
                    Button(action: {
                        let supportDirectory = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
                        let fileURL = supportDirectory!.appendingPathComponent("model.json")
                        NSWorkspace.shared.activateFileViewerSelecting([fileURL])
                    }) {
                        Text("Locate configuration file")
                    }
                    .controlSize(.large)
                    .padding(0)
                    
                    Button(action: {
                        // This code should be moved to PersistenceController
                        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = ChatMessage.fetchRequest()
                        
                        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
                        
                        do {
                            try viewContext.execute(batchDeleteRequest)
                            try viewContext.save()
                            viewContext.reset()
                        } catch {
                            // Handle error
                            print("Error deleting data: \(error)")
                        }
                        refreshID = UUID()
                    }) {
                        Text("Clear history")
                    }
                    .controlSize(.large)
                    .padding(0)
                    
                    Button(action: {
                        shouldSendMessage.toggle()
                    }) {
                        Text("Send message")
                    }
                    .foregroundColor(.blue)
                    .keyboardShortcut(.return, modifiers: .command)
                    .controlSize(.large)
                    .padding(0)
                }
            }
            .padding()
            .background(Color(red: 44/256, green: 48/256, blue: 50/256))
        }
    }
}

struct NavigationmanagerView_Previews: PreviewProvider {
    static var previews: some View {
        @State var shouldFocusPromptTemplateList: Bool = false
        NavigationmanagerView(shouldFocusPromptTemplateList: $shouldFocusPromptTemplateList)
            .environmentObject(PersistenceController.preview)
    }
}

