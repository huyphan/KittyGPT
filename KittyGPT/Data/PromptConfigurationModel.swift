//
//  PromptConfigurationModel.swift
//  KittyGPT
//
//  Created by huyphan on 5/27/23.
//

import Foundation

struct Field: Identifiable, Decodable {
    var id: String
    var name: String
    var type: String
    var options: [String]?
    var persistent: Bool?
}

struct Prompt: Identifiable, Decodable {
    var id: String
    var name: String
    var description: String
    var template: String
    var fields: [Field]
}

struct PromptGroup: Hashable, Identifiable, Decodable {
    public func hash(into hasher: inout Hasher) {
        return hasher.combine(id)
    }
    
    static func == (lhs: PromptGroup, rhs: PromptGroup) -> Bool {
        return lhs.id == rhs.id
    }
    
    var id: String
    var name: String
    var prompts: [Prompt]
}

struct PromptTemplate: Decodable {
    var groups: [PromptGroup]
}
