//
//  ImproveWriting.swift
//  KittyGPT
//
//  Created by Phan, Harry on 5/21/23.
//

import Foundation
import SwiftUI

struct ConciseWriting: View {
    
    @State var mainContent: String = ""
    
    var body: some View {
        QuestionEditor({
            Configuration {
                Text("Make the writing more concise").font(.title2)
            }
        }, mainContent: $mainContent, buildPrompt: self.buildPrompt)
    }
    
    func buildPrompt() -> String {
        return "Rewrite the following sentence(s) of paragraph(s) so it's more concise:\n\n" + self.mainContent
    }
}
