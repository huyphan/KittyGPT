//
//  ImproveWriting.swift
//  KittyGPT
//
//  Created by Phan, Harry on 5/21/23.
//

import Foundation
import SwiftUI

struct ImproveWriting: View {
    
    @State var mainContent: String = ""
    
    var body: some View {
        QuestionEditor({
            Configuration {
                Text("Improve this sentence or paragraph").font(.title2)
            }
        }, mainContent: $mainContent, buildPrompt: self.buildPrompt)
    }
    
    func buildPrompt() -> String {
        return "Rewrite the following sentence(s) of paragraph(s) so it's more convincing:\n\n" + self.mainContent
    }
}
