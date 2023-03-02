//
//  ViewModel.swift
//  ChatGPTAPISample
//
//  Created by Masaki Hayashi on 2023/03/02.
//

import Foundation
import SwiftUI
import Alamofire

struct Message: Hashable {
    var content: String
    var role: Role
    
    enum Role: String {
        case system = "system"
        case user = "user"
        case assistant = "assistant"
    }
}

protocol ViewModelProtocol:ObservableObject {
    var messages: [Message] { get }
    var isAsking: Bool { get }
    var showAlert: Bool { get set }
    var errorText: String { get }
    func askChatGPT(text: String)
}

final class ViewModel: ViewModelProtocol {
    @Published public var messages: [Message] = []
    @Published public var isAsking: Bool = false
    @Published public var errorText: String = ""
    @Published public var showAlert = false

    private let token = ""
    
    private let setting: Message? = Message(
        content: "あなたは、素人質問ですがという前置きで学部生や大学院生に恐れられている大学の教授です。",
        role: .system
    )
    
    public func askChatGPT(text: String) {
        if text.isEmpty { return }
        isAsking = true
        add(text: text, role: .user)
        send(text: text)
    }
    
    private func responseSuccess(data: ChatGPTResponse) {
        guard let message = data.choices.first?.message else { return }
        add(text: message.content, role: .assistant)
        isAsking = false
    }
    
    private func responseFailure(error: String) {
        errorText = error
        showAlert = true
        isAsking = false
    }
    
    private func add(text: String, role: Message.Role) {
        messages.append(.init(content: text, role: role))
    }
}

extension ViewModel {
    private func send(text: String) {
        let headers: HTTPHeaders = [
            "Content-type": "application/json",
            "Authorization":"Bearer \(token)"
        ]
        
        var messages = convertToMessages(text: text)
        if setting != nil {
            messages.insert(["content":setting!.content, "role":setting!.role.rawValue], at: 0)
        }
        let parameters: [String: Any] = [
            "model": "gpt-3.5-turbo",
            "messages": messages,
        ]

        AF.request(
            "https://api.openai.com/v1/chat/completions",
            method: .post,
            parameters: parameters,
            encoding: JSONEncoding.default,
            headers: headers
        ).responseData(completionHandler: { response in
            switch response.result {
            case .success(let data):
                guard let res = try? JSONDecoder().decode(ChatGPTResponse.self, from: data) else {
                    self.responseFailure(error: "Decode error")
                    return
                }
                self.responseSuccess(data: res)
                break
            case .failure(let error):
                self.responseFailure(error: error.localizedDescription)
                break
            }
        })
    }
    
    private func convertToMessages(text: String) -> [[String: String]] {
        return messages.map { ["content": $0.content, "role": $0.role.rawValue] }
    }
}
