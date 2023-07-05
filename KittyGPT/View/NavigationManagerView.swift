//
//  NavigationManagerView.swift
//  KittyGPT
//
//  Created by huyphan on 5/27/23.
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

func saveDefaultPromptTemplate(fileURL: URL) {
    guard let asset = NSDataAsset(name: "DefaultPrompts") else {
        fatalError("Missing data asset: DefaultPrompts")
    }
    
    let data = asset.data
    do {
        try data.write(to: fileURL)
    } catch {
        fatalError("Couldn't save the default prompts to disk")
    }
}

func loadPromptConfigurations<T: Decodable>() -> T {
    
    let fileManager = FileManager.default
    let supportDirectory = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
    
    var data: String = ""
    let fileURL = supportDirectory?.appendingPathComponent("prompts.json")
    if (!FileManager.default.fileExists(atPath: fileURL!.absoluteString)) {
        saveDefaultPromptTemplate(fileURL: fileURL!)
    }
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
    var persistenceController = PersistenceController.shared
    
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
    
    func placeOrder() { }
    func adjustOrder() { }
    func rename() { }
    func delay() { }
    func cancelOrder() { }
    
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
                Divider()
                HStack {
                    Spacer()
                    Menu {
                        Button("Settings") {
                            if #available(macOS 13, *) {
                                NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
                            } else {
                                NSApp.sendAction(Selector(("showPreferencesWindow:")), to: nil, from: nil)
                            }
                        }
                        Button("Locate template file") {
                            let supportDirectory = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
                            let fileURL = supportDirectory!.appendingPathComponent("prompts.json")
                            NSWorkspace.shared.activateFileViewerSelecting([fileURL])
                        }
                        Button("Clear history") {
                            persistenceController.deleteAll()
                            viewContext.reset()
                            refreshID = UUID()
                        }
                    } label: {
                        Image(systemName: "gearshape.fill")
                    }
                    .menuStyle(BorderlessButtonMenuStyle())
                    .menuIndicator(.hidden)
                    .fixedSize()
                    .padding(.bottom, 8)
                }
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
            
            if (selectedPrompt == nil) {
                Text("Choose a prompt template from the sidebar to start")
                    .font(.system(size: 20))
                    .foregroundColor(.gray)
            }
            
            PromptEditor(prompt: selectedPrompt, shouldSendMessage: $shouldSendMessage)
            
            HStack {
                Spacer()
                Button(action: {
                    shouldSendMessage.toggle()
                }) {
                    Text("Send message")
                }
                .foregroundColor(.blue)
                .keyboardShortcut(.return, modifiers: .command)
                .controlSize(.large)
            }.padding(.horizontal)
            
            HStack {
                Spacer()
                Text("Shorcuts: Cmd-Enter to send message. Cmd-F to navigate the prompt templates")
                    .italic()
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

