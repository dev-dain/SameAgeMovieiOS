//
//  MovieDetailViewController.swift
//  SameAgeMovie
//
//  Created by Dain Kim on 2022/08/07.
//

import UIKit
import WebKit

class MovieDetailViewController: UIViewController {
    var movieNm: String?

    private lazy var webView: WKWebView = {
        let webConfiguration = WKWebViewConfiguration()
        let webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.uiDelegate = self
        webView.translatesAutoresizingMaskIntoConstraints = false
        return webView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        if let movieNm = movieNm {
            navigationItem.title = movieNm
            navigationItem.largeTitleDisplayMode = .never
            let urlString = "https://m.search.naver.com/search.naver?sm=mtp_hty.top&where=m&query=\(movieNm)"
            guard let encodedURL = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return }
            let url = URL(string: encodedURL)!
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }

}

// MARK: WKUIDelegate
extension MovieDetailViewController: WKUIDelegate {
    func setupUI() {
        self.view.backgroundColor = .systemBackground
        self.view.addSubview(webView)
        
        webView.snp.makeConstraints {
            $0.edges.equalTo(self.view.safeAreaLayoutGuide)
        }
    }
}
