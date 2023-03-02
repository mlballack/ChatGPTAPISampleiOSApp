//
//  ContentView.swift
//  ChatGPTwithSpeech
//
//  Created by Masaki Hayashi on 2023/03/02.
//

import SwiftUI

struct ContentView<ViewModel: ViewModelProtocol>: View {
    @ObservedObject var viewModel: ViewModel
    @State private var text = ""
    @FocusState var focus: Bool
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                VStack {
                    ScrollViewReader { proxy in
                        ScrollView {
                            ForEach(viewModel.messages, id: \.self) {message in
                                let color: UIColor = message.role == .user ? UIColor.lightGray : UIColor.white
                                let side: CGFloat = message.role == .user ? 30 : 0
                                Text(message.content)
                                    .foregroundColor(.init(uiColor: color))
                                    .font(.title3)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.init(top: 20, leading: side, bottom: 10, trailing: side))
                            }
                            Color.clear.padding(.bottom, 60).id(200)
                        }
                        .onChange(of: viewModel.messages) { _ in
                            withAnimation {
                                proxy.scrollTo(200)
                            }
                        }
                    }
                    
                    Spacer()
                    HStack {
                        ZStack(alignment : .leading){
                            TextField("ここに入力", text: $text, axis: .vertical)
                                .foregroundColor(Color.black)
                                .lineLimit(2)
                                //.font(.title3)
                                .focused($focus)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        Button {
                            focus = false
                            viewModel.askChatGPT(text: text)
                            text = ""
                        } label: {
                            Image(systemName: "paperplane")
                                .foregroundColor(Color.blue)
                                .font(.title2)
                        }
                    }
                }
                .padding(.init(top: geometry.safeAreaInsets.top + 10, leading: 20, bottom: geometry.safeAreaInsets.bottom+10, trailing: 20))
                .onTapGesture {
                    focus.toggle()
                }
            }
            .edgesIgnoringSafeArea(.all)
            
            if viewModel.isAsking {
                withAnimation {
                    ZStack {
                        Color.black.opacity(0.5)
                            .edgesIgnoringSafeArea(.all)
                        ActivityIndicator()
                    }
                }
            }
        }
        .background(Color.init(uiColor: .black))
        .alert(isPresented: $viewModel.showAlert) {
            Alert(
                title: Text("確認"),
                message: Text(viewModel.errorText)
            )
        }
    }
}

struct ActivityIndicator: UIViewRepresentable {
    func makeUIView(context: UIViewRepresentableContext<ActivityIndicator>) -> UIActivityIndicatorView {
        return UIActivityIndicatorView(style: .large)
    }
    func updateUIView(_ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<ActivityIndicator>) {
        uiView.startAnimating()
    }
}
