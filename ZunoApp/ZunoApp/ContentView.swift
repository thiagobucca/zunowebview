//
//  ContentView.swift
//  ZunoApp
//
//  Created by Thiago Bucca on 02/08/25.
//

import SwiftUI

struct ContentView: View {
    @State private var urlText: String = ""
    @State private var showWebView = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 40) {
                Spacer()
                
                // Título Zuno
                Text("Zuno")
                    .font(.system(size: 48, weight: .bold, design: .default))
                    .foregroundColor(.blue)
                
                Spacer()
                
                // Campo de entrada de URL
                VStack(spacing: 20) {
                    TextField("Digite a URL do site", text: $urlText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.URL)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .padding(.horizontal, 40)
                        .frame(height: 50)
                    
                    // Botão Abrir Site
                    Button(action: openWebsite) {
                        Text("Abrir Site")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.white)
                            .frame(width: 150, height: 50)
                            .background(urlText.isEmpty ? Color.gray : Color.blue)
                            .cornerRadius(10)
                    }
                    .disabled(urlText.isEmpty)
                }
                
                Spacer()
                Spacer()
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showWebView) {
            WebViewContainer(url: formatURL(urlText))
        }
        .alert("Erro", isPresented: $showAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
    }
    
    private func openWebsite() {
        guard !urlText.isEmpty else {
            alertMessage = "Por favor, digite uma URL válida."
            showAlert = true
            return
        }
        
        let formattedURL = formatURL(urlText)
        guard URL(string: formattedURL) != nil else {
            alertMessage = "URL inválida. Por favor, verifique e tente novamente."
            showAlert = true
            return
        }
        
        showWebView = true
    }
    
    private func formatURL(_ urlString: String) -> String {
        var formatted = urlString.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if !formatted.hasPrefix("http://") && !formatted.hasPrefix("https://") {
            formatted = "https://" + formatted
        }
        
        return formatted
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

