//
//  PreferencesView.swift
//  KittyGPT
//
//  Created by huyphan on 5/27/23.
//

import SwiftUI

struct PreferencesView: View {
    @State private var backend: Backend = Configurations.backend
    @State private var openAIApiKey: String = Configurations.openAIApiKey
    @State private var awsCredsMode: AWSCredsMode = Configurations.awsCredsMode
    @State private var awsProfile: String = Configurations.awsProfile
    @State private var awsAccessKey: String = Configurations.awsAccessKey
    @State private var awsSecretKey: String = Configurations.awsSecretKey
    @State private var awsSessionToken: String = Configurations.awsSessionToken
    @State private var awsRegion: String = Configurations.awsRegion
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(alignment: .leading) {

            Text("Backend").padding(.top, 3)
            Picker(selection: $backend, label: Text("")) {
                Text("OpenAI")
                    .tag(Backend.openai)

                Text("Claude Instance v1 via AWS Bedrock")
                    .tag(Backend.bedrock_claude_instance_1)
            }
            .pickerStyle(.radioGroup)
            .padding(.bottom, 5)

            Divider().padding(.bottom, 5)
        
            if (backend == Backend.openai) {
                HStack(alignment: .top) {
                    Text("Open AI key").padding(.top, 3)
                    TextField("", text: $openAIApiKey)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                .padding(.leading, 20)
            }
                
            if (backend == Backend.bedrock_claude_instance_1) {
                Text("AWS credentials")
                    .padding(.top, 3)
                    .padding(.leading, 20)
                
                Picker(selection: $awsCredsMode, label: Text("")) {
                    Text("Use system profile")
                        .tag(AWSCredsMode.profile)
                    
                    Text("Input credentials")
                        .tag(AWSCredsMode.hardcoded)
                }
                .pickerStyle(.radioGroup)
                .padding(.bottom, 5)
                .padding(.leading, 20)
                
                if (awsCredsMode == AWSCredsMode.hardcoded) {
                    VStack {
                        HStack(alignment: .top) {
                            Text("AWS Access Key").padding(.top, 3)
                            TextField("", text: $awsAccessKey)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        HStack(alignment: .top) {
                            Text("AWS Secret Key").padding(.top, 3)
                            TextField("", text: $awsSecretKey)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        HStack(alignment: .top) {
                            Text("AWS Session Token").padding(.top, 3)
                            TextField("", text: $awsSessionToken)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                    }
                    .padding(.leading, 20)
                }
                
                if (awsCredsMode == AWSCredsMode.profile) {
                    VStack {
                        HStack(alignment: .top) {
                            Text("Profile").padding(.top, 3)
                            TextField("", text: $awsProfile)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                    }
                    .padding(.leading, 20)
                }
                
                HStack(alignment: .top) {
                    Text("AWS region").padding(.top, 3)
                    TextField("", text: $awsRegion)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                .padding(.leading, 20)
            }

            HStack() {
                Spacer()
                Button(action: {
                    saveApiKey()
                    dismiss()
                }) {
                    Text("Save and close")
                        .font(.headline)
                        .cornerRadius(10)
                }
                .controlSize(.large)
            }
        }
        .frame(width: 550)
        .padding()
    }
    
    private func saveApiKey() {
        Configurations.backend = backend
        Configurations.awsCredsMode = awsCredsMode
        Configurations.awsAccessKey = awsAccessKey
        Configurations.awsSecretKey = awsSecretKey
        Configurations.awsSessionToken = awsSessionToken
        Configurations.awsRegion = awsRegion
        Configurations.awsProfile = awsProfile
        Configurations.openAIApiKey = openAIApiKey
    }
}

struct PreferencesView_Previews: PreviewProvider {
    static var previews: some View {
        PreferencesView()
    }
}
