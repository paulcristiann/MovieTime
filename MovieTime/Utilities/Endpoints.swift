//
//  Endpoints.swift
//  MovieTime
//
//  Created by Paul-Cristian Vasile on 16/05/2019.
//  Copyright © 2019 Paul-Cristian Vasile. All rights reserved.
//

import Foundation

struct Endpoints {
    
    static let register = "https://sexyracoon.com:8888/api/user/register"
    static let login = "https://sexyracoon.com:8888/api/user/login"
    static let fetchMovies = "https://sexyracoon.com:8888/api/movie/getDefaults"
    static let fetchImage = "https://sexyracoon.com:8888/api/movie/poster"
    static let top = "https://sexyracoon.com:8888/api/movie/top"
    static let news = "https://sexyracoon.com:8888/api/movie/news"
    static let recommandations = "https://sexyracoon.com:8888/api/user/recommendations"
    static let userDefaults = "https://sexyracoon.com:8888/api/user/defaults"
    static let getMovieDetails = "https://sexyracoon.com:8888/api/movie/get"
	static let search = "https://sexyracoon.com:8888/api/movie/search"
    static let rate = "https://sexyracoon.com:8888/api/movie/rate"
    static let getRating = "https://sexyracoon.com:8888/api/movie/getRating"
    static let addComment = "https://sexyracoon.com:8888/api/movie/comment"
    static let getPersonalComment = "https://sexyracoon.com:8888/api/movie/getPersonalComments"
    static let getComments = "https://sexyracoon.com:8888/api/movie/getComments"
    static let history = "https://sexyracoon.com:8888/api/user/movies"

}
