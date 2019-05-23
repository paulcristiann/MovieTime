//
//  Movie.swift
//  MovieTime
//
//  Created by Paul-Cristian Vasile on 17/05/2019.
//  Copyright © 2019 Paul-Cristian Vasile. All rights reserved.
//

import Foundation
import UIKit

struct Movie: Codable
{
    var tags: [String] = []
    var _id: String = ""
    var title: String = ""
    var genres: String = ""
    var imdbId: String = ""
}
