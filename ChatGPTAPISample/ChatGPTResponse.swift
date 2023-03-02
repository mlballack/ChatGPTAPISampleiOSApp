//
//  ChatGPTResponse.swift
//  ChatGPTAPISample
//
//  Created by 林 政樹 on 2023/03/02.
//

import Foundation

struct ChatGPTResponse: Codable {
    var id: String
    var object: String
    var created: Int
    var model: String
    var choices: [Choice]
    var usage: Usage
    
    struct Choice: Codable {
        var index: Int
        var finish_reason: String
        var message: Message
        //var messages: [Message]?
        
        struct Message: Codable {
            var role: String
            var content: String
        }
    }
    
    struct Usage: Codable {
        var prompt_tokens: Int
        var completion_tokens: Int
        var total_tokens: Int
    }
}
