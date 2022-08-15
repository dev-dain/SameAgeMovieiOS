//
//  HomeViewController.swift
//  SameAgeMovie
//
//  Created by Dain Kim on 2022/08/05.
//

import UIKit
import SwiftUI

class HomeViewController: UITableViewController {
    var movieList = [Movie]()
    var dataTasks = [URLSessionTask]()
    var curPage = 1
    var openStartDt: Int?
    private let loadingView = UIView()
    private let spinner = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setHomeView()
    }
    
    @objc func updateMovie(_ notification: NSNotification) {
        openStartDt = notification.object as? Int ?? 2022
        self.spinner.isHidden = false
        self.spinner.startAnimating()
        movieList = []
        dataTasks = []
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        
        guard let openStartDt = openStartDt else { return }
        fetchMovie(of: 1, year: openStartDt, completionHandler: { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                // UIActivityIndicatorView.stopAnimating() must be used from main thread only
                self.spinner.stopAnimating()
                self.spinner.isHidden = true
            }
        })
    }
}

// MARK: DataSource
extension HomeViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movieList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        let movie = movieList[indexPath.row]
        
        cell.textLabel?.text = movie.movieNm
        cell.textLabel?.font = .systemFont(ofSize: 18.0, weight: .semibold)
        if movie.directors.isEmpty {
            cell.detailTextLabel?.text = "감독 없음"
        } else {
            cell.detailTextLabel?.text = movie.directors[0].peopleNm ?? ""
        }
        
        cell.accessoryType = .disclosureIndicator
        cell.selectionStyle = .blue
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let movieNm = movieList[indexPath.row].movieNm
        let detailViewController = MovieDetailViewController()
        detailViewController.movieNm = movieNm
        show(detailViewController, sender: self)
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 125.0
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "HeaderView") as? HeaderView else { return UIView() }
        return headerView
    }

}

// MARK: Prefetch Data
extension HomeViewController: UITableViewDataSourcePrefetching {
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        guard curPage != 1 else { return }
        
        if let openStartDt = openStartDt {
            indexPaths.forEach {
                if ($0.row + 1) / 20 + 1 == curPage {
                    self.fetchMovie(of: curPage, year: openStartDt, completionHandler: { [weak self] result in
                        guard let self = self else { return }
                    })
                }
            }
        }
    }
}
// MARK: fetch Movie function
private extension HomeViewController {
    func setHomeView() {
        navigationItem.title = "동갑내기 영화🍿"
        navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.backButtonTitle = "뒤로가기"
        
        tableView = UITableView(frame: .zero, style: .grouped)
        tableView.register(HeaderView.self, forHeaderFooterViewReuseIdentifier: "HeaderView")
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "MovieTableViewCell")
        tableView.rowHeight = 60.0
        tableView.prefetchDataSource = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateMovie(_:)), name: NSNotification.Name(rawValue: "fetchMovie"), object: nil)
        
        view.addSubview(spinner)
        spinner.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview()
        }
    }
    
    func fetchMovie(of page: Int, year: Int, completionHandler: @escaping (MovieListResult) -> Void) {
        if page == 1 {
            curPage = 1
        }
        
        guard let url = URL(string: "https://www.kobis.or.kr/kobisopenapi/webservice/rest/movie/searchMovieList.json?key=\(Key.KEY)&curPage=\(page)&itemPerPage=20&openStartDt=\(year)&openEndDt=\(year)"),
              dataTasks.firstIndex(where: { task in
                  task.originalRequest?.url == url
              }) == nil
        else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let dataTask = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard error == nil,
                  let self = self,
                  let response = response as? HTTPURLResponse,
                  let data = data,
                  let movies = try? JSONDecoder().decode(MovieListResult.self, from: data) else {
                print("ERROR URLSession data task \(error?.localizedDescription ?? "")")
                return
            }
            completionHandler(movies)
            
            switch response.statusCode {
            case (200...299):
                self.movieList += movies.movieListResult.movieList
                self.curPage += 1
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            case (400...499):
                print("""
                    ERROR: Client ERROR \(response.statusCode)
                    Response: \(response)
                """)
            case (500...599):
                print("""
                    ERROR: Server ERROR \(response.statusCode)
                    Response: \(response)
                """)
            default:
                print("""
                    ERROR \(response.statusCode)
                    Response: \(response)
                """)
            }
        }
        dataTask.resume()
        dataTasks.append(dataTask)
    }
}

// MARK: SwiftUI를 활용한 미리보기
struct HomeViewController_Preview: PreviewProvider {
    static var previews: some View {
        Container().edgesIgnoringSafeArea(.all)
    }
    
    struct Container: UIViewControllerRepresentable {
        func makeUIViewController(context: Context) -> UIViewController {
            let homeViewController = HomeViewController()
            return  UINavigationController(rootViewController: homeViewController)
        }

        func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
            
        }
    }
}
