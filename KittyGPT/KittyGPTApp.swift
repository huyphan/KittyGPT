//
//  KittyGPTApp.swift
//  KittyGPT
//
//  Created by huyphan on 5/27/23.
//

import SwiftUI
import Combine
import SettingsAccess

@main
struct KittyGPTApp: App {
    @StateObject private var persistenceController = PersistenceController.shared
    @Environment(\.scenePhase) var scenePhase
    
    @State var shouldFocusPromptTemplateList: Bool = false
    
    var body: some Scene {
        WindowGroup {
            NavigationmanagerView(shouldFocusPromptTemplateList: $shouldFocusPromptTemplateList)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .openSettingsAccess()
        }
        .onChange(of: scenePhase) { _ in
            persistenceController.save()
        }.commands {
            CommandMenu("Tools") {
                Button("Choose prompt template") {
                    shouldFocusPromptTemplateList.toggle()
                }.keyboardShortcut("f", modifiers: .command)
            }
        }
        Settings {
          PreferencesView()
        }
    }
}
