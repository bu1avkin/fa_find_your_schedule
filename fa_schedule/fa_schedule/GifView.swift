//
//  GifView.swift
//  fa_schedule
//
//  Created by Pedro Rojas on 16/08/21.
//

import SwiftUI
import WebKit

struct GifImage: UIViewRepresentable {
    private let name: String

    init(_ name: String) {
        self.name = name
    }

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.isOpaque = false // Задаем фон как непрозрачный
        webView.backgroundColor = .clear // Устанавливаем прозрачный фон
        webView.scrollView.isScrollEnabled = false // Отключаем скроллинг

        if let url = Bundle.main.url(forResource: name, withExtension: "gif") {
            let data = try! Data(contentsOf: url)
            webView.load(data, mimeType: "image/gif", characterEncodingName: "UTF-8", baseURL: url.deletingLastPathComponent())
        }

        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        // Обновление не требуется
    }
}



struct GifImage_Previews: PreviewProvider {
    static var previews: some View {
        GifImage("pokeball")
    }
}
