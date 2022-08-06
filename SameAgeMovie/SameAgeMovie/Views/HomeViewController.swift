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
    var curPage = 1
    var openStartDt, openEndDt: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let indicatorView = UIActivityIndicatorView()
        indicatorView.isHidden = true
        
        navigationItem.title = "동갑내기 영화🍿"
        navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.prefersLargeTitles = true
        
        tableView = UITableView(frame: .zero, style: .grouped)
        tableView.register(HeaderView.self, forHeaderFooterViewReuseIdentifier: "HeaderView")
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "MovieTableViewCell")
        tableView.rowHeight = 60.0
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateMovie(_:)), name: NSNotification.Name(rawValue: "fetchMovie"), object: nil)
        
//        if movieList.isEmpty {
//            self.view = UIActivityIndicatorView()
//        }
    }
    
    @objc func updateMovie(_ notification: NSNotification) {
        let year = notification.object as? Int ?? 2022
        fetchMovie(of: 1, year: year)
    }
}

// DataSource
extension HomeViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movieList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        let movie = movieList[indexPath.row]
        cell.textLabel?.text = movie.movieNm
        cell.textLabel?.font = .systemFont(ofSize: 18.0, weight: .semibold)
        cell.detailTextLabel?.text = movie.directors[0].peopleNm ?? ""
        cell.accessoryType = .disclosureIndicator
        cell.selectionStyle = .none
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 110.0
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "HeaderView") as? HeaderView else { return UIView() }
        return headerView
    }

}

private extension HomeViewController {
    func fetchMovie(of page: Int, year: Int) {
        if page == 1 {
            self.movieList = []
        }
        
        guard let url = URL(string: "https://www.kobis.or.kr/kobisopenapi/webservice/rest/movie/searchMovieList.json?key=\(Key.KEY)&curPage=\(page)&itemPerPage=20&openStartDt=\(year)&openEndDt=\(year)") else { return }
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
            
            switch response.statusCode {
            case (200...299):
                movies.movieListResult.movieList.forEach {
                    print($0)
                }
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
    }
}

// SwiftUI를 활용한 미리보기
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
