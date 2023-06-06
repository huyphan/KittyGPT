//
//  ImproveWriting.swift
//  KittyGPT
//
//  Created by Phan, Harry on 5/21/23.
//

import Foundation
import SwiftUI

struct Thesaurus: View {
    
    @State var mainContent: String = ""
    
    var body: some View {
        QuestionEditor({
            Configuration {
                Text("Alternative words or phrases").font(.title2)
            }
        }, mainContent: $mainContent, buildPrompt: self.buildPrompt)
    }
    
    func buildPrompt() -> String {
        return "What are the alternative words or phrases for \"\(self.mainContent)\"?"
    }
}
