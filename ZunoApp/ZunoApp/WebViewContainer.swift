//
//  Untitled.swift
//  ZunoApp
//
//  Created by Thiago Bucca on 02/08/25.
//
import SwiftUI
import WebKit

struct WebViewContainer: View {
    let url: String
    @Environment(\.presentationMode) var presentationMode
    @State private var isLoading = true
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        ZStack {
            // WebView simplificada
            SimpleWebView(
                urlString: url,
                isLoading: $isLoading,
                showError: $showError,
                errorMessage: $errorMessage
            )
            .edgesIgnoringSafeArea(.all)
            
            // Indicador de carregamento
            if isLoading {
                VStack {
                    ProgressView()
                        .scaleEffect(1.5)
                        .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                    Text("Carregando...")
                        .padding(.top, 10)
                        .foregroundColor(.blue)
                        .font(.system(size: 16, weight: .medium))
                }
                .padding()
                .background(Color.white.opacity(0.9))
                .cornerRadius(10)
                .shadow(radius: 5)
            }
        }
        .navigationBarHidden(true)
        .gesture(
            // Gesto de deslizar da borda esquerda para sair
            DragGesture()
                .onEnded { value in
                    if value.startLocation.x < 30 && value.translation.width > 100 {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
        )
        .onLongPressGesture(minimumDuration: 2.0) {
            // Toque longo de 2 segundos para sair
            presentationMode.wrappedValue.dismiss()
        }
        .alert("Erro de Carregamento", isPresented: $showError) {
            Button("Voltar") {
                presentationMode.wrappedValue.dismiss()
            }
        } message: {
            Text(errorMessage)
        }
    }
}

struct SimpleWebView: UIViewRepresentable {
    let urlString: String
    @Binding var isLoading: Bool
    @Binding var showError: Bool
    @Binding var errorMessage: String
    
    func makeUIView(context: Context) -> WKWebView {
        // Configuração mínima e estável
        let configuration = WKWebViewConfiguration()
        configuration.allowsInlineMediaPlayback = true
        
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        
        // Configurações básicas
        webView.scrollView.bounces = true
        webView.allowsBackForwardNavigationGestures = false
        
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        // Carregar apenas uma vez
        if webView.url == nil {
            loadURL(in: webView)
        }
    }
    
    private func loadURL(in webView: WKWebView) {
        guard let url = URL(string: urlString) else {
            DispatchQueue.main.async {
                self.errorMessage = "URL inválida"
                self.showError = true
                self.isLoading = false
            }
            return
        }
        
        let request = URLRequest(url: url)
        webView.load(request)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        let parent: SimpleWebView
        private var hasLoaded = false
        
        init(_ parent: SimpleWebView) {
            self.parent = parent
        }
        
        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            DispatchQueue.main.async {
                self.parent.isLoading = true
            }
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            hasLoaded = true
            DispatchQueue.main.async {
                self.parent.isLoading = false
            }
        }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            let nsError = error as NSError
            
            // Ignorar completamente erro -999 para evitar loop
            if nsError.code == NSURLErrorCancelled {
                return
            }
            
            DispatchQueue.main.async {
                self.parent.isLoading = false
                self.parent.errorMessage = "Erro: \(error.localizedDescription)"
                self.parent.showError = true
            }
        }
        
        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            let nsError = error as NSError
            
            // Ignorar completamente erro -999 para evitar loop
            if nsError.code == NSURLErrorCancelled {
                return
            }
            
            // Só mostrar erro se não carregou nada ainda
            if !hasLoaded {
                DispatchQueue.main.async {
                    self.parent.isLoading = false
                    self.parent.errorMessage = "Não foi possível carregar a página"
                    self.parent.showError = true
                }
            }
        }
        
        // Política de navegação simples
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            decisionHandler(.allow)
        }
    }
}
