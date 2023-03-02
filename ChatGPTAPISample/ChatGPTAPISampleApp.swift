//
//  ChatGPTAPISampleApp.swift
//  ChatGPTAPISample
//
//  Created by Masaki Hayashi on 2023/03/02.
//

import SwiftUI

@main
struct ChatGPTAPISampleApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: ViewModel())
        }
    }
}
