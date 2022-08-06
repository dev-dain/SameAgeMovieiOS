//
//  Movie.swift
//  SameAgeMovie
//
//  Created by Dain Kim on 2022/08/05.
//

import Foundation

struct MovieListResult: Decodable {
    let movieListResult: MovieList
}

struct MovieList: Decodable {
    let movieList: [Movie]
}

struct Movie: Decodable {
    let movieNm, openDt: String?
    let directors: [Directors]
}

struct Directors: Decodable {
    let peopleNm: String?
}
