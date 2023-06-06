//
//  ImproveWriting.swift
//  KittyGPT
//
//  Created by Phan, Harry on 5/21/23.
//

import Foundation
import SwiftUI

struct CodeSnippet: View {
    
    @State var mainContent: String = ""
    @State private var context = ""
    var body: some View {
        QuestionEditor({
            Configuration {
                VStack {
                    Text("Ask ChatGPT to write code for a use case").font(.title2)
                    TextField("Language of framework", text: $context)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                        .disableAutocorrection(true)
                }
            }
        }, mainContent: $mainContent, buildPrompt: self.buildPrompt)
    }
    
    func buildPrompt() -> String {
        return "Write a \(self.context) code to \(self.mainContent)"
    }
}
