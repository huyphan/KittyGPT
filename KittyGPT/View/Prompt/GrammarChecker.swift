//
//  ImproveWriting.swift
//  KittyGPT
//
//  Created by Phan, Harry on 5/21/23.
//

import Foundation
import SwiftUI

struct GrammarChecker: View {
    
    @State var mainContent: String = ""
    
    var body: some View {
        QuestionEditor({
            Configuration {
                Text("Grammar and spelling checker").font(.title2)
            }
        }, mainContent: $mainContent, buildPrompt: self.buildPrompt)
    }
    
    func buildPrompt() -> String {
        return "Check for grammar and spelling error in the following sentence or paragraph:\n\n" + self.mainContent
    }
}
