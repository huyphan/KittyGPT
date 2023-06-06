//
//  PreferencesView.swift
//  KittyGPT
//
//  Created by huyphan on 5/27/23.
//

import SwiftUI

struct PreferencesView: View {
    @State private var apiKey: String = ""
    @State private var isApiKeySaved: Bool = false
    
    init() {
        _apiKey = State(initialValue: UserDefaults.standard.string(forKey: "openAiApiKey") ?? "")
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top) {
                Text("API Key").padding(.top, 3)
                TextField("", text: $apiKey)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .onChange(of: apiKey) { _ in
                        isApiKeySaved = false
                    }
            }
            HStack() {
                Spacer()
                Button(action: {
                    saveApiKey()
                }) {
                    Text("Save")
                        .font(.headline)
                        .padding()
                        .cornerRadius(10)
                }
                .controlSize(.large)
                .disabled(apiKey.isEmpty || isApiKeySaved)
            }
        }
        .frame(width: 400, height: 100)
        .padding()
    }
    
    private func saveApiKey() {
        UserDefaults.standard.set(apiKey, forKey: "openAiApiKey")
        isApiKeySaved = true
    }
}

struct PreferencesView_Previews: PreviewProvider {
    static var previews: some View {
        PreferencesView()
    }
}
